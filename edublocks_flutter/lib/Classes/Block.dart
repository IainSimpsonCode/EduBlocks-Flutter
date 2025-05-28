import 'dart:convert';
import 'package:edublocks_flutter/Services/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class Block {
  final String category;
  final String code;
  final String imageName;
  final bool condition;
  final bool hasChildren;

  Block({
    required this.category,
    required this.code,
    required this.imageName,
    required this.condition,
    required this.hasChildren,
  });

  factory Block.fromJson(Map<String, dynamic> json) {
    return Block(
      category: json['category'],
      code: json['code'],
      imageName: json['imageName'],
      condition: json['condition'],
      hasChildren: json['hasChildren'],
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
