import 'dart:convert';

import 'package:edublocks_flutter/Classes/Block.dart';
import 'package:edublocks_flutter/Classes/Category.dart';
import 'package:edublocks_flutter/Widgets/codeTextPanel.dart';
import 'package:edublocks_flutter/Widgets/outputTextPanel.dart';
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

  String? _categorySelected;

  // -- Categories --
  List<Category> get categories => _allCategories;
  String? get categorySelected => _categorySelected;

  set categories(List<Category> value) {
    _allCategories = value;
    notifyListeners();
  }

  void addCategory(Category newCategory) {
    _allCategories.add(newCategory);
    notifyListeners();
  }

  void setCategorySelected(String categorySelected) {
    // If the user clicks the currently selected category a second time, set the selected category to null
    if (categorySelected == _categorySelected) {
      _categorySelected = null;
    }
    else {
      // Otherwise, set the currently selected category to be what the user has selected.
      _categorySelected = categorySelected;
    }

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

  /// Returns the first block in the list of all blocks where the code of the block matches the provided code string.
  Block getBlockByCode(String code) {
    return _allBlocks.firstWhere((element) => element.code == code);
  }

  /// Returns a list of blocks where block.category matches the provided category.
  List<Block> getBlocksByCategory(String? category) {
    if (category == null) {
      return _allBlocks;
    }
    else {
      return _allBlocks.where((element) => element.category == category).toList();
    }
  }
}

class BlocksToLoad extends ChangeNotifier {
  
  List<Block> _blocksToLoad = [];

  void AddBlockToLoad(Block block) {
    _blocksToLoad.add(block);

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
  String codeJSONString = """{"blocks": [{"line": 1, "code": "# Start Here", "hasChildren": false}]}""";

  /// Check and update all line numbers in the JSON string.
  /// ### How it works
  /// Start a counter initialised at 0. For each block, set it's line number to the counter then add 1 to the counter.
  void updateLineNumbers() {
    // Parse the JSON
    Map<String, dynamic> data = jsonDecode(codeJSONString);
    List blocks = data["blocks"];

    int counter = 1;

    for (var block in blocks) {
      block["line"] = counter;
      counter++;
    }

    codeJSONString = jsonEncode({"blocks": blocks});
  }

  /// Insert a block (using the ```Block``` class) into the code chain at a specific line number
  int insertBlock(Block block, int line) {
    const passBlock = {"line": 0, "code": "pass", "hasChildren": false};

    if (line <= 1 && line != -1) {return 1;} // Line number must be positive (except -1), and cannot be 1 as this is the start block. Inserting at -1 will automatically place the block at the end of the chain.

    // Parse the JSON
    Map<String, dynamic> data = jsonDecode(codeJSONString); 
    List blocks = data['blocks'];

    // New object to insert
    List<Map<String, dynamic>> newBlock = [{
      "line": line,
      "code": block.code,
      "hasChildren": block.hasChildren
    }];

    // If the block can have children nested (eg, while loops and if statements) then add a "pass" block to the chain
    if (block.hasChildren) {
      newBlock.add(passBlock);
    }

    if (line == -1) {
      // Add the new block to the end of the chain.
      blocks.addAll(newBlock);
    }
    else if (blocks.last["line"] <= line) { // If the block is being inserted between blocks
      // Insert the new block at the specified line number.
      // Todo this, find the block, find the block at line number ```line - 1```, then insert after it.
      int insertIndex = blocks.indexWhere((block) => block['line'] == line);
      blocks.insertAll(insertIndex, newBlock);
    }
    else {
      // If the block is being added on a new line
      blocks.addAll(newBlock);
    }

    // Save the results
    codeJSONString = jsonEncode({"blocks": blocks});
    updateLineNumbers();

    notifyListeners();

    return 0;
  }

  int removeBlock(int line) {

    if (line <= 1 && line != -1) {return 1;} // Line number must be positive (except -1), and cannot be 1 as this is the start block. Removing at -1 will automatically remove the block at the end of the chain.

    // Parse the JSON
    Map<String, dynamic> data = jsonDecode(codeJSONString); 
    List blocks = data['blocks'];

    if (line == -1) {
      // If line is -1, remove the last item in the chain
      blocks.removeLast();
    }
    else {
      // If a line number is specified, remove all items below and including that line
      blocks.removeWhere((element) => element["line"] >= line);
    }

    // Save the results
    codeJSONString = jsonEncode({"blocks": blocks});
    updateLineNumbers();

    notifyListeners();

    return 0;
  }

  List<Widget> JSONToPythonCode() {
    updateLineNumbers();

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

    for (var block in blocks) {

      // If the line number is less than 10, add a leading 0 to help allign the text correctly in the code panel.
      String? leadingZero;
      if (block["line"] < 10) { leadingZero = "0"; }

      String line = "$leadingZero${block["line"]}: ${actualIndent()}${block["code"]}";
      pythonText.add(Text(
        line,
        style: GoogleFonts.firaCode(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: codeTextColour
        ),
      ));

      // If the block has nested blocks (Eg while loops and if statements), increase the indent
      if (block["hasChildren"] == true) {
        numOfIndents++;
      }
      // If the block is a pass block, reduce the indent
      else if (block["code"] == "pass") {
        numOfIndents--;
      }
    }

    return pythonText;
  }
}

class CodeOutputTextPanelNotifier extends ChangeNotifier {
  bool _codeSelected = true; // Is the code panel selected or the output panel

  bool get codeSelected => _codeSelected;
  set codeSelected (value) {
    _codeSelected = value;
    notifyListeners();
  }

  Widget textPanel() => _codeSelected ? codeTextPanel() : outputTextPanel();
}