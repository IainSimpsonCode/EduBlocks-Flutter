import 'package:edublocks_flutter/Classes/Block.dart';
import 'package:edublocks_flutter/Services/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../Classes/MoveableBlock.dart';
import 'package:collection/collection.dart';

class canvasWidget extends StatefulWidget {
  const canvasWidget({super.key});

  @override
  State<canvasWidget> createState() => _canvasWidgetState();
}

class _canvasWidgetState extends State<canvasWidget> {
  final double snapThreshold = 100;
  final double snapThresholdNested = 100;
  final Map<int, GlobalKey> blockKeys = {};
  final Map<int, Offset> dragPositions =
      {}; // store latest drag global positions

  List<MoveableBlock> blocks = [];

  List<MoveableBlock> draggedChain = [];

  @override
  void initState() {
    super.initState();

    Provider.of<BlocksToLoad>(context, listen: false).addListener(() {
      //Load blocks on the screen
      bool run = true;
      while (run) {
        Block? block =
            Provider.of<BlocksToLoad>(context, listen: false).getBlockToLoad();
        if (block == null) {
          run = false;
        } else {
          // Load next block in the queue
        }
      }
    });

    blocks = [
      MoveableBlock(
        id: 0,
        type: Provider.of<BlockLibrary>(
          context,
          listen: false,
        ).getBlockByCode("# Start Here"),
        position: const Offset(100, 0),
        height: 100,
      ),
      MoveableBlock(
        id: 1,
        type: Provider.of<BlockLibrary>(
          context,
          listen: false,
        ).getBlockByCode("count = 0"),
        position: const Offset(100, 500),
        height: 100,
      ),
      MoveableBlock(
        id: 2,
        type: Provider.of<BlockLibrary>(
          context,
          listen: false,
        ).getBlockByCode("count += 1"),
        position: const Offset(500, 900),
        height: 100,
      ),
      MoveableBlock(
        id: 3,
        type: Provider.of<BlockLibrary>(
          context,
          listen: false,
        ).getBlockByCode("print(count)"),
        position: const Offset(500, 500),
        height: 100,
      ),
      MoveableBlock(
        id: 4,
        type: Provider.of<BlockLibrary>(
          context,
          listen: false,
        ).getBlockByCode("while True:"),
        position: const Offset(100, 800),
        height: 450,
        nestedBlocks: [],
      ),
      MoveableBlock(
        id: 5,
        type: Provider.of<BlockLibrary>(
          context,
          listen: false,
        ).getBlockByCode("if (count <= 10):"),
        position: const Offset(900, 200),
        height: 300,
      ),
    ];

    for (var block in blocks) {
      blockKeys[block.id] = GlobalKey();
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
        final child = blocks.firstWhereOrNull((b) => b.id == block.childId);
        if (child != null) collect(child);
      }

      // Get side-snapped (nested) blocks
      final nested = blocks.where(
        (b) => b.snappedTo == block.id && block.childId != b.id,
      );
      for (var b in nested) {
        collect(b);
      }
    }

    collect(start);

    return chain;
  }

 
  //called by the gesture detector when a block is dragged
  void onStartDrag(int id) {
    // Get the block
    final dragged = blocks.firstWhere((b) => b.id == id);

    if (dragged.snappedTo != null) {
      final parent = blocks.firstWhere((b) => b.id == dragged.snappedTo);
      if (parent.nestedBlocks!.isNotEmpty) {
        if(parent.nestedBlocks?[0].id == dragged.id) parent.nestedBlocks = [];
      } else {
        parent.childId = null;
      }

      dragged.snappedTo = null;
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
    final dragged = blocks.firstWhere((b) => b.id == id);
    final draggedContext = blockKeys[dragged.id]?.currentContext;
    final draggedBox = draggedContext?.findRenderObject() as RenderBox?;

    final draggedSize = draggedBox?.size ?? const Size(100, 100);


    bool snapDone = false; //USed for tracking if a block was snapped as a child, if not snap it as a nested block
    bool newSnap = false; //Used for calling the insertBlock function in the provider. is made true only if a block is snapped for the first time.

    //iterate through all blocks
    for (var target in blocks) {
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
      final nestedSnapXCoordinatesTarget = target.position.dx + targetSize.width / 8 - 6;
      final nestedSnapYCoordinatesTarget = target.position.dy + (targetSize.height / 6) + 5;

      //x and y DISTANCES for child snapping
      final childSnapXDistance = draggedCenterX - targetCenterX;
      final childSnapYDistance = dragged.position.dy - childSnapY;

      //x and y DISTANCES for child nested snapping
      final nestedSnapXDistance = (dragged.position.dx) - nestedSnapXCoordinatesTarget;
      final nestedSnapYDistance = dragged.position.dy - nestedSnapYCoordinatesTarget;

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

          if(target.isNested) {
            dragged.isNested = true;
          }

          final draggedChainChildren = getConnectedChain(
            dragged,
          ).skip(1); // Skip the dragged block itself
          for (var childBlock in draggedChainChildren) {
            onEndDrag(childBlock.id);
          }
        }
      } else if (target.childId == dragged.id) {
        setState(() {
          dragged.position = Offset(target.position.dx, childSnapY + 20);
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
          if (nestedSnapXDistance.abs() < snapThresholdNested &&
              nestedSnapYDistance.abs() < snapThresholdNested) {
            if (target.type.code == 'while True:') {
              setState(() {
                dragged.position = Offset(nestedSnapXCoordinatesTarget, nestedSnapYCoordinatesTarget);
                dragged.snappedTo = target.id;
                dragged.isNested = true;
              });
              //add it to the list

              target.nestedBlocks?.add(dragged);
            } else if (target.type.code == 'if (count <= 10):') {
              setState(() {
                dragged.position = Offset(nestedSnapXCoordinatesTarget - 20, nestedSnapYCoordinatesTarget + 40);
                dragged.snappedTo = target.id;
                dragged.isNested = true;
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
        callInsertBlock(dragged);
      }
    }
  }

  void callInsertBlock(MoveableBlock block) {
    final first = blocks.firstWhere((b) => b.id == 0);
    List<MoveableBlock> chain = getConnectedChain(first);

    final lastBlock = chain.last;
    Provider.of<CodeTracker>(
      context,
      listen: false,
    ).insertBlock(lastBlock.type, -1);

    if(block.childId != null && block.isNested == false) {
       Provider.of<CodeTracker>(
      context,
      listen: false,
    ).insertBlock(block.type, -1);
    }
    
  }

  Widget buildBlock(MoveableBlock block) {
    return Positioned(
      left: block.position.dx,
      top: block.position.dy,
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
              ...blocks
                  .where((b) => b.type.priorityBuild == true)
                  .map(buildBlock)
                  .toList(),
              // Render the remaining blocks
              ...blocks
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