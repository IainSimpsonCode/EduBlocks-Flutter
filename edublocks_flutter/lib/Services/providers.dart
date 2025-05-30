import 'dart:convert';

import 'package:edublocks_flutter/Classes/Block.dart';
import 'package:edublocks_flutter/Classes/Category.dart';
import 'package:edublocks_flutter/style.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
}

class BlocksToLoad extends ChangeNotifier {
  
  List<Block> _blocksToLoad = List.empty();

  void AddBlockToLoad(Block block) {
    notifyListeners();
  }

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
    };

    if (block.hasChildren) {
      final nested = <String, dynamic>{"nested": {"line": line + 1, "code": "pass", "nested": []}};
      newBlock["nested"] = nested;
    }

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

  List<Widget> JSONToPythonCode() {
    // Parse the JSON
    Map<String, dynamic> data = jsonDecode(codeJSONString);
    List blocks = data["blocks"];

    List<Widget> pythonText = List.empty(growable: true);

    const indent = "  ";
    int numOfIndents = 0;
    String actualIndent() {
      String _actualIndent = "";
      for (int i = 0; i < numOfIndents; i++) {
        _actualIndent += indent;
      }
      return _actualIndent;
    }
    
    void traverseBlocks(List<dynamic> blocks) {
      for (var block in blocks) {
        String line = "${block["line"]}: ${actualIndent()}${block["code"]}";
        pythonText.add(Text(
          line,
          style: GoogleFonts.firaCode(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: codeBarColour
          ),
        ));

        // If the block has nested blocks, traverse them
        if (block['nested'] != null && block['nested'] is List && block['nested'] != List.empty()) {
          numOfIndents++;
          traverseBlocks(block['nested']);
        }
        // If the block is a pass block, reduce the indent
        else if (block["code"] == "pass") {
          numOfIndents--;
        }
      }
    }
    traverseBlocks(blocks);

    return pythonText;
  }

}