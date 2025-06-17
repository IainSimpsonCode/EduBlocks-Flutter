import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:edublocks_flutter/Services/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'Category.dart';

class Block {
  final String category;
  final String code;
  final String imageName;
  final String displayImageName;
  final bool condition;
  final bool hasChildren;
  final bool priorityBuild;
  final double height;
  final double displayImageHeight;
  final int standardCodeColour;
  int? alternateCodeColour;

  int snapXOffset;
  int snapYOffset;

  Block({
    required this.category,
    required this.code,
    required this.imageName,
    required this.displayImageName,
    required this.condition,
    required this.hasChildren,
    required this.priorityBuild,
    required this.height,
    required this.standardCodeColour,
    required this.displayImageHeight,
    this.snapXOffset = 0,
    this.snapYOffset = 0
  });

  factory Block.fromJson(Map<String, dynamic> json) {
    return Block(
      category: json['category'] ?? "Undefined",
      code: json['code'] ?? "# Code not added",
      imageName: json['imageName'] ?? "Undefined",
      displayImageName: json['displayImageName'] ?? json['imageName'] ?? "Undefined",
      condition: json['condition'] ?? false,
      hasChildren: json['hasChildren'] ?? false,
      priorityBuild: json['priorityBuild'] ?? false,
      height: json['height'] ?? 80,
      standardCodeColour: int.parse(json["standardCodeColour"] ?? "0xFF7d8799"),
      displayImageHeight: json['displayImageHeight'] ?? json['height'] ?? 80,
      snapXOffset: json['snapXOffset'] ?? 0,
      snapYOffset: json['snapYOffset'] ?? 0
    );
  }
}

Future<int> loadBlocks(BuildContext context) async {
  final String response = await rootBundle.loadString('assets/blocks.json');
  final data = json.decode(response);
  List<Block> blockList = (data['blocks'] as List).map((item) => Block.fromJson(item)).toList();

  // Ensure the widget is still in the widget tree before accessing context to prevent using a BuildContext after an async gap.
  // If the widget is not mounted, leave unsucessfully.
  if (!context.mounted) return 1;

  Provider.of<BlockLibrary>(context, listen: false).blocks = blockList;

  return 0;
}

Future<int> assignAlternateColours(BuildContext context) async {
  // Ensure the widget is still in the widget tree before accessing context to prevent using a BuildContext after an async gap.
  // If the widget is not mounted, leave unsucessfully.
  if (!context.mounted) return 1;

  List<Block> blocks = Provider.of<BlockLibrary>(context, listen: false).blocks;
  List<Category> categories = Provider.of<BlockLibrary>(context, listen: false).categories;

  for (Block block in blocks) {
    block.alternateCodeColour = (categories.firstWhereOrNull((element) => element.category == block.category) ?? Category(category: "Blank category", color: Colors.white, iconName: "broken_image")).color.toARGB32();
  }

  return 0;
}
