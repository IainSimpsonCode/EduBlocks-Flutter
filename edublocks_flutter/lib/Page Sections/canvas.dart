import 'package:edublocks_flutter/Classes/Block.dart';
import 'package:edublocks_flutter/Services/providers.dart';
import 'package:edublocks_flutter/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../Classes/MoveableBlock.dart';
import 'package:collection/collection.dart';

class canvasWidget extends StatefulWidget {
  canvasWidget({super.key});

  List<MoveableBlock> blocks = [];

  @override
  State<canvasWidget> createState() => _canvasWidgetState();
}

class _canvasWidgetState extends State<canvasWidget> {
  final double snapThreshold = 25;
  final double snapThresholdNested = 25;
  final Map<int, GlobalKey> blockKeys = {};
  final Map<int, Offset> dragPositions =
      {}; // store latest drag global positions

  List<MoveableBlock> draggedChain = [];

  int getNewID() {
    int currentLargestID = 0; // the largest id number currently in use

    // check the list of blocks to find the current largest ID
    for (var block in widget.blocks) {
      if (block.id > currentLargestID) {
        currentLargestID = block.id;
      }
    }

    // return an ID number 1 bigger than the current biggest.
    return currentLargestID + 1;
  }

  @override
  void initState() {
    super.initState();

    // Listen to updates from the queue of blocks to load
    Provider.of<BlocksToLoad>(context, listen: false).addListener(() {
      //Load blocks on the screen
      bool run = true;
      while (run) {
        // Get the next block from the queue
        Block? block =
            Provider.of<BlocksToLoad>(context, listen: false).getBlockToLoad();

        if (block == null) {
          // If there was no block left in the queue (queue is empty), leave the loop
          run = false;
          break;
        } else {
          setState(() {
            // Load next block in the queue
            widget.blocks.add(
              MoveableBlock(
                id: getNewID(),
                type: block,
                position: const Offset(200, 100),
                height: block.height,
                nestedBlocks: [],
              ),
            );
          });
          for (var block in widget.blocks) {
            if (!blockKeys.containsKey(block.id)) {
              blockKeys[block.id] = GlobalKey();
            }

            dragPositions[block.id] = block.position;
          }
        }
      }
    });

    widget.blocks = [
      MoveableBlock(
        id: 0,
        type: Provider.of<BlockLibrary>(
          context,
          listen: false,
        ).getBlockByCode("# Start Here"),
        position: const Offset(100, 0),
        height: 100,
        nestedBlocks: [],
      ),
      // MoveableBlock(
      //   id: 1,
      //   type: Provider.of<BlockLibrary>(
      //     context,
      //     listen: false,
      //   ).getBlockByCode("count = 0"),
      //   position: const Offset(100, 500),
      //   height: 100,
      // ),
      // MoveableBlock(
      //   id: 2,
      //   type: Provider.of<BlockLibrary>(
      //     context,
      //     listen: false,
      //   ).getBlockByCode("count += 1"),
      //   position: const Offset(500, 900),
      //   height: 100,
      // ),
      // MoveableBlock(
      //   id: 3,
      //   type: Provider.of<BlockLibrary>(
      //     context,
      //     listen: false,
      //   ).getBlockByCode("print(count)"),
      //   position: const Offset(500, 500),
      //   height: 100,
      // ),
      // MoveableBlock(
      //   id: 4,
      //   type: Provider.of<BlockLibrary>(
      //     context,
      //     listen: false,
      //   ).getBlockByCode("while True:"),
      //   position: const Offset(100, 800),
      //   height: 450,
      //   nestedBlocks: [],
      // ),
      // MoveableBlock(
      //   id: 5,
      //   type: Provider.of<BlockLibrary>(
      //     context,
      //     listen: false,
      //   ).getBlockByCode("if (count <= 10):"),
      //   position: const Offset(900, 200),
      //   height: 300,
      // ),
    ];

    for (var block in widget.blocks) {
      if (!blockKeys.containsKey(block.id)) {
        blockKeys[block.id] = GlobalKey();
      }

      dragPositions[block.id] = block.position;
    }
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
      final nested = widget.blocks.where(
        (b) => b.snappedTo == block.id && block.childId != b.id,
      );
      for (var b in nested) {
        collect(b);
      }
      
      // Get vertically snapped child
      if (block.childId != null) {
        final child = widget.blocks.firstWhereOrNull(
          (b) => b.id == block.childId,
        );
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
      if (block.id == targetId) return line;

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
          widget.blocks.any((b) => b.id == block.childId)) {
        MoveableBlock? child = widget.blocks.firstWhere(
          (b) => b.id == block.childId,
        );
        return traverse(child);
      }

      return null;
    }

    return traverse(startBlock);
  }

  void onStartDrag(int id) {
    int? blockLineNumber = getBlockLineNumber(
      id,
      widget.blocks.firstWhere((b) => b.id == 0),
    );

    // Get the block being dragged from the blocks list
    final dragged = widget.blocks.firstWhere((b) => b.id == id);

    // If the block is attached to another block
    if (dragged.snappedTo != null) {
      // Find the parent block it is snapped to
      final parent = widget.blocks.firstWhere((b) => b.id == dragged.snappedTo);

      // If the parent has nested blocks
      if (parent.nestedBlocks != null && parent.nestedBlocks!.isNotEmpty) {
        // And if the dragged block is the nested block, remove nested blocks from the parent
        if (parent.nestedBlocks?[0].id == dragged.id) {parent.nestedBlocks = [];}
      } 
      // Remove the child block from the parent
      if(parent.childId == dragged.id) {parent.childId = null;}

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
    draggedChain = getConnectedChain(dragged);
  }

  //Update positions of dragged and child blocks
  void onUpdateDrag(int id, DragUpdateDetails details) {
    setState(() {
      for (var block in draggedChain) {
        block.position += details.delta;
        dragPositions[block.id] = block.position;
      }
    });
  }

  //Called by the gesture detector when a block is released
  void onEndDrag(int id) {
    // Get the block
    final dragged = widget.blocks.firstWhere((b) => b.id == id);
    final draggedContext = blockKeys[dragged.id]?.currentContext;
    final draggedBox = draggedContext?.findRenderObject() as RenderBox?;

    final draggedSize = draggedBox?.size ?? const Size(100, 100);

    bool snapDone =
        false; //USed for tracking if a block was snapped as a child, if not snap it as a nested block
    bool newSnap =
        false; //Used for calling the insertBlock function in the provider. is made true only if a block is snapped for the first time.

    //iterate through all blocks
    for (var target in widget.blocks) {
      newSnap = false;
      if (target.id == dragged.id) continue;

      final targetContext = blockKeys[target.id]?.currentContext;
      if (targetContext == null) continue;

      final targetBox = targetContext.findRenderObject() as RenderBox;
      final targetSize = targetBox.size;

      //The x coordinates of the target block is the same for chuld and nested snapping
      //The Y coordinate is different for the 2 (child and nested snapping).
      //The dragged block snaps based on the distance to the Y target of the child or nested coordinate

      //X position of the target block
      final targetCenterX = target.position.dx + targetSize.width / 2;
      //X position of the dragged block
      final draggedCenterX = dragged.position.dx + draggedSize.width / 2;

      // Bottom snap Y position for target (child)
      final childSnapY = target.position.dy + targetSize.height - 30;

      //x and y positions of the target block for nested snapping
      final nestedSnapXCoordinatesTarget =
          target.position.dx + targetSize.width / 8;
      final nestedSnapYCoordinatesTarget =
          target.position.dy + (targetSize.height / 6) + 5;

      //x and y DISTANCES for child snapping
      final childSnapXDistance = draggedCenterX - targetCenterX;
      final childSnapYDistance = dragged.position.dy - childSnapY;

      //x and y DISTANCES for child nested snapping
      final nestedSnapXDistance =
          (dragged.position.dx) - nestedSnapXCoordinatesTarget;
      final nestedSnapYDistance =
          dragged.position.dy - nestedSnapYCoordinatesTarget;

      // Bottom snap: only if target bottom is free (no childId)
      if (target.childId == null) {
        if (childSnapXDistance.abs() < snapThreshold &&
            childSnapYDistance.abs() < snapThreshold) {
          setState(() {
            dragged.position = Offset(target.position.dx, childSnapY + 20);
            dragged.snappedTo = target.id;
            target.childId = dragged.id;
          });

          snapDone = true;
          newSnap = true;

          if (target.isNested) {
            dragged.isNested = true;
          }

          final draggedChainChildren = getConnectedChain(
            dragged,
          ).skip(1); // Skip the dragged block itself
          for (var childBlock in draggedChainChildren) {
            onEndDrag(childBlock.id);
          }
        }
      } // Child snap - this is for re-snapping
      else if (target.childId == dragged.id) {
        
        setState(() {
          dragged.position = Offset(target.position.dx, childSnapY + 20);
          dragged.snappedTo = target.id;
        });
        snapDone = true;
      }

      // Side snap: only if target block type is in allowed list
      final sideSnapTargetTypes = ['while True:', 'if (count <= 10):'];

      //This part handles nested snapping
      //1 - check if the target block is in the list of allowed nested snapping types and snapDone is false
      if (!snapDone && sideSnapTargetTypes.contains(target.type.code)) {
        //2.1 - if the target block has no nested blocks
        //this means its a new snap
        if (target.nestedBlocks?.isEmpty == true) {
          //3 check distances
          if (nestedSnapXDistance.abs() < snapThresholdNested &&
              nestedSnapYDistance.abs() < snapThresholdNested) {
            //4.1 snap for while true
            if (target.type.code == 'while True:') {
              setState(() {
                dragged.position = Offset(
                  nestedSnapXCoordinatesTarget,
                  nestedSnapYCoordinatesTarget,
                );
                dragged.snappedTo = target.id;
                dragged.isNested = true;
              });

              //add it to the list
              target.nestedBlocks?.add(dragged);
            }
            //4.2 snap for if
            else if (target.type.code == 'if (count <= 10):') {
              setState(() {
                dragged.position = Offset(
                  nestedSnapXCoordinatesTarget - 20,
                  nestedSnapYCoordinatesTarget + 40,
                );
                dragged.snappedTo = target.id;
                dragged.isNested = true;
              });

              target.nestedBlocks?.add(dragged);
            }

            if(dragged.nestedBlocks!.isNotEmpty) {
              onEndDrag(dragged.nestedBlocks![0].id);
            }
            snapDone = true; //snap is set as done
            newSnap = true; //this is a new snap
          }
        }
        //2.2 - if the first nested block is the dragged block
        //this means its re-snapping the block after being dragged
        else if (target.nestedBlocks?[0].id == dragged.id) {
          //3.1
          if (target.type.code == 'while True:') {
            setState(() {
              dragged.position = Offset(
                nestedSnapXCoordinatesTarget,
                nestedSnapYCoordinatesTarget,
              );
              dragged.snappedTo = target.id;
              dragged.isNested = true;
            });

            target.nestedBlocks?.add(dragged);

          } //3.2
          else if (target.type.code == 'if (count <= 10):') {
            setState(() {
              dragged.position = Offset(
                nestedSnapXCoordinatesTarget - 20,
                nestedSnapYCoordinatesTarget + 40,
              );
              dragged.snappedTo = target.id;
              dragged.isNested = true;
            });
            target.nestedBlocks?.add(dragged);
          }

          snapDone = true; //snap is done but its not a new snap
        }
      }

      

      //if its a new snap and that block is in the main chain
      if (newSnap &&
          getConnectedChain(
            widget.blocks.firstWhere((b) => b.id == 0),
          ).contains(dragged)) {
            
        callInsertBlock(dragged);
      }

      //if the dragged block has a child, snap that as well.
      if (dragged.childId != null) {
        onEndDrag(dragged.childId!);
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
    //1.2 this is called everyother time
    else {
      //call getConnectedChain by passing in the first block of the connected chain
      List<MoveableBlock> chain = getConnectedChain(
        widget.blocks.firstWhere((b) => b.id == block.id),
      );

      //iterate through and all of the blocks
      //nested blocks are handled in getBlockLineNumber
      for (int i = 0; i < chain.length; i++) {
        print(chain[i].type.code);
        print(getBlockLineNumber(
            chain[i].id,
            widget.blocks.firstWhere((b) => b.id == 0),
          )!);
        Provider.of<CodeTracker>(context, listen: false).insertBlock(
          chain[i].type,
          getBlockLineNumber(
            chain[i].id,
            widget.blocks.firstWhere((b) => b.id == 0),
          )!,
        );
      }
    }
  }

  Widget buildBlock(MoveableBlock block) {
    return Positioned(
      left: block.position.dx,
      top: block.position.dy,
      height: block.height,
      width: block.width,
      child: GestureDetector(
        onPanStart: (_) => onStartDrag(block.id),
        onPanUpdate: (details) => onUpdateDrag(block.id, details),
        onPanEnd: (_) => onEndDrag(block.id),
        onTap:
            () => print(
              "Line number: ${getBlockLineNumber(block.id, widget.blocks.firstWhere((b) => b.id == 0))}",
            ),
        child: Container(
          key: blockKeys[block.id],
          child: SizedBox(
            height: block.height,
            child: Image.asset(
              block.type.imageName,
              fit:
                  BoxFit
                      .fitHeight, // width auto-scales to preserve aspect ratio
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
              ...widget.blocks
                  .where((b) => b.type.priorityBuild == true)
                  .map(buildBlock)
                  .toList(),
              // Render the remaining blocks
              ...widget.blocks
                  .where((b) => b.type.priorityBuild != true)
                  .map(buildBlock)
                  .toList(),
            ],
          );
        },
      ),
    );
  }
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
