
import 'package:edublocks_flutter/Classes/Block.dart';
import 'package:flutter/material.dart';

class MoveableBlock {
  final int id;
  Offset position;
  //final String imagePath;
  final Block type;
  double? height;

  int? snappedTo;
  int? childId;
  List<MoveableBlock>? nestedBlocks;

  // For Variable type blocks
  List<String>? options;
  String? selectedOption;
  String? inputText;

  MoveableBlock({
    required this.id,
    required this.position,
    //required this.imagePath,
    required this.type,
    this.options,
    this.selectedOption,
    this.inputText,
    this.snappedTo,
    this.childId,
    this.height,
    this.nestedBlocks ,
  });
}
