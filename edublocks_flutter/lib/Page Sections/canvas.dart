import 'package:edublocks_flutter/Classes/Block.dart';
import 'package:edublocks_flutter/Services/providers.dart';
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
          ..color = Colors.grey.withOpacity(0.3)
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

class _canvasWidgetState extends State<canvasWidget> {
  final double snapThreshold = 100;
  final double snapThresholdNested = 100;
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
        Block? block = Provider.of<BlocksToLoad>(context, listen: false).getBlockToLoad(); 

        if (block == null) { // If there was no block left in the queue (queue is empty), leave the loop
          run = false;
          break;
        } else {
          setState(() {
            // Load next block in the queue
            widget.blocks.add(
              MoveableBlock(
                id: getNewID(),
                type: block,
                position: const Offset(100, 0),
                height: 100,
                width: 500,
              ),
            );            
          });
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
        width: 300,
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

      // Get vertically snapped child
      if (block.childId != null) {
        final child = widget.blocks.firstWhereOrNull((b) => b.id == block.childId);
        if (child != null) collect(child);
      }

      // Get side-snapped (nested) blocks
      final nested = widget.blocks.where(
        (b) => b.snappedTo == block.id && block.childId != b.id,
      );
      for (var b in nested) {
        collect(b);
      }
    }

    collect(start);

    return chain;
  }

//   int? getBlockLineNumber(int targetId, MoveableBlock startBlock) {
//     int line = 1;
//     bool found = false;

//     int? traverse(MoveableBlock block) {
//       // If this is the block we want, return the current line
//       if (block.id == targetId) return line;

//       line++; // Move to next line after current block

//       // Traverse nested blocks (e.g., ifs, loops)
//       for (var nestedBlock in block.nestedBlocks!) {
//         int? result = traverse(nestedBlock);
//         if (result != null) return result;
//       }

//       // Add a line if this block has children (visual padding for "end")
//       if (block.type.hasChildren) {
//         line++; // Account for the visual closing line (like 'end if')
//       }

//       // Traverse next block in the chain
//       if (block.childId != null) {
//         MoveableBlock? child = widget.blocks.firstWhere(
//           (b) => b.id == block.childId,
//           orElse: () => null,
//         );
//         if (child != null) {
//           return traverse(child);
//         }
//       }

//       return null;
//     }

//     return traverse(startBlock);
// }


  void onStartDrag(int id) {
    // Get the block being dragged from the blocks list
    final dragged = widget.blocks.firstWhere((b) => b.id == id);

    // If the block was connected to another block
    if (dragged.snappedTo != null) {
      // Find the parent block is was snapped to
      final parent = widget.blocks.firstWhere((b) => b.id == dragged.snappedTo);

      // If the block being dragged matches the block nested within the parent (for if and while blocks)
      if (parent.nestedBlocks?[0].id == dragged.id) {
        // Remove the nested blocks
        parent.nestedBlocks = [];
      } else {
        // Remove the child block from the parent
        parent.childId = null;
      }

      // The dragged block is now not snapped to another block
      dragged.snappedTo = null;
      Provider.of<CodeTracker>(context, listen: false).removeBlock(-1);
    }
    draggedChain = getConnectedChain(dragged);
  }

  void onUpdateDrag(int id, DragUpdateDetails details) {
    setState(() {
      for (var block in draggedChain) {
        block.position += details.delta;
        dragPositions[block.id] = block.position;
      }
    });
  }

  void onEndDrag(int id) {
    final dragged = widget.blocks.firstWhere((b) => b.id == id);
    final draggedContext = blockKeys[dragged.id]?.currentContext;
    final draggedBox = draggedContext?.findRenderObject() as RenderBox?;

    final draggedSize = draggedBox?.size ?? const Size(100, 100);

    bool snapDone = false;
    bool newSnap = false;

    for (var target in widget.blocks) {
      newSnap = false;
      if (target.id == dragged.id) continue;

      final targetContext = blockKeys[target.id]?.currentContext;
      if (targetContext == null) continue;

      final targetBox = targetContext.findRenderObject() as RenderBox;
      final targetSize = targetBox.size;

      final targetCenterX = target.position.dx + targetSize.width / 2;
      final draggedCenterX = dragged.position.dx + draggedSize.width / 2;

      // Bottom snap position
      final defaultSnapY = target.position.dy + targetSize.height - 30;

      //x and y positions of the target block
      final customSnapX = target.position.dx + targetSize.width / 8 - 6;
      final customSnapY = target.position.dy + (targetSize.height / 6) + 5;

      final dxDefault = draggedCenterX - targetCenterX;
      final dyDefault = dragged.position.dy - defaultSnapY;

      //gap between the target and dragged
      final dxCustom = (dragged.position.dx) - customSnapX;
      final dyCustom = dragged.position.dy - customSnapY;

      // Bottom snap: only if target bottom is free (no childId)
      if (target.childId == null) {
        if (dxDefault.abs() < snapThreshold &&
            dyDefault.abs() < snapThreshold) {
          setState(() {
            dragged.position = Offset(target.position.dx, defaultSnapY + 20);
            dragged.snappedTo = target.id;
            target.childId = dragged.id;
          });

          snapDone = true;
          newSnap = true;

          final draggedChainChildren = getConnectedChain(
            dragged,
          ).skip(1); // Skip the dragged block itself
          for (var childBlock in draggedChainChildren) {
            onEndDrag(childBlock.id);
          }
        }
      } else if (target.childId == dragged.id) {
        setState(() {
          dragged.position = Offset(target.position.dx, defaultSnapY + 20);
          dragged.snappedTo = target.id;
        });
        snapDone = true;
      }

      // Side snap: only if target block type is in allowed list
      final sideSnapTargetTypes = [
        'while True:',
        'if (count <= 10):',
      ]; // <-- only these target types allow side snap

      if (!snapDone) {
        if (sideSnapTargetTypes.contains(target.type.code) &&
                target.nestedBlocks?.isEmpty == true ||
            target.nestedBlocks?[0].id == dragged.id) {
          if (dxCustom.abs() < snapThresholdNested &&
              dyCustom.abs() < snapThresholdNested) {
            if (target.type.code == 'while True:') {
              setState(() {
                dragged.position = Offset(customSnapX, customSnapY);
                dragged.snappedTo = target.id;
              });
              //add it to the list

              target.nestedBlocks?.add(dragged);
            } else if (target.type.code == 'if (count <= 10):') {
              setState(() {
                dragged.position = Offset(customSnapX - 20, customSnapY + 40);
                dragged.snappedTo = target.id;
              });
              target.nestedBlocks?.add(dragged);
            }

            snapDone = true;
            newSnap = true;
          }
        }
      }
      if (dragged.childId != null) {
        onEndDrag(dragged.childId!);
      }
      if (newSnap) {
      printChain();
    }
    }

    
  }

  void printChain() {
    final first = widget.blocks.firstWhere((b) => b.id == 0);
    List<MoveableBlock> chain = getConnectedChain(first);

    
      final lastBlock = chain.last;
      Provider.of<CodeTracker>(context, listen: false).insertBlock(lastBlock.type, -1);
    
    
    
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
              // Grid background
              CustomPaint(
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
