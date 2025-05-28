import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Classes/MoveableBlock.dart';
import 'package:collection/collection.dart';

class canvasWidget extends StatefulWidget {
  const canvasWidget({super.key});

  @override
  State<canvasWidget> createState() => _canvasWidgetState();
}

class _canvasWidgetState extends State<canvasWidget> {
  final double snapThreshold = 100;
  final double snapThresholdNested = 200;
  final Map<int, GlobalKey> blockKeys = {};
  final Map<int, Offset> dragPositions =
      {}; // store latest drag global positions

  List<MoveableBlock> blocks = [
    MoveableBlock(
      id: 0,
      type: 'Start',
      position: const Offset(100, 0),
      imagePath: 'block_images/startHere.png',
      height: 100,
    ),
    MoveableBlock(
      id: 1,
      type: 'count=0',
      position: const Offset(100, 500),
      imagePath: 'block_images/count=0.png',
      height: 100,
    ),
    MoveableBlock(
      id: 2,
      type: 'count+=1',
      position: const Offset(500, 900),
      imagePath: 'block_images/count+=1.png',
      height: 100,
    ),
    MoveableBlock(
      id: 3,
      type: 'printCount',
      position: const Offset(500, 500),
      imagePath: 'block_images/print.png',
      height: 100,
    ),
    MoveableBlock(
      id: 4,
      type: 'whileTrue',
      position: const Offset(100, 800),
      imagePath: 'block_images/whileTrue.png',
      height: 450,
    ),
    MoveableBlock(
      id: 5,
      type: 'ifCount',
      position: const Offset(900, 200),
      imagePath: 'block_images/ifCountLessOr=10.png',
      height: 300,
    ),
  ];

  List<MoveableBlock> draggedChain = [];

  @override
  void initState() {
    super.initState();
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

  void onStartDrag(int id) {
    final dragged = blocks.firstWhere((b) => b.id == id);
    if (dragged.snappedTo != null) {
      final parent = blocks.firstWhere((b) => b.id == dragged.snappedTo);
      parent.childId = null;
      dragged.snappedTo = null;
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
    final dragged = blocks.firstWhere((b) => b.id == id);

    final draggedContext = blockKeys[dragged.id]?.currentContext;
    final draggedBox = draggedContext?.findRenderObject() as RenderBox?;
    final draggedSize = draggedBox?.size ?? const Size(100, 100);

    for (var target in blocks) {
      if (target.id == dragged.id || isLoop(dragged, target)) continue;

      final targetContext = blockKeys[target.id]?.currentContext;
      if (targetContext == null) continue;

      final targetBox = targetContext.findRenderObject() as RenderBox;
      final targetSize = targetBox.size;

      final targetCenterX = target.position.dx + targetSize.width / 2;
      final draggedCenterX = dragged.position.dx + draggedSize.width / 2;

      // Bottom snap position
      final defaultSnapY = target.position.dy + targetSize.height - 30;

      // Side snap position (right middle side of target)
      final customSnapX = target.position.dx + targetSize.width + 10;
      final customSnapY =
          target.position.dy + targetSize.height / 2 - draggedSize.height / 2;

      final dxDefault = draggedCenterX - targetCenterX;
      final dyDefault = dragged.position.dy - defaultSnapY;

      final dxCustom =
          (dragged.position.dx + draggedSize.width / 2) - customSnapX;
      final dyCustom = dragged.position.dy - customSnapY;

      bool snapDone = false;

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

          final draggedChainChildren = getConnectedChain(
            dragged,
          ).skip(1); // Skip the dragged block itself
          for (var childBlock in draggedChainChildren) {
            onEndDrag(childBlock.id); // Resnap each nested block
          }
        }
      }

      // Side snap: only if target block type is in allowed list
      final sideSnapTargetTypes = [
        'whileTrue',
        'ifCount',
      ]; // <-- only these target types allow side snap

      if (!snapDone && sideSnapTargetTypes.contains(target.type)) {
        if (dxCustom.abs() < snapThresholdNested &&
            dyCustom.abs() < snapThresholdNested) {
          double x = 0;
          double y = 0;
          if (target.type == 'whileTrue') {
            switch (dragged.type) {
              case 'printCount':
                x = customSnapX - draggedSize.width / 2 - 85;
                y = customSnapY - 90;
                break;

              case 'count=0':
                x = customSnapX - draggedSize.width / 2 - 70;
                y = customSnapY - 90;
                break;

              case 'count+=1':
                x = customSnapX - draggedSize.width / 2 - 60;
                y = customSnapY - 90;
                break;

              case 'ifCount':
                x = customSnapX - draggedSize.width / 2 - 30;
                y = customSnapY + 10;
                break;
            }
            setState(() {
              dragged.position = Offset(x, y);
              dragged.snappedTo = target.id;
            });
          } else if (target.type == 'ifCount') {
            switch (dragged.type) {
              case 'printCount':
                x = customSnapX - draggedSize.width / 2 - 235;
                y = customSnapY;
                break;

              case 'count=0':
                x = customSnapX - draggedSize.width / 2 - 225;
                y = customSnapY - 10;
                break;

              case 'count+=1':
                x = customSnapX - draggedSize.width / 2 - 220;
                y = customSnapY - 10;
                break;

              case 'whileTrue':
                x = customSnapX - draggedSize.width / 2 - 220;
                y = customSnapY - 10;
                break;
            }
            setState(() {
              dragged.position = Offset(x, y);
              dragged.snappedTo = target.id;
            });
          }

          snapDone = true;
          print('side snap done');
        }
      }

      if (snapDone) break;
    }
  }

  bool isLoop(MoveableBlock child, MoveableBlock target) {
    MoveableBlock? current = target;
    while (current != null) {
      if (current.id == child.id) return true;
      if (current.childId == null) break;

      final next = blocks.where((b) => b.id == current!.childId).toList();
      if (next.isEmpty) break;

      current = next.first;
    }
    return false;
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
              block.imagePath,
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
    return Expanded(child: Stack(children: blocks.map(buildBlock).toList()));
  }
}

// class Block {
//   final int id;
//   Offset position;
//   final Color color;
//   int? snappedTo; // parent block
//   int? childId; // child block
//   String? type;

//   List<String>? options; // for dropdown options
//   String? selectedOption;
//   String? inputText;

//   Block({
//     required this.id,
//     required this.position,
//     required this.color,
//     this.snappedTo,
//     this.childId,
//     this.type,
//     this.options,
//     this.selectedOption,
//     this.inputText,
//   });
// }
