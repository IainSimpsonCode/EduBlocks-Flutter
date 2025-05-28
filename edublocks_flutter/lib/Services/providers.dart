import 'dart:convert';

import 'package:edublocks_flutter/Classes/Block.dart';
import 'package:edublocks_flutter/Classes/Category.dart';
import 'package:flutter/material.dart';

/// ChangeNotifier used to store information about blocks currently loaded into the block library
/// and store information about any filters applied to limit which blocks are displayed.
/// ## Using this ChangeNotifier
/// ### Categories
/// - ```get``` Categories:<br>
/// ```Provider.of<BlockLibrary>(context, listen: false).categories;```<br>
/// - ```set``` Categories:<br>
/// ```Provider.of<BlockLibrary>(context, listen: false).categories = List.empty();```<br>
/// - ```append``` Categories:<br>
/// ```Provider.of<BlockLibrary>(context, listen: false).addCategory(Category value);```<br>
/// ### Blocks
/// - ```get``` Blocks:<br>
/// ```Provider.of<BlockLibrary>(context, listen: false).blocks;```<br>
/// - ```set``` Blocks:<br>
/// ```Provider.of<BlockLibrary>(context, listen: false).blocks = List.empty();```<br>
/// - ```append``` Blocks:<br>
/// ```Provider.of<BlockLibrary>(context, listen: false).addBlock(Block value);```<br>
class BlockLibrary extends ChangeNotifier {
  List<Block> _allBlocks = List.empty();
  List<Category> _allCategories = List.empty();
  List<Block> _blocksToLoad = List.empty();

  // -- Categories --
  List<Category> get categories => _allCategories;

  set categories(List<Category> value) {
    _allCategories = value;
    notifyListeners();
  }

  void addCategory(Category newCategory) {
    _allCategories.add(newCategory);
    notifyListeners();
  }

  // -- Blocks --
  List<Block> get blocks => _allBlocks;

  set blocks(List<Block> value) {
    _allBlocks = value;
    notifyListeners();
  }

  void addBlock(Block newBlock) {
    _allBlocks.add(newBlock);
    notifyListeners();
  }

  // -- Loading Blocks --
  Block? getBlockToLoad() {
    if (_blocksToLoad.isNotEmpty) {
      Block blockToLoad = _blocksToLoad[0];
      _blocksToLoad.removeAt(0);
      return blockToLoad;
    }

    return null;
  }
}

class CodeTracker extends ChangeNotifier {
  String codeJSONString = """
  {
    "blocks": [
      {
        "line": 0,
        "code": "# Start Here",
        "nested": []
      },
      {
        "line": 1,
        "code": "count = 0",
        "nested": []
      },
      {
        "line": 2,
        "code": "while true",
        "nested": [
          {
            "line": 3,
            "code": "print(count)",
            "nested": []
          }
        ]
      }
    ]
  }
  """;

  /// Check and update all line numbers in the JSON string.
  /// ### How it works
  /// Start a counter initialised at 0. For each block, and then each nested block within that block, set it's line number to the counter then add 1 to the counter.
  // void updateLineNumbers() {
  //   // Parse the JSON
  //   Map<String, dynamic> data = jsonDecode(codeJSONString);
  //   List blocks = data["blocks"];

  //   int counter = 0;
  //   for (var block in blocks) {
  //     // For each block, assign the correct line number
  //     block['line'] = counter;
  //     counter++;

  //     // Check the line numbers for each nested block
  //     List nestedBlocks = block["nested"];
  //     for (var block in nestedBlocks) {
  //       block['line'] = counter;
  //       counter++;
  //     }
  //   }

  //   codeJSONString = jsonEncode(data);    
  // }
  void updateLineNumbers() {
    // Parse the JSON
    Map<String, dynamic> data = jsonDecode(codeJSONString);
    List blocks = data["blocks"];

    int counter = 0;

    void updateLines(List<dynamic> blocks) {
      for (var block in blocks) {
        block['line'] = counter;
        counter++;

        // Recursively process nested blocks
        if (block['nested'] != null && block['nested'] is List) {
          updateLines(block['nested']);
        }
      }
    }

    updateLines(blocks);

    codeJSONString = jsonEncode(data);
  }

  int insertBlock(Block block, int line) {
    if (line <= 0) {return 1;} //Line number must be positive, and cannot be 0 as this is the start block

    // Parse the JSON
    Map<String, dynamic> data = jsonDecode(codeJSONString);

    // New object to insert
    Map<String, dynamic> newBlock = {
      "line": line,
      "code": block.code,
      "nested": []
    };

    // Insert the new block at the specified line number.
    // Todo this, find the block, find the block at line number ```line - 1```, then insert after it.
    List blocks = data['blocks'];

    int insertIndex = blocks.indexWhere((block) => block['line'] == (line - 1));
    if (insertIndex != -1) {
      blocks.insert(insertIndex + 1, newBlock);
    }

    // Save the results
    codeJSONString = jsonEncode(data);
    updateLineNumbers();

    return 0;
  }

  List<Text> convertJSONToCodePanelText() {

    List<Text> result = List.empty();

    updateLineNumbers();

    // Parse the JSON
    Map<String, dynamic> data = jsonDecode(codeJSONString);
    List blocks = data["blocks"];

    for (var block in blocks) {
      Text codeLine = Text(
        "${block["line"]}  ${block["code"]}"
        
      );
    }

    return result;

  }

}