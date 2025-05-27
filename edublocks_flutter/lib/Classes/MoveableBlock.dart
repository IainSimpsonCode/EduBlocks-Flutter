import 'package:flutter/material.dart';


class MoveableBlock {
  final int id;
  Offset position;
  final Color color;
  int? snappedTo; // parent block
  int? childId; // child block
  String? type;

  List<String>? options; // for dropdown options
  String? selectedOption;
  String? inputText;

  MoveableBlock({
    required this.id,
    required this.position,
    required this.color,
    this.snappedTo,
    this.childId,
    this.type,
    this.options,
    this.selectedOption,
    this.inputText,
  });
}