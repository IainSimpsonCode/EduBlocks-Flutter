import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Classes/MoveableBlock.dart';

class canvasWidget extends StatefulWidget {
  const canvasWidget({super.key});

  @override
  State<canvasWidget> createState() => _canvasWidgetState();
}

class _canvasWidgetState extends State<canvasWidget> {
  final List<MoveableBlock> blocks = [
    MoveableBlock(
      id: 0,
      position: const Offset(100, 100),
      color: Colors.orange,
      type: 'Start',
    ),
    MoveableBlock(
      id: 1,
      position: const Offset(250, 150),
      color: Colors.green,
      type: 'Variable',
      options: ['X', 'Y', 'Z'],
      selectedOption: 'X',
      inputText: '',
    ),
    MoveableBlock(
      id: 2,
      position: const Offset(180, 400),
      color: Colors.blue,
      type: 'If',
    ),
    MoveableBlock(
      id: 3,
      position: const Offset(400, 300),
      color: Colors.purple,
      type: 'End',
    ),
  ];

  List<MoveableBlock> chainedBlocks = [];

  final double blockSize = 150;
  final double snapThreshold = 75;

  void onStartDrag(int id) {
    final block = blocks.firstWhere((b) => b.id == id);

    // Can't drag if it has a child
    if (block.childId != null) return;

    // Detach from parent
    if (block.snappedTo != null) {
      final parent = blocks.firstWhere((b) => b.id == block.snappedTo);
      setState(() {
        parent.childId = null;
        block.snappedTo = null;
      });
      onSnapChange(block);
    }
  }

  void onUpdateDrag(int id, DragUpdateDetails details) {
    final block = blocks.firstWhere((b) => b.id == id);
    if (block.childId != null) return;

    setState(() {
      block.position += details.delta;
    });
  }

  void onEndDrag(int id) {
    final block = blocks.firstWhere((b) => b.id == id);
    if (block.childId != null) return;

    for (var target in blocks) {
      if (target.id == block.id || target.childId != null) continue;

      final dx = (block.position.dx - target.position.dx).abs();
      final dy = block.position.dy - (target.position.dy + blockSize);

      if (dx < 30 && dy.abs() < snapThreshold) {
        setState(() {
          block.position = Offset(
            target.position.dx,
            target.position.dy + blockSize,
          );
          block.snappedTo = target.id;
          target.childId = block.id;
        });
        onSnapChange(block);
      }
    }
  }

  void onSnapChange(MoveableBlock block) {
    if (block.snappedTo != null) {
      if (!chainedBlocks.contains(block)) {
        chainedBlocks.add(block);
        debugPrint(block.selectedOption);
        debugPrint(block.inputText);
      }
    } else {
      chainedBlocks.remove(block);
    }

    debugPrint('Chained Blocks: ${chainedBlocks.map((b) => b.type)}');
  }

  MoveableBlock getLastInChain(MoveableBlock start) {
    MoveableBlock current = start;
    while (current.childId != null) {
      current = blocks.firstWhere((b) => b.id == current.childId);
    }
    return current;
  }

  Widget buildBlock(MoveableBlock block) {
    Widget content;

    if (block.type == 'Variable') {
      content = SizedBox(
        height: blockSize - 16, // padding
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                block.type ?? '',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 8),
              DropdownButton<String>(
                value: block.selectedOption,
                dropdownColor: block.color,
                underline: const SizedBox(),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                items:
                    block.options!
                        .map(
                          (option) => DropdownMenuItem(
                            value: option,
                            child: Text(option),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      block.selectedOption = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 80,
                height: 30,
                child: TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Number',
                    hintStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: block.color.withOpacity(0.3),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (text) {
                    setState(() {
                      block.inputText = text;
                    });
                  },
                  controller: TextEditingController(text: block.inputText),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      content = Center(
        child: Text(
          block.type ?? '',
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      );
    }

    return Positioned(
      left: block.position.dx,
      top: block.position.dy,
      child: GestureDetector(
        onPanStart: (_) => onStartDrag(block.id),
        onPanUpdate: (details) => onUpdateDrag(block.id, details),
        onPanEnd: (_) => onEndDrag(block.id),
        child: Container(
          width: blockSize,
          height: blockSize,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: block.color,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                blurRadius: 4,
                color: Colors.black26,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: content,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        children: blocks.map(buildBlock).toList()
      ),
    );
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
