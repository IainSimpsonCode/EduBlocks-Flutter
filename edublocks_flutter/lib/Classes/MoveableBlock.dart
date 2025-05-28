import 'package:flutter/material.dart';

class MoveableBlock {
  final int id;
  Offset position;
  final String imagePath;
  final String type;
  double? height;

  int? snappedTo;
  int? childId;

  // For Variable type blocks
  List<String>? options;
  String? selectedOption;
  String? inputText;

  MoveableBlock({
    required this.id,
    required this.position,
    required this.imagePath,
    required this.type,
    this.options,
    this.selectedOption,
    this.inputText,
    this.snappedTo,
    this.childId,
    this.height,
  });
}
