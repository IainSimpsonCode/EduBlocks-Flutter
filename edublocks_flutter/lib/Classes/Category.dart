import 'dart:convert';

import 'package:edublocks_flutter/Services/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class Category {
  final String category;
  final Color color;
  final String iconName;

  Category({
    required this.category,
    required this.color,
    required this.iconName,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      category: json['category'],
      color: _hexToColor(json['color']),
      iconName: json['icon'],
    );
  }

  static Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex'; // Add opacity if not specified
    return Color(int.parse(hex, radix: 16));
  }
}

/// Load in the categories of blocks (e.g. 'Statement', 'Logic') and save the categories in the ```BlockLibrary``` ```ChangeNotifier```
Future<int> loadCategories(BuildContext context) async {
  final String response = await rootBundle.loadString('assets/categories.json');
  final data = json.decode(response);
  List<Category> categoryList =
      (data['categories'] as List)
          .map((item) => Category.fromJson(item))
          .toList();

  // Ensure the widget is still in the widget tree before accessing context to prevent using a BuildContext after an async gap.
  // If the widget is not mounted, leave unsucessfully.
  if (!context.mounted) return 1;

  Provider.of<BlockLibrary>(context, listen: false).categories = categoryList;

  return 0;
}
