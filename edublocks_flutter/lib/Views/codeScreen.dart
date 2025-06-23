import 'package:edublocks_flutter/Page%20Sections/canvas.dart';
import 'package:edublocks_flutter/Page%20Sections/codeBar.dart';
import 'package:edublocks_flutter/Page%20Sections/sideBar.dart';
import 'package:edublocks_flutter/Page%20Sections/topBar.dart';
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

  void _showPopUpMessage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskNumber = Provider.of<ParticipantInformation>(context, listen: false).currentParticipant?.getTask() ?? 0;
      final text = "You are working on task $taskNumber";
      showDialog(
        barrierDismissible: false, // User must click a button to proceed
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Welcome'),
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

  @override
  void initState() {
    super.initState();

    // Show a popup to display which task they are initially working on.
    _showPopUpMessage();
    
    // Add a listener to update the widget when the state of the task changes
    _taskTracker = Provider.of<TaskTracker>(context, listen: false);
    _taskTracker.addListener(_onTaskUpdate);
  }

  @override
  void dispose() {
    super.dispose();

    _taskTracker.removeListener(_onTaskUpdate);
  }

  @override
  Widget build(BuildContext context) {
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