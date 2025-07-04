import 'dart:convert';
import 'package:edublocks_flutter/Classes/Block.dart';
import 'package:edublocks_flutter/Classes/Category.dart';
import 'package:edublocks_flutter/Classes/MoveableBlock.dart';
import 'package:edublocks_flutter/Classes/Participant.dart';
import 'package:edublocks_flutter/Services/TextFormatter.dart';
import 'package:edublocks_flutter/Services/toastNotifications.dart';
import 'package:edublocks_flutter/Widgets/codeTextPanel.dart';
import 'package:edublocks_flutter/Widgets/outputTextPanel.dart';
import 'package:edublocks_flutter/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:edublocks_flutter/features.dart';

class ParticipantInformation extends ChangeNotifier {
  Participant? currentParticipant;

  void login(Participant participant) {
    currentParticipant ??= participant;
    notifyListeners();
  }

  void logout() {
    currentParticipant = null;
    notifyListeners();
  }
}

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
  List<Block> _allBlocks = [];
  List<Category> _allCategories = [];
  List<String> _variableNames = [];

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

  // -- Variable Names --
  List<String> get variableNames => _variableNames;

  void addVariable(String variableName) {
    
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

  // Variables requiered for canvas()
  List<MoveableBlock> blocks = [];
  Map<int, GlobalKey> blockKeys = {};
  Map<int, Offset> dragPositions = {}; // store latest drag global positions
  List<MoveableBlock> draggedChain = [];
  MoveableBlock? selectedBlock;
  MoveableBlock? proximityDetectedBlock;
  bool isProximityChild = false;
  MoveableBlock? errorBlock;

  void reinitialiseCanvasVariables(BuildContext context) {
    blockKeys = {};
    dragPositions ={};
    draggedChain = [];
    selectedBlock = null;
    proximityDetectedBlock = null;
    isProximityChild = false;
    errorBlock = null;
    
    blocks = [
      MoveableBlock(
        id: 0,
        type: Provider.of<BlockLibrary>(
          context,
          listen: false,
        ).getBlockByCode("# Start Here"),
        position: const Offset(50, 50),
        height: 90,
        nestedBlocks: [],
      ),
    ];

    for (var block in blocks) {
      if (!blockKeys.containsKey(block.id)) {
        blockKeys[block.id] = GlobalKey();
      }

      dragPositions[block.id] = block.position;
    }

    removeBlock(2); // Remove all blocks after the start block
  }

  /// Returns the total height of all the blocks within the chain of blocks
  double getHeightOfBlockChain() {
    double totalHeight = 0;

    for (MoveableBlock block in blocks) {
      totalHeight += block.height ?? 0;
    }

    return totalHeight;
  }

  String _codeJSONString = """{"blocks": [{"line": 1, "code": "# Start Here", "hasChildren": false}]}""";
  String _outputString = "";

  String get outputString => _outputString;
  void setOutputString(String value, BuildContext context) {
    _outputString = value;

    Provider.of<CodeOutputTextPanelNotifier>(context, listen: false).codeSelected = false;

    notifyListeners();
  }
  bool outputChanged = false;

  /// Check and update all line numbers in the JSON string.
  /// ### How it works
  /// Start a counter initialised at 0. For each block, set it's line number to the counter then add 1 to the counter.
  void updateLineNumbers() {
    // Parse the JSON
    Map<String, dynamic> data = jsonDecode(_codeJSONString);
    List blocks = data["blocks"];

    int counter = 1;

    for (var block in blocks) {
      block["line"] = counter;
      counter++;
    }

    _codeJSONString = jsonEncode({"blocks": blocks});
  }

  /// Insert a block (using the ```Block``` class) into the code chain at a specific line number
  int insertBlock(Block block, int line) {
    if (line <= 1 && line != -1) {return 1;} // Line number must be positive (except -1), and cannot be 1 as this is the start block. Inserting at -1 will automatically place the block at the end of the chain.

    // Parse the JSON
    Map<String, dynamic> data = jsonDecode(_codeJSONString); 
    List blocks = data['blocks'];

    // New object to insert
    List<Map<String, dynamic>> newBlock = [{
      "line": line,
      "code": block.code,
      "hasChildren": block.hasChildren,
      "standardCodeColour": block.standardCodeColour,
      "alternateCodeColour": block.alternateCodeColour
    }];

    final passBlock = {"line": 0, "code": "pass", "hasChildren": false, "standardCodeColour": block.standardCodeColour, "alternateCodeColour": block.alternateCodeColour};

    // If the block can have children nested (eg, while loops and if statements) then add a "pass" block to the chain
    if (block.hasChildren) {
      newBlock.add(passBlock);
    }

    if (line == -1) {
      // Add the new block to the end of the chain.
      blocks.addAll(newBlock);
    }
    else if (blocks.last["line"] >= line) { // If the block is being inserted between blocks
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
    _codeJSONString = jsonEncode({"blocks": blocks});
    updateLineNumbers();

    notifyListeners();

    return 0;
  }

  int removeBlock(int line) {
    if (line <= 1 && line != -1) {return 1;} // Line number must be positive (except -1), and cannot be 1 as this is the start block. Removing at -1 will automatically remove the block at the end of the chain.

    // Parse the JSON
    Map<String, dynamic> data = jsonDecode(_codeJSONString); 
    List blocks = data['blocks'];

    if (line == -1) {
      // If line is -1, remove the last item in the chain
      blocks.removeLast();
    }
    else {
      // If a line number is specified, remove all blocks at and below that line.

      // Iterate through all the blocks at and below the specified line to remove
      // Create a list of blocks to remove after iterating through the list. Removing blocks inside the for loop will cause an error as you are changing the list you are iterating through
      List<int> blocksToRemove = [];
      // When passing an if or while loop, increase skip pass. You should skip as many pass blocks as you pass if and while blocks. Eg, if you pass 2 while blocks, you should skip the next 2 pass blocks.
      int skipPass = 0;
      for (var block in blocks.where((element) => element["line"] >= line)) {
        if (block["code"] == "pass" && skipPass == 0) {
          // If you hit a pass block, and skipPass is 0, stop removing blocks as you have reached the end of the nested stack you are removing
          break;
        }
        else if (block["code"] == "pass" && skipPass > 0) {
          // If you hit a pass block, and skipPass if greater than 0, remove the pass block and continue as you have removed a whole if/while block
          skipPass--;
        }
        else if (block["hasChildren"] == true) {
          // If you hit a while or if block, increase skipPass as you will need to skip the next pass block and delete the whole if/while block
          skipPass++;
        }

        blocksToRemove.add(block["line"]);
      }


      blocks.removeWhere((element) => blocksToRemove.contains(element["line"]));
    }

    // Save the results
    _codeJSONString = jsonEncode({"blocks": blocks});
    updateLineNumbers();

    notifyListeners();

    return 0;
  }

  int removeSingleBlock(int line) {
    if (line <= 1 && line != -1) {return 1;} // Line number must be positive (except -1), and cannot be 1 as this is the start block. Removing at -1 will automatically remove the block at the end of the chain.

    // Parse the JSON
    Map<String, dynamic> data = jsonDecode(_codeJSONString); 
    List blocks = data['blocks'];

    if (line == -1) {
      // If line is -1, remove the last item in the chain
      blocks.removeLast();
    }
    else {
      // If a line number is specified, remove the specified block. 
      // If the block has children, remove the nested blocks too. When removing nested blocks, use the same code as in ```removeBlock()```, but initialise skipPass as -1
      if (blocks.firstWhere((element) => element["line"] == line)["hasChildren"] == true) {
        // Iterate through all the blocks at and below the specified line to remove
        // Create a list of blocks to remove after iterating through the list. Removing blocks inside the for loop will cause an error as you are changing the list you are iterating through
        List<int> blocksToRemove = [];
        // When passing an if or while loop, increase skip pass. You should skip as many pass blocks as you pass if and while blocks. Eg, if you pass 2 while blocks, you should skip the next 2 pass blocks.
        int skipPass = -1;
        for (var block in blocks.where((element) => element["line"] >= line)) {
          if (block["code"] == "pass" && skipPass <= 0) {
            // If you hit a pass block, and skipPass is 0, stop removing blocks as you have reached the end of the nested stack you are removing
            break;
          }
          else if (block["code"] == "pass" && skipPass > 0) {
            // If you hit a pass block, and skipPass if greater than 0, remove the pass block and continue as you have removed a whole if/while block
            skipPass--;
          }
          else if (block["hasChildren"] == true) {
            // If you hit a while or if block, increase skipPass as you will need to skip the next pass block and delete the whole if/while block
            skipPass++;
          }

          blocksToRemove.add(block["line"]);        
        }

        blocks.removeWhere((element) => blocksToRemove.contains(element["line"]));
      }
      else {
        // If the specified block did not have children or nested blocks, remove the block
        blocks.removeWhere((element) => element["line"] == line);
      }
    }

    // Save the results
    _codeJSONString = jsonEncode({"blocks": blocks});
    updateLineNumbers();

    notifyListeners();

    return 0;
  }

  /// Returns a list of strings, with just python code.
  /// This list of strings can either be used to create a list of text widgets to be used on the UI, or used to create a string to be sent to the compiler.
  String JSONToPythonCode() {
    updateLineNumbers();

    // Parse the JSON
    Map<String, dynamic> data = jsonDecode(_codeJSONString);
    List blocks = data["blocks"];

    String pythonText = "";

    const indent = " ";
    int numOfIndents = 0;
    String actualIndent() {
      String _actualIndent = "";
      for (int i = 0; i < numOfIndents; i++) {
        _actualIndent += indent;
      }
      return _actualIndent;
    }

    for (var block in blocks) {
      pythonText += "\n${actualIndent()}${block["code"]}";

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

  /// Replaces instances of "while True" with "for i in range(100)".
  /// Takes the raw python code as a parameter, and returns the cleaned code
  String cleanPythonCode(String rawCode) {

    Map<String, String> replacements = {
      "while True": "for i in range(100)"
    };

    print("Raw code: $rawCode");

    replacements.forEach((key, value) {
      rawCode = rawCode.replaceAll(key, value);
    });

    print("Cleaned code: $rawCode");

    return rawCode;
  }

  List<Widget> JSONToFormattedTextWidgets(BuildContext context) {
    updateLineNumbers();

    // Parse the JSON
    Map<String, dynamic> data = jsonDecode(_codeJSONString);
    List blocks = data["blocks"];

    List<Widget> returnWidgets = [];

    // Function to create proper indents on lines
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

      List<TextSpan> formattedText = [TextSpan(
        text: "${block["line"] < 10 ? 0 : ""}${block["line"]}: ",
        style: codeTextStyle
      )];

      formattedText.addAll(TextFormatter.formatCodeLine(context, "${actualIndent()}${block["code"]}", Color((altColours(context) ? block["alternateCodeColour"] : block["standardCodeColour"]) ?? 0xFFffffff)));
      

      returnWidgets.add(Text.rich(TextSpan( children: formattedText)));

      // If the block has nested blocks (Eg while loops and if statements), increase the indent
      if (block["hasChildren"] == true) {
        numOfIndents++;
      }
      // If the block is a pass block, reduce the indent
      else if (block["code"] == "pass") {
        numOfIndents--;
      }
    }

    return returnWidgets;
  }

  /// Will send the code currently stored in the CodeTracker notifier to a python compiler server. Returns the output as a string to be shown on the output pane.
  Future<String> run(BuildContext context) async {

    // Check if the code matches the desired solution
    if (Provider.of<ParticipantInformation>(context, listen: false).currentParticipant != null) {

      // Record that the run button has been pressed
      Provider.of<ParticipantInformation>(context, listen: false).currentParticipant!.runButtonPressed++;

      // Define what the popup should say after run is clicked
      String correctAnswerText = "";
      String incorrectAnswerText = "";
      if (Provider.of<ParticipantInformation>(context, listen: false).currentParticipant!.currentProgress == 0) { // If they are at the start of the task
        correctAnswerText = "You've correcly put together the code from the workbook. However, this code is broken and has an error. We have added a new feature to the app to help you try and fix the error. Read through the error message provided on the output panel and see if you can fix the error.";
        incorrectAnswerText = "That wasnt quite right. Your code doesn't match with what is in your workbook. Reread the task and try again.";
      }
      else if (Provider.of<ParticipantInformation>(context, listen: false).currentParticipant!.currentProgress == 1) { // If they have the new feature and are debugging
        correctAnswerText = "Correct! You've found what was causing the problem and successfully fixed it. \nNow you can work on making the code even better. Try the extention activity in your workbook.";
        incorrectAnswerText = "That wasnt quite right. The original error hasn't been fixed. Try again.";
      }
      else if (Provider.of<ParticipantInformation>(context, listen: false).currentParticipant!.currentProgress == 2) { // If they are doing the extention activity
        correctAnswerText = "Well done! You've completed the task, and made it even better through the extention acitvity. Now you can start your next task.";
        incorrectAnswerText = "That wasnt quite right. Your code doesn't match with what is in your workbook. Reread the task and try again.";
      }

      final isSolutionCorrect = await Provider.of<ParticipantInformation>(context, listen: false).currentParticipant!.checkSolution(context, JSONToPythonCode());
      print("Correct Solution?: $isSolutionCorrect");

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final text = isSolutionCorrect ? correctAnswerText : incorrectAnswerText;
        final icon = isSolutionCorrect ? Icons.check_circle : Icons.warning_amber;
        final color = isSolutionCorrect ? Colors.green : Colors.amber;
        final time = isSolutionCorrect ? 10 : 5; // If correct, give more time to read the longer notification

        showToastWithIcon(context, text, icon, color, time);
      });

    
      // Get the relevant detailed error message
      final String response = await rootBundle.loadString('assets/solutions.json'); // Get the solutions from a json file
      final data = json.decode(response);
      int currentTask = Provider.of<ParticipantInformation>(context, listen: false).currentParticipant!.getTask() ?? 0;
      if (data["$currentTask"] == JSONToPythonCode() && detailedErrorMessages(context)) { // if the code given matches what the task requires, and the feature is detailed error messages
        // Return the detailed error message
        String detailedErrorMessage = data["${currentTask}detailedErrorMessage"] ?? "Task $currentTask: Error message not found";
        setOutputString(detailedErrorMessage, context);
        return detailedErrorMessage;
      }
    }

    String output = "";


    try {
      final url = Uri.parse("https://marklochrie.co.uk/edublocks/run");
      final headers = {"Content-Type": "application/json"};
      final body = jsonEncode({"code": cleanPythonCode(JSONToPythonCode())});

      final response = await http.post(url, headers: headers, body: body);
      final data = jsonDecode(response.body);

      output = data["output"] ?? data["error"] ?? "Unknown response";
    } catch (e) {
      output = "Error: ${e.toString()}";
    }    

    setOutputString(output, context);
    return output;
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

class TaskTracker extends ChangeNotifier {
  void taskUpdate() {
    notifyListeners();
  }
  
  bool _featureVisible = false;

  bool get isFeatureVisible => _featureVisible;

  void activateFeature() {
    _featureVisible = true;
    notifyListeners();
  }

  void deactivateFeature() {
    _featureVisible = false;
    notifyListeners();
  }
}

class DeleteAll extends ChangeNotifier {
  void deleteAll(BuildContext context) {

    // Check they really want to delete all the blocks
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final text = "Are you sure you want to delete all the blocks you have placed?";
      showDialog(
        barrierDismissible: false, // User must click a button to proceed
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Are you sure?'),
            content: Text(text),
            actions: [
              TextButton(
                child: Text('Yes'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Provider.of<CodeTracker>(context, listen: false).reinitialiseCanvasVariables(context);
                  notifyListeners();
                },
              ),
              TextButton(
                child: Text('No'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    });
  }
}