import 'package:edublocks_flutter/Page%20Sections/canvas.dart';
import 'package:edublocks_flutter/Page%20Sections/codeBar.dart';
import 'package:edublocks_flutter/Page%20Sections/sideBar.dart';
import 'package:edublocks_flutter/Page%20Sections/topBar.dart';
import 'package:edublocks_flutter/Services/firestore.dart';
import 'package:edublocks_flutter/Services/providers.dart';
import 'package:edublocks_flutter/style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CodeScreen extends StatefulWidget {
  const CodeScreen({super.key});

  @override
  State<CodeScreen> createState() => _CodeScreenState();
}

class _CodeScreenState extends State<CodeScreen> {

  late TaskTracker _taskTracker;
  late DeleteAll _deleteAllButton;

  void _showTaskPopUpMessage() {
    // # When starting a new task
    // Clear the blocks on screen
    Provider.of<CodeTracker>(context, listen: false).reinitialiseCanvasVariables(context, false);
    // Save what task is starting
    saveCurrentTask(Provider.of<ParticipantInformation>(context, listen: false).currentParticipant!);
    // Save what feature is being used
    saveCurrentFeature(Provider.of<ParticipantInformation>(context, listen: false).currentParticipant!);

    // Show popup to display task
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskNumber = Provider.of<ParticipantInformation>(context, listen: false).currentParticipant?.getTask();
      if (taskNumber == null) {
        return;
      }

      final text = "You are working on task $taskNumber.\nPlease find it in your workbook";
      showDialog(
        barrierDismissible: false, // User must click a button to proceed
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Your Task'),
            content: Text(text),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    });
  }

  void _onTaskUpdate() {
    setState(() {
      
    });
  }

  void _onDeleteAllPressed() {
    setState(() {
      
    });
  }

  @override
  void initState() {
    super.initState();
    
    // Add a listener to update the widget when the state of the task changes
    _taskTracker = Provider.of<TaskTracker>(context, listen: false);
    _taskTracker.addListener(_onTaskUpdate);

    // Add a listener to delete all blocks on screen when
    _deleteAllButton = Provider.of<DeleteAll>(context, listen: false);
    _deleteAllButton.addListener(_onDeleteAllPressed);
    
    // Show a popup to display which task they are initially working on.
    //_showTaskPopUpMessage();
  }

  @override
  void dispose() {
    _taskTracker.removeListener(_onTaskUpdate);
    _deleteAllButton.removeListener(_onDeleteAllPressed);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (Provider.of<ParticipantInformation>(context, listen: false).currentParticipant?.showNextTask() ?? false) { // If a new task is started
        _showTaskPopUpMessage(); // Notify the user which task they are on
    }

    return Container(
      height: MediaQuery.sizeOf(context).height,
      width: MediaQuery.sizeOf(context).width,
      color: canvasColour,
      child: Column(
        children: [
          topBarWidget(),
          Expanded(
            child: Row(
              children: [
                sideBarWidget(),
                canvasWidget(),
                codeBarWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}