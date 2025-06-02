
import 'package:edublocks_flutter/Classes/Block.dart';
import 'package:flutter/material.dart';

class MoveableBlock {
  final int id;
  Offset position;
  final Block type;
  double? height;
  double? width;
  
  int? snappedTo;
  int? childId;
  List<MoveableBlock>? nestedBlocks;
  bool isNested = false;

  // For Variable type blocks
  List<String>? options;
  String? selectedOption;
  String? inputText;

  MoveableBlock({
    required this.id,
    required this.position,
    required this.type,
    this.options,
    this.selectedOption,
    this.inputText,
    this.snappedTo,
    this.childId,
    this.height,
    this.width,
    this.nestedBlocks,
  });
}
