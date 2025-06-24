import 'package:edublocks_flutter/Classes/Block.dart';
import 'package:edublocks_flutter/Services/providers.dart';
import 'package:edublocks_flutter/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../Classes/MoveableBlock.dart';
import 'package:collection/collection.dart';
import 'package:just_audio/just_audio.dart';
import 'package:edublocks_flutter/features.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

Future<void> loadJsonFromAssets() async {
  String jsonString = await rootBundle.loadString('assets/data.json');
  Map<String, dynamic> jsonMap = jsonDecode(jsonString);

  print(jsonMap);
}

class canvasWidget extends StatefulWidget {
  canvasWidget({super.key});

  @override
  State<canvasWidget> createState() => _canvasWidgetState();
}

class _canvasWidgetState extends State<canvasWidget> {

  late CodeTracker _codeTracker;

  final double snapThreshold = 10;
  final double snapThresholdNested = 10;
  
  final player = AudioPlayer();
  FocusNode _focusNode = FocusNode();

  late BlocksToLoad _blocksToLoad;

  /// Function called when the BlocksToLoad function calls ```notifyListeners()```. Is run everytime a block is added to the queue of blocks to load from the block library
  void _handleLoadingBlock() {
    //Load blocks on the screen
    bool run = true;
    while (run) {
      // Get the next block from the queue
      Block? block = _blocksToLoad.getBlockToLoad();

      if (block == null) {
        // If there was no block left in the queue (queue is empty), leave the loop
        run = false;
        break;
      } else {
        setState(() {
          // Load next block in the queue
          _codeTracker.blocks.add(
            MoveableBlock(
              id: getNewID(),
              type: block,
              position: const Offset(400, 100),
              height: block.height,
              nestedBlocks: [],
            ),
          );
        });
        for (var block
            in _codeTracker.blocks) {
          if (!_codeTracker.blockKeys.containsKey(block.id)) {
            _codeTracker.blockKeys[block.id] = GlobalKey();
          }

          _codeTracker.dragPositions[block.id] = block.position;
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _focusNode.requestFocus();

    _codeTracker = Provider.of<CodeTracker>(context, listen: false);

    // Listen to updates from the queue of blocks to load
    _blocksToLoad = Provider.of<BlocksToLoad>(context, listen: false);
    _blocksToLoad.addListener(_handleLoadingBlock);

    _codeTracker.blocks = [
      MoveableBlock(
        id: 0,
        type: Provider.of<BlockLibrary>(
          context,
          listen: false,
        ).getBlockByCode("# Start Here"),
        position: const Offset(50, 50),
        height: 90,
        nestedBlocks: [],
      ),
    ];

    for (var block in _codeTracker.blocks) {
      if (!_codeTracker.blockKeys.containsKey(block.id)) {
        _codeTracker.blockKeys[block.id] = GlobalKey();
      }

      _codeTracker.dragPositions[block.id] = block.position;
    }
  }

  @override
  void dispose() {
    // Safely remove provider listener
    _blocksToLoad.removeListener(_handleLoadingBlock);
    super.dispose();
  }

  int getNewID() {
    int currentLargestID = 0; // the largest id number currently in use

    // check the list of blocks to find the current largest ID
    for (var block in _codeTracker.blocks) {
      if (block.id > currentLargestID) {
        currentLargestID = block.id;
      }
    }

    // return an ID number 1 bigger than the current biggest.
    return currentLargestID + 1;
  }

  // Recursively get all children connected below the block
  List<MoveableBlock> getConnectedChain(MoveableBlock start) {
    Set<int> visited = {};
    List<MoveableBlock> chain = [];

    void collect(MoveableBlock block) {
      if (visited.contains(block.id)) return;
      visited.add(block.id);
      chain.add(block);

      // Get side-snapped (nested) blocks
      final nested = Provider.of<CodeTracker>(
        context,
        listen: false,
      ).blocks.where((b) => b.snappedTo == block.id && block.childId != b.id);
      for (var b in nested) {
        collect(b);
      }

      // Get vertically snapped child
      if (block.childId != null) {
        final child = Provider.of<CodeTracker>(
          context,
          listen: false,
        ).blocks.firstWhereOrNull((b) => b.id == block.childId);
        if (child != null) collect(child);
      }
    }

    collect(start);

    return chain;
  }

  /// Return the line number of a block in a chain the starts at startBlock.
  /// The line number is relative to startBlock, who's line number will always be 1.
  int? getBlockLineNumber(int targetId, MoveableBlock startBlock) {
    // Check if the target block is connected to the chain with the start block.
    // If it is not, leave the function as it does not have a line number
    if (!getConnectedChain(startBlock).any((b) => b.id == targetId)) {
      return null;
    }

    int line = 1;

    int? traverse(MoveableBlock block) {
      // If this is the block we want, return the current line
      if (block.id == targetId) {
        return line;
      }

      line++; // Move to next line after current block

      // Traverse nested blocks (e.g., ifs, loops)
      if (block.nestedBlocks != null) {
        for (var nestedBlock in block.nestedBlocks!) {
          int? result = traverse(nestedBlock);
          if (result != null) return result;
        }
      }

      // Add a line if this block has children (e.g., ifs, loops)
      if (block.type.hasChildren) {
        line++; // Add a line for the pass statement after any nested blocks.
      }

      // Traverse next block in the chain
      if (block.childId != null &&
          Provider.of<CodeTracker>(
            context,
            listen: false,
          ).blocks.any((b) => b.id == block.childId)) {
        MoveableBlock? child = Provider.of<CodeTracker>(
          context,
          listen: false,
        ).blocks.firstWhere((b) => b.id == block.childId);
        return traverse(child);
      }

      return null;
    }

    return traverse(startBlock);
  }

  void onStartDrag(int id) {
    int? blockLineNumber = getBlockLineNumber(
      id,
      Provider.of<CodeTracker>(
        context,
        listen: false,
      ).blocks.firstWhere((b) => b.id == 0),
    );

    // Get the block being dragged from the blocks list
    final dragged = Provider.of<CodeTracker>(
      context,
      listen: false,
    ).blocks.firstWhere((b) => b.id == id);

    // If the block is attached to another block
    if (dragged.snappedTo != null) {
      // Find the parent block it is snapped to
      final parent = Provider.of<CodeTracker>(
        context,
        listen: false,
      ).blocks.firstWhere((b) => b.id == dragged.snappedTo);

      // If the parent has nested blocks
      if (parent.nestedBlocks != null && parent.nestedBlocks!.isNotEmpty) {
        // And if the dragged block is the nested block, remove nested blocks from the parent
        if (parent.nestedBlocks?[0].id == dragged.id) {
          parent.nestedBlocks = [];
          playSound(0);
        }
      }

      // Remove the child block from the parent
      if (parent.childId == dragged.id) {
        parent.childId = null;
        playSound(0);

        if (parent.isNested) {
          MoveableBlock parentParent = getParent(parent);
          parentParent.nestedBlocks?.remove(dragged);
        }
      }

      if (dragged.isNested) {
        reSizeBlock(dragged);
        removeIsNested(dragged);
        dragged.isNested = false;
      }

      //PLay disconnect sound
      //if(parent.childId == dragged.id || parent.nestedBlocks?[0].id == dragged.id) {playSound(0); }

      // The dragged block is now not snapped to another block
      dragged.snappedTo = null;

      // If the block line number was found in the chain using the getBlockLineNumber() function, remove the block from the JSON string at the specified line number
      if (blockLineNumber != null) {
        Provider.of<CodeTracker>(
          context,
          listen: false,
        ).removeBlock(blockLineNumber);
      }
    }

    _codeTracker.draggedChain = getConnectedChain(dragged);
  }

  void removeIsNested(MoveableBlock block) {
    if (block.childId != null) {
      final child = Provider.of<CodeTracker>(
        context,
        listen: false,
      ).blocks.firstWhere((b) => b.id == block.childId);
      child.isNested = false;
      removeIsNested(child);
    }
  }

  //Update positions of dragged and child blocks
  void onUpdateDrag(int id, DragUpdateDetails details) {
    setState(() {
      for (var block in _codeTracker.draggedChain) {
        block.position += details.delta;
        _codeTracker.dragPositions[block.id] = block.position;
      }
    });
    for (var target
        in _codeTracker.blocks) {
      final dragged = Provider.of<CodeTracker>(
        context,
        listen: false,
      ).blocks.firstWhere((b) => b.id == id);
      final draggedContext = _codeTracker.blockKeys[dragged.id]?.currentContext;
      final draggedBox = draggedContext?.findRenderObject() as RenderBox?;

      final draggedSize = draggedBox?.size ?? const Size(100, 100);

      final targetContext = _codeTracker.blockKeys[target.id]?.currentContext;
      if (targetContext == null) continue;

      final targetBox = targetContext.findRenderObject() as RenderBox;
      final targetSize = targetBox.size;

      //The x coordinates of the target block is the same for chuld and nested snapping
      //The Y coordinate is different for the 2 (child and nested snapping).
      //The dragged block snaps based on the distance to the Y target of the child or nested coordinate

      //X position of the target block
      final targetSnapPointX = target.position.dx + 40;
      //X position of the dragged block
      final draggedSnapPointX = dragged.position.dx + 40;

      // Bottom snap Y position for target (child)
      final childSnapY = target.position.dy + targetSize.height;

      //x and y positions of the target block for nested snapping
      final nestedSnapXCoordinatesTarget = target.position.dx + 60;
      final nestedSnapYCoordinatesTarget = target.position.dy + 80;

      //x and y DISTANCES for child snapping
      final childSnapXDistance = draggedSnapPointX - targetSnapPointX;
      final childSnapYDistance = dragged.position.dy - childSnapY + 10;

      //x and y DISTANCES for child nested snapping
      final nestedSnapXDistance =
          draggedSnapPointX - nestedSnapXCoordinatesTarget;
      final nestedSnapYDistance =
          dragged.position.dy - nestedSnapYCoordinatesTarget + 10;

      if (childSnapXDistance.abs() < snapThreshold &&
          childSnapYDistance.abs() < snapThreshold) {
        _codeTracker.proximityDetectedBlock = Provider.of<CodeTracker>(
          context,
          listen: false,
        ).blocks.firstWhere((b) => b.id == target.id);
        _codeTracker.isProximityChild = true;
      } else if (nestedSnapXDistance.abs() < snapThresholdNested &&
          nestedSnapYDistance.abs() < snapThresholdNested) {
        _codeTracker.proximityDetectedBlock = Provider.of<CodeTracker>(
          context,
          listen: false,
        ).blocks.firstWhere((b) => b.id == target.id);
        _codeTracker.isProximityChild = false;
      } else if (_codeTracker.proximityDetectedBlock?.id == target.id) {
        _codeTracker.proximityDetectedBlock = null;
      }
    }
  }

  //Called by the gesture detector when a block is released
  void onEndDrag(int id, {bool snap = true}) {
    _codeTracker.proximityDetectedBlock = null;
    // Get the block
    final dragged = Provider.of<CodeTracker>(
      context,
      listen: false,
    ).blocks.firstWhere((b) => b.id == id);
    final draggedContext = _codeTracker.blockKeys[dragged.id]?.currentContext;
    final draggedBox = draggedContext?.findRenderObject() as RenderBox?;

    final draggedSize = draggedBox?.size ?? const Size(100, 100);

    bool snapDone =
        false; //USed for tracking if a block was snapped as a child, if not snap it as a nested block
    bool newSnap =
        false; //Used for calling the insertBlock function in the provider. is made true only if a block is snapped for the first time.
    //iterate through all blocks
    for (var target
        in _codeTracker.blocks) {
      newSnap = false;
      if (target.id == dragged.id) continue;

      final targetContext = _codeTracker.blockKeys[target.id]?.currentContext;
      if (targetContext == null) continue;

      final targetBox = targetContext.findRenderObject() as RenderBox;
      final targetSize = targetBox.size;

      //The x coordinates of the target block is the same for chuld and nested snapping
      //The Y coordinate is different for the 2 (child and nested snapping).
      //The dragged block snaps based on the distance to the Y target of the child or nested coordinate

      //X position of the target block
      final targetSnapPointX = target.position.dx + 40;
      //X position of the dragged block
      final draggedSnapPointX = dragged.position.dx + 40;

      // Bottom snap Y position for target (child)

      final childSnapY = target.position.dy + target.height!;

      //x and y positions of the target block for nested snapping
      final nestedSnapXCoordinatesTarget = target.position.dx + 60;
      final nestedSnapYCoordinatesTarget = target.position.dy + 80;

      //x and y DISTANCES for child snapping
      final childSnapXDistance = draggedSnapPointX - targetSnapPointX;
      final childSnapYDistance = dragged.position.dy - childSnapY + 10;

      //x and y DISTANCES for child nested snapping
      final nestedSnapXDistance =
          draggedSnapPointX - nestedSnapXCoordinatesTarget;
      final nestedSnapYDistance =
          dragged.position.dy - nestedSnapYCoordinatesTarget + 10;

      // Bottom snap: only if target bottom is free (no childId)
      if (target.childId == null) {
        if (childSnapXDistance.abs() < snapThreshold &&
            childSnapYDistance.abs() < snapThreshold) {
          setState(() {
            dragged.position = Offset(targetSnapPointX - 40, childSnapY - 10);
            dragged.snappedTo = target.id;
            target.childId = dragged.id;
          });

          snapDone = true;
          newSnap = true;

          if (target.isNested) {
            dragged.isNested = true;

            final targetSnappedTo = getParent(dragged);
            targetSnappedTo.nestedBlocks?.add(dragged);
            reSizeBlock(dragged);
          }

          final draggedChainChildren = getConnectedChain(
            dragged,
          ).skip(1); // Skip the dragged block itself
          for (var childBlock in draggedChainChildren) {
            onEndDrag(childBlock.id, snap: false);
          }

          // Play sound
          playSound(1);
        }
      } // Child snap - this is for re-snapping
      else if (target.childId == dragged.id) {
        setState(() {
          dragged.position = Offset(targetSnapPointX - 40, childSnapY - 10);
          dragged.snappedTo = target.id;
        });
        snapDone = true;
        if (target.isNested) {
          dragged.isNested = true;

          MoveableBlock parent = getParent(dragged);

          parent.nestedBlocks?.add(dragged);
          reSizeBlock(dragged);
        } else if (dragged.isNested) {
          dragged.isNested = false;
        }

        final draggedChainChildren = getConnectedChain(
          dragged,
        ).skip(1); // Skip the dragged block itself
        for (var childBlock in draggedChainChildren) {
          onEndDrag(childBlock.id, snap: false);
        }
      } else {
        if (childSnapXDistance.abs() < snapThreshold &&
            childSnapYDistance.abs() < snapThreshold) {
          final oldChild = Provider.of<CodeTracker>(
            context,
            listen: false,
          ).blocks.firstWhere((b) => b.id == target.childId);
          onStartDrag(oldChild.id);
          setState(() {
            oldChild.position = Offset(
              targetSnapPointX - 40,
              childSnapY - 10 + dragged.height!,
            );
            dragged.position = Offset(targetSnapPointX - 40, childSnapY - 10);
            dragged.snappedTo = target.id;
            target.childId = dragged.id;
          });
          dragged.childId = oldChild.id;
          oldChild.snappedTo = null;
          snapDone = true;
          newSnap = true;

          if (target.isNested) {
            dragged.isNested = true;

            final targetSnappedTo = getParent(dragged);
            targetSnappedTo.nestedBlocks?.add(dragged);
            reSizeBlock(dragged);
          }

          onEndDrag(oldChild.id, snap: false);

          // Play sound
          playSound(1);
        }
      }

      // Side snap: only if target block type is in allowed list
      //final sideSnapTargetTypes = ['while True:', 'if (count <= 10):']; // REPLACED: now uses the hasChildren property of blocks to determine if a block allows sideSnapping

      //This part handles nested snapping
      //1 - check if the target block is in the list of allowed nested snapping types and snapDone is false
      if (!snapDone && target.type.hasChildren) {
        //2.1 - if the target block has no nested blocks
        //this means its a new snap
        if (target.nestedBlocks?.isEmpty == true) {
          //3 check distances
          if (nestedSnapXDistance.abs() < snapThresholdNested &&
              nestedSnapYDistance.abs() < snapThresholdNested) {
            //4.1 snap blocks with the required offset per block
            setState(() {
              dragged.position = Offset(
                nestedSnapXCoordinatesTarget + target.type.snapXOffset,
                nestedSnapYCoordinatesTarget + target.type.snapYOffset,
              );
              dragged.snappedTo = target.id;
              dragged.isNested = true;
            });

            //add it to the list
            target.nestedBlocks?.add(dragged);

            if (dragged.nestedBlocks!.isNotEmpty) {
              onEndDrag(dragged.nestedBlocks![0].id, snap: false);
            }

            reSizeBlock(dragged);
            if (dragged.childId != null) {
              onEndDrag(dragged.childId!, snap: false);
            }
            if (target.childId != null) {
              onEndDrag(target.childId!);
            }
            snapDone = true; //snap is set as done
            newSnap = true; //this is a new snap
            playSound(1);
          }
        }
        //2.2 - if the first nested block is the dragged block
        //this means its re-snapping the block after being dragged
        else if (target.nestedBlocks?[0].id == dragged.id) {
          //3.1

          setState(() {
            dragged.position = Offset(
              nestedSnapXCoordinatesTarget + target.type.snapXOffset,
              nestedSnapYCoordinatesTarget + target.type.snapYOffset,
            );
            dragged.snappedTo = target.id;
            dragged.isNested = true;
          });

          if (dragged.nestedBlocks!.isNotEmpty) {
            onEndDrag(dragged.nestedBlocks![0].id, snap: false);
          }

          // if (dragged.childId != null) {
          //   onEndDrag(dragged.childId!, snap: false);
          // }

          snapDone = true; //snap is done but its not a new snap
        }
      }

      // if (newSnap && dragged.isNested) {
      //   reSizeBlock(_codeTracker.blocks.firstWhere((b) => b.id == dragged.id));
      // }

      //if the dragged block has a child, snap that as well.
      // if (dragged.childId != null) {
      //   onEndDrag(dragged.childId!, snap: false);
      // }

      //if its a new snap and that block is in the main chain
      if (newSnap &&
          getConnectedChain(
            Provider.of<CodeTracker>(
              context,
              listen: false,
            ).blocks.firstWhere((b) => b.id == 0),
          ).contains(dragged)) {
        callInsertBlock(dragged);
        break;
      }
    }
  }

  void callInsertBlock(MoveableBlock block) {
    // 1.1 snapping ONE block to the end of the main chain with no children
    // simply append it to the json
    if (block.childId == null &&
        block.isNested == false &&
        block.nestedBlocks!.isEmpty) {
      Provider.of<CodeTracker>(
        context,
        listen: false,
      ).insertBlock(block.type, -1);
    }
    //1.2 this is called when the block is nested but without children
    else if (block.childId == null && block.nestedBlocks!.isEmpty) {
      _codeTracker.insertBlock(
        block.type,
        getBlockLineNumber(
          block.id,
          Provider.of<CodeTracker>(
            context,
            listen: false,
          ).blocks.firstWhere((b) => b.id == 0),
        )!,
      );
    }
    // 1.3 every other time
    else {
      //call getConnectedChain by passing in the first block of the connected chain
      List<MoveableBlock> chain = getConnectedChain(
        Provider.of<CodeTracker>(
          context,
          listen: false,
        ).blocks.firstWhere((b) => b.id == block.id),
      );

      //iterate through and all of the blocks
      //nested blocks are handled in getBlockLineNumber
      for (int i = 0; i < chain.length; i++) {
        _codeTracker.insertBlock(
          chain[i].type,
          getBlockLineNumber(
            chain[i].id,
            Provider.of<CodeTracker>(
              context,
              listen: false,
            ).blocks.firstWhere((b) => b.id == 0),
          )!,
        );
      }
    }
  }

  void reSizeBlock(MoveableBlock block) {
    MoveableBlock parent = getParent(block);

    int parentNestedBlocks = getNumberOfNestedBlocks(parent);

    switch (parent.type.code) {
      case 'while True:':
        switch (parentNestedBlocks) {
          case 0:
            parent.type.imageName =
                "block_images/whileTrue/whileTrueSmallV1.png";
            parent.height = 150.0;

            break;
          case 1:
            parent.type.imageName =
                "block_images/whileTrue/whileTrueSmallV2.png";
            parent.height = 190.0;
            break;
          case 2:
            parent.type.imageName =
                "block_images/whileTrue/whileTrue2Blocks.png";
            parent.height = 190.0 + (70 * (parentNestedBlocks - 1));
            break;
          case 3:
            parent.type.imageName =
                "block_images/whileTrue/whileTrue3Blocks.png";
            parent.height = 190.0 + (70 * (parentNestedBlocks - 1));
            break;
          case 4:
            parent.type.imageName =
                "block_images/whileTrue/whileTrue4Blocks.png";
            parent.height = 190.0 + (70 * (parentNestedBlocks - 1));
            break;
        }
        break;

      case 'if (count <= 10):':
        switch (parentNestedBlocks) {
          case 0:
            parent.type.imageName =
                "block_images/logic/countLessThan10/ifCountLessThan10_Small.png";
            parent.height = 165.0;
            break;
          case 1:
            parent.type.imageName =
                "block_images/logic/countLessThan10/ifCountLessThan10_1Block.png";
            parent.height = 205.0;
            break;
          case 2:
            parent.type.imageName =
                "block_images/logic/countLessThan10/ifCountLessThan10_2Blocks.png";
            parent.height = 205.0 + (70 * (parentNestedBlocks - 1));
            break;
          case 3:
            parent.type.imageName =
                "block_images/logic/countLessThan10/ifCountLessThan10_3Blocks.png";
            parent.height = 205.0 + (70 * (parentNestedBlocks - 1));
            break;
        }
        break;

      case 'if (age <= 11):':
        switch (parentNestedBlocks) {
          case 0:
            parent.type.imageName =
                "block_images/logic/ageLessThan11/ifAgeLessThan11Small.png";
            parent.height = 165.0;
            break;
          case 1:
            parent.type.imageName =
                "block_images/logic/ageLessThan11/ifAgeLessThan11_1Block.png";
            parent.height = 205.0;
            break;
          case 2:
            parent.type.imageName =
                "block_images/logic/ageLessThan11/ifAgeLessThan11_2Blocks.png";
            parent.height = 205.0 + (70 * (parentNestedBlocks - 1));
            break;
          case 3:
            parent.type.imageName =
                "block_images/logic/ageLessThan11/ifAgeLessThan11_3Blocks.png";
            parent.height = 205.0 + (70 * (parentNestedBlocks - 1));
            break;
        }
        break;

      case "elif (age <= 16):":
        switch (parentNestedBlocks) {
          case 0:
            parent.type.imageName =
                "block_images/logic/elseIfAgeLessThan16/elseIfAgeLessThan16Small.png";
            parent.height = 160.0;
            break;
          case 1:
            parent.type.imageName =
                "block_images/logic/elseIfAgeLessThan16/elseIfAgeLessThan16_1Block.png";
            parent.height = 200.0;
            break;
          case 2:
            parent.type.imageName =
                "block_images/logic/elseIfAgeLessThan16/elseIfAgeLessThan16_2Blocks.png";
            parent.height = 200.0 + (70 * (parentNestedBlocks - 1));
            break;
          case 3:
            parent.type.imageName =
                "block_images/logic/elseIfAgeLessThan16/elseIfAgeLessThan16_3Blocks.png";
            parent.height = 200.0 + (70 * (parentNestedBlocks - 1));
            break;
        }
        break;

      case "else:":
        switch (parentNestedBlocks) {
          case 0:
            parent.type.imageName = "block_images/logic/else/elseSmall.png";
            parent.height = 150.0;
            break;
          case 1:
            parent.type.imageName = "block_images/logic/else/else_1Block.png";
            parent.height = 200.0;
            break;
          case 2:
            parent.type.imageName = "block_images/logic/else/else_2Blocks.png";
            parent.height = 200.0 + (70 * (parentNestedBlocks - 1));
            break;
        }
        break;
    }

    buildBlock(parent);

    if (parent.isNested) {
      reSizeBlock(parent);
    }

    if (parent.childId != null) {
      onEndDrag(parent.childId!);
    }
  }

  MoveableBlock getParent(MoveableBlock block) {
    bool breakLoop = false;
    while (true) {
      MoveableBlock snappedTo = Provider.of<CodeTracker>(
        context,
        listen: false,
      ).blocks.firstWhere((b) => b.id == block.snappedTo);

      if ((snappedTo.type.code == 'while True:' ||
              snappedTo.type.code == 'if (count <= 10):' ||
              snappedTo.type.code == 'if (age <= 11):') ||
          snappedTo.type.code == 'elif (age <= 16):' ||
          snappedTo.type.code == 'else:' && snappedTo.id != block.id) {
        return snappedTo;
      }

      block = snappedTo;
    }
  }

  int getNumberOfNestedBlocks(MoveableBlock block) {
    int blockUnits = 0;
    for (int i = 0; i < block.nestedBlocks!.length; i++) {
      MoveableBlock currentBlock = block.nestedBlocks![i];

      if (currentBlock.type.code == "if (count <= 10):" ||
          currentBlock.type.code == "while True:" ||
          currentBlock.type.code == "if (age <= 11):" ||
          currentBlock.type.code == "elif (age <= 16):" ||
          currentBlock.type.code == "else:") {
        if (currentBlock.nestedBlocks!.isNotEmpty) {
          blockUnits += getNumberOfNestedBlocks(currentBlock);
          blockUnits = blockUnits + 2;
        } else {
          blockUnits = blockUnits + 2;
        }
      } else {
        blockUnits++;
      }
    }
    return blockUnits;
  }

  Widget buildBlock(MoveableBlock block) {
    if (block.type.code ==
            Provider.of<ParticipantInformation>(
              context,
              listen: false,
            ).currentParticipant?.getErrorLine() &&
        redBorder(context)) {
      block.priority = true;
    }
    return Positioned(
      left: block.position.dx,
      top: block.position.dy,
      height: block.height,
      width: block.width,
      child: GestureDetector(
        onPanStart: (_) => onStartDrag(block.id),
        onPanUpdate: (details) => onUpdateDrag(block.id, details),
        onPanEnd: (_) => onEndDrag(block.id),
        onTap: () {
          print(
            "Line number: ${getBlockLineNumber(block.id, _codeTracker.blocks.firstWhere((b) => b.id == 0))}",
          );

          if (block.id != 0) {
            setState(() {
              if (_codeTracker.selectedBlock?.id == block.id) {
                _codeTracker.selectedBlock = null;
              } else {
                _codeTracker.selectedBlock = block;
              }
            });
            print("Block selected: ${block.type.code}");
          }
        },
        child: SizedBox(
          height: block.height,
          width: (block.width ?? 1000) + (lineNumbering(context) ? 100 : 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Number box
              lineNumbering(context)
                  ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 75,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 179, 179, 179),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 20,
                        ), // distance from top
                        child: Text(
                          '${getBlockLineNumber(block.id, _codeTracker.blocks.firstWhere((b) => b.id == 0)) ?? ''}',
                          style: const TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                  : SizedBox(width: 0, height: 0),
              // Stack with block content
              SizedBox(
                width: block.width,
                height: block.height,
                child: Stack(
                  clipBehavior: Clip.none,
                  key: _codeTracker.blockKeys[block.id],
                  children: [
                    if (_codeTracker.selectedBlock?.id == block.id)
                      Positioned(
                        left: -5,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 5,
                          decoration: BoxDecoration(
                            color: blockHighlightColour,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                        ),
                      ),

                    if (_codeTracker.proximityDetectedBlock?.id == block.id &&
                        _codeTracker.isProximityChild)
                      Positioned.fill(
                        child: CustomPaint(painter: BottomOutlinePainter()),
                      ),

                    if (_codeTracker.proximityDetectedBlock?.id == block.id &&
                        !_codeTracker.isProximityChild)
                      Positioned.fill(
                        child: CustomPaint(painter: NestedOutlinePainter()),
                      ),

                    if (block.type.code ==
                            Provider.of<ParticipantInformation>(
                              context,
                              listen: false,
                            ).currentParticipant?.getErrorLine() &&
                        redBorder(context))
                      Positioned.fill(
                        child: CustomPaint(painter: ErrorOutlinePainter()),
                      ),

                    ColorFiltered(
                      colorFilter:
                          (getBlockLineNumber(block.id, _codeTracker.blocks.firstWhere((b) => b.id == 0),
                                  ) == null) || (greyscaleHighlight(context) && block.type.code != Provider.of<ParticipantInformation>(context, listen: false).currentParticipant?.getErrorLine()) // If the block is not connected, OR, if the greyscale feature is active and this block does not match the error line
                              ? const ColorFilter.matrix([
                                0.2126,
                                0.7152,
                                0.0722,
                                0,
                                0,
                                0.2126,
                                0.7152,
                                0.0722,
                                0,
                                0,
                                0.2126,
                                0.7152,
                                0.0722,
                                0,
                                0,
                                0,
                                0,
                                0,
                                1,
                                0,
                              ])
                              : const ColorFilter.mode(
                                Colors.transparent,
                                BlendMode.multiply,
                              ),
                      child: Image.asset(
                        block.type.imageName,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    void detatch(MoveableBlock block, bool? removeDecendants) {
      if (removeDecendants == true) {
        int? blockLineNumber = getBlockLineNumber(
          block.id,
          Provider.of<CodeTracker>(
            context,
            listen: false,
          ).blocks.firstWhere((b) => b.id == 0),
        );

        // If the block is attached to another block
        if (block.snappedTo != null) {
          // Find the parent block it is snapped to
          final parent = Provider.of<CodeTracker>(
            context,
            listen: false,
          ).blocks.firstWhere((b) => b.id == block.snappedTo);

          // If the parent has nested blocks
          if (parent.nestedBlocks != null && parent.nestedBlocks!.isNotEmpty) {
            // And if the block is the nested block, remove nested blocks from the parent
            if (parent.nestedBlocks?[0].id == block.id) {
              parent.nestedBlocks = [];
            }
          }
          // Remove the child block from the parent
          if (parent.childId == block.id) {
            parent.childId = null;
          }

          // The block is now not snapped to another block
          block.snappedTo = null;

          // If the block line number was found in the chain using the getBlockLineNumber() function, remove the block from the JSON string at the specified line number
          if (blockLineNumber != null) {
            Provider.of<CodeTracker>(
              context,
              listen: false,
            ).removeBlock(blockLineNumber);
          }
        }
      } else if (removeDecendants == false) {
        int? blockLineNumber = getBlockLineNumber(
          block.id,
          Provider.of<CodeTracker>(
            context,
            listen: false,
          ).blocks.firstWhere((b) => b.id == 0),
        );

        // If the block is attached to another block
        if (block.snappedTo != null) {
          // Find the parent block it is snapped to
          final parent = Provider.of<CodeTracker>(
            context,
            listen: false,
          ).blocks.firstWhere((b) => b.id == block.snappedTo);

          // If the parent has nested blocks
          if (parent.nestedBlocks != null && parent.nestedBlocks!.isNotEmpty) {
            // And if the block is the nested block, remove nested blocks from the parent
            if (parent.nestedBlocks?[0].id == block.id) {
              parent.nestedBlocks = [];
            }
          }
          // Remove the child block from the parent
          if (parent.childId == block.id) {
            parent.childId = null;
          }

          // The block is now not snapped to another block
          block.snappedTo = null;

          // If the block line number was found in the chain using the getBlockLineNumber() function, remove the block from the JSON string at the specified line number
          if (blockLineNumber != null) {
            Provider.of<CodeTracker>(
              context,
              listen: false,
            ).removeSingleBlock(blockLineNumber);
          }
        }
      } else if (removeDecendants == null) {
        // If the block is attached to another block
        if (block.snappedTo != null) {
          // Find the parent block it is snapped to
          final parent = Provider.of<CodeTracker>(
            context,
            listen: false,
          ).blocks.firstWhere((b) => b.id == block.snappedTo);

          // If the parent has nested blocks
          if (parent.nestedBlocks != null && parent.nestedBlocks!.isNotEmpty) {
            // And if the block is the nested block, remove nested blocks from the parent
            if (parent.nestedBlocks?[0].id == block.id) {
              parent.nestedBlocks = [];
            }
          }
          // Remove the child block from the parent
          if (parent.childId == block.id) {
            parent.childId = null;
          }

          // The block is now not snapped to another block
          block.snappedTo = null;
        }
      }
    }

    // If the delete key is pressed
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.delete) {
      // Check if a block was selected
      if (_codeTracker.selectedBlock != null) {
        // Delete the block

        // Assert that the selectedBlock is not null, and does exist
        final block = _codeTracker.selectedBlock!;

        // If the block had any children, detatch them
        if (block.childId != null) {
          detatch(
            Provider.of<CodeTracker>(
              context,
              listen: false,
            ).blocks.firstWhere((element) => element.id == block.childId),
            true,
          );
        }

        // Then detach the block being removed
        detatch(block, true);

        // Then remove the block from blocks to prevent it being redrawn
        setState(() {
          Provider.of<CodeTracker>(
            context,
            listen: false,
          ).blocks.removeWhere((element) => element.id == block.id);
        });
        playSound(2);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // Paint background
                isProduction
                    ? CustomPaint(
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                    )
                    : CustomPaint(
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                      painter: GridPainter(gridSpacing: 100),
                    ),
                // Render any blocks that have priorityBuild first
                ..._codeTracker.blocks
                    .where(
                      (b) => b.type.priorityBuild == true || b.priority == true,
                    )
                    .map(buildBlock)
                    .toList(),
                // Render the remaining blocks
                ..._codeTracker.blocks
                    .where((b) => b.type.priorityBuild != true)
                    .map(buildBlock)
                    .toList(),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> playSound(int option) async {
    if (option == 0) {
      await player.setAsset('sounds/disconnect.wav');
      await player.play();
    } else if (option == 1) {
      await player.setAsset('sounds/click.mp3');
      await player.play();
    } else {
      await player.setAsset('sounds/disconnect.wav');
      await player.play();
    }
  }
}

class BottomOutlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFFFFD600) // Yellow
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10;

    final path = Path();

    double notchEndX = 0;

    path.moveTo(notchEndX, size.height - 8); // start just after notch
    path.lineTo(size.width, size.height - 8); // go to bottom-right

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class NestedOutlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFFFFD600) // Yellow
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10;

    final path = Path();

    double notchEndX = 25;

    path.moveTo(notchEndX, 70); // start just after notch
    path.lineTo(size.width, 70); // go to bottom-right

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ErrorOutlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color.fromARGB(255, 255, 0, 0) // Yellow
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class GridPainter extends CustomPainter {
  final double gridSpacing;
  final TextStyle labelStyle;

  GridPainter({
    this.gridSpacing = 100,
    this.labelStyle = const TextStyle(fontSize: 12, color: Colors.grey),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.grey
          ..strokeWidth = 1;

    final textPainter = TextPainter(
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );

    // Draw vertical lines with labels
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      textPainter.text = TextSpan(text: '${x.toInt()}', style: labelStyle);
      textPainter.layout();
      textPainter.paint(canvas, Offset(x + 2, 2));
    }

    // Draw horizontal lines with labels
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      textPainter.text = TextSpan(text: '${y.toInt()}', style: labelStyle);
      textPainter.layout();
      textPainter.paint(canvas, Offset(2, y + 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
