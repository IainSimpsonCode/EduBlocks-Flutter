import 'package:edublocks_flutter/Classes/Block.dart';
import 'package:edublocks_flutter/Classes/Category.dart';
import 'package:edublocks_flutter/Views/loadingScreen.dart';
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