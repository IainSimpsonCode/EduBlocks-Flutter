import 'dart:convert';
import 'dart:math';

import 'package:edublocks_flutter/Services/firestore.dart';
import 'package:edublocks_flutter/Services/providers.dart';
import 'package:edublocks_flutter/Services/supervisorCodePopup.dart';
import 'package:edublocks_flutter/Services/toastNotifications.dart';
import 'package:edublocks_flutter/features.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class Participant {
  final String classID;
  final String ID;
  bool task1;
  bool task2;
  bool task3;
  bool task4;
  bool task5;
  bool task6;
  bool featureA;
  bool featureB;
  bool featureC;
  bool featureD;
  bool featureE;
  bool featureF;
  bool seenGavin;

  // What task and feature are they currently working on
  int? currentTask;
  String? currentFeature;

  /// For each task, what is their progress through the task. A number between 0 and 3.
  /// 0 = they are at the start; 1 = they have completed the task up to the first error; 2 = they have used the feature to fix the error; 3 = they have completed the extention
  int _currentProgress = 0;

  /// How many times has the run button been pressed for the current activity
  int runButtonPressed = 0;

  /// bool to show when the next task button has been pressed, and the conditions have been met to show the next task
  bool _nextTask = true; // Initialise as true so that a task starts upon the app initially starting.
  bool showNextTask() {
    if (_nextTask) {
      _nextTask = false;
      resetProgress();
      return true;
    } else {
      return false;
    }
  }

  void nextTaskPressed(BuildContext context) {
    if (_currentProgress >= 2) {
      // If they have completed the main task, but may or may not have completed the extention, allow them to move on
      _nextTask = true;
      Provider.of<TaskTracker>(context, listen: false).taskUpdate();
    } else if (runButtonPressed < 2 && _currentProgress <= 2) {
      // If they have attempted the task less than twice, and not yet completed the activity
      // Show toast pop up saying to attempt the task at least twice before moving on
      showToastWithIcon(
        context,
        "You need to complete the current task before moving to the next task. If you can't figure it out, raise your hand and someone will come help",
        Icons.front_hand,
        Colors.blue[400]!,
        10,
      );
    } else if (runButtonPressed >= 2 && _currentProgress < 2) {
      // If they have attempted the task at least twice, but not been able to complete the task
      // Show a popup with a textbox
      // The user must input a 4 digit code. If the code matches the value of supervisorCode, set _nextTask to true
      showCodePopup(context, supervisorCode).then((authorized) {
        if (authorized) {
          _nextTask = true;
        } else {
          showToastWithIcon(
            context,
            "Incorrect code. Please ask a supervisor for assistance.",
            Icons.lock,
            Colors.red[400]!,
            5,
          );
        }
        Provider.of<TaskTracker>(context, listen: false).taskUpdate();
      });
    }
  }

  String _errorCode = "# Start Here";
  int _errorLine = 1;
  String _taskCodeUpToError = "";

  Participant({
    required this.classID,
    required this.ID,
    this.task1 = false,
    this.task2 = false,
    this.task3 = false,
    this.task4 = false,
    this.task5 = false,
    this.task6 = false,
    this.featureA = false,
    this.featureB = false,
    this.featureC = false,
    this.featureD = false,
    this.featureE = false,
    this.featureF = false,
    this.seenGavin = false,
    this.currentTask,
    this.currentFeature,
  });

  factory Participant.fromJson(
    String classid,
    String id,
    Map<String, dynamic> json,
  ) {
    return Participant(
      classID: classid,
      ID: id,
      task1: json["task1"] ?? false,
      task2: json["task2"] ?? false,
      task3: json["task3"] ?? false,
      task4: json["task4"] ?? false,
      task5: json["task5"] ?? false,
      task6: json["task6"] ?? false,
      featureA: json["featureA"] ?? false,
      featureB: json["featureB"] ?? false,
      featureC: json["featureC"] ?? false,
      featureD: json["featureD"] ?? false,
      featureE: json["featureE"] ?? false,
      featureF: json["featureF"] ?? false,
      seenGavin: json["seenGavin"] ?? false,

      currentTask: json['currentTask'],
      currentFeature: json['currentFeature'],
    );
  }

  /// Returns the current progress of the participant through thier current task.
  /// 0 = they are at the start; 1 = they have completed the task up to the first error; 2 = they have used the feature to fix the error; 3 = they have completed the extention
  int get currentProgress => _currentProgress;

  /// Returns the value of the current task to complete
  /// If all tasks have been completed, function will return ```null```
  int? getTask() {
    // If the current task is null, assign it a new task
    currentTask ??= assignTask();

    return currentTask;
  }

  /// Returns the value of the current feature to complete
  /// If all features have been used, function will return ```null```
  String? getFeature() {
    // If the current feature is null, assign it a new feature
    currentFeature ??= assignFeature();

    return currentFeature;
  }

  /// Returns the number of task to complete next (```int?``` between 1 and 5, inclusive). The next task is selected randomly from the pool of tasks that have not already been completed.
  /// If all tasks have been completed, function will return ```null```
  int? assignTask() {
    final random = Random();

    // If all tasks have been completed, return null
    if (task1 && task2 && task3 && task4 && task5 && task6) {
      return null;
    }

    List<int> incompleteTasks = [];

    if (!task1) {
      incompleteTasks.add(1);
    }
    if (!task2) {
      incompleteTasks.add(2);
    }
    if (!task3) {
      incompleteTasks.add(3);
    }
    if (!task4) {
      incompleteTasks.add(4);
    }
    if (!task5) {
      incompleteTasks.add(5);
    }
    if (!task6) {
      incompleteTasks.add(6);
    }

    return incompleteTasks[random.nextInt(incompleteTasks.length)];
  }

  /// Returns the number of feature to complete next (```int?``` between 1 and 5, inclusive). The next feature is selected randomly from the pool of features that have not already been completed.
  /// If all features have been completed, function will return ```null```
  String? assignFeature() {
    final random = Random();

    // If all tasks have been completed, return null
    if (featureA && featureA && featureC && featureD && featureE && featureF) {
      return null;
    }

    List<String> incompleteTasks = [];

    if (!featureA) {
      incompleteTasks.add('A');
    }
    if (!featureB) {
      incompleteTasks.add('B');
    }
    if (!featureC) {
      incompleteTasks.add('C');
    }
    if (!featureD) {
      incompleteTasks.add('D');
    }
    if (!featureE) {
      incompleteTasks.add('E');
    }
    if (!featureF) {
      incompleteTasks.add('F');
    }

    return incompleteTasks[random.nextInt(incompleteTasks.length)];
  }

  void taskComplete() {
    if (currentTask == 1) {
      task1 = true;
    } else if (currentTask == 2) {
      task2 = true;
    } else if (currentTask == 3) {
      task3 = true;
    } else if (currentTask == 4) {
      task4 = true;
    } else if (currentTask == 5) {
      task5 = true;
    } else if (currentTask == 6) {
      task6 = true;
    }

    if (currentFeature == "A") {
      featureA = true;
    } else if (currentFeature == "B") {
      featureB = true;
    } else if (currentFeature == "C") {
      featureC = true;
    } else if (currentFeature == "D") {
      featureD = true;
    } else if (currentFeature == "E") {
      featureE = true;
    } else if (currentFeature == 'F') {
      featureF = true;
    }

    currentTask = null;
    currentFeature = null;
    saveParticipantData(this);
  }

  Future<bool> checkSolution(BuildContext context, String solution) async {
    final String response = await rootBundle.loadString(
      'assets/solutions.json',
    ); // Get the solutions from a json file
    final data = json.decode(response);

    _errorCode = data["${currentTask}ErrorCode"] ?? "# Start Here";
    _errorLine = data["${currentTask}ErrorLine"] ?? 1;
    _taskCodeUpToError = data["$currentTask"] ?? "# Start Here";

    print("Solution: $solution");
    print(
      "Answer ($currentTask${_currentProgress == 1 ? "fixed" : ""}${_currentProgress == 2 ? "extention" : ""}): ${data["$currentTask${_currentProgress == 1 ? "fixed" : ""}${_currentProgress == 2 ? "extention" : ""}"]}",
    );

    if (solution ==
        data["$currentTask${_currentProgress == 1 ? "fixed" : ""}${_currentProgress == 2 ? "extention" : ""}"]) {
      // If the solution given matches the solution for the currentTask
      _currentProgress++; // If the solution was correct, increase thier progress
      if (_currentProgress == 1) {
        // If they have completed up to the first error
        Provider.of<TaskTracker>(
          context,
          listen: false,
        ).activateFeature(); // Show the new feature
      } else if (_currentProgress >= 2) {
        // If they have successfully fixed the error and finished the main tasks
        taskComplete(); // Mark the task as complete
        Provider.of<TaskTracker>(context, listen: false).taskUpdate();
      }

      return true;
    } else {
      return false;
    }
  }

  /// Returns the line of code associated with the error. Or returns null if no task is selected or the task is not found
  String getErrorCode() {
    return _errorCode;
  }

  /// Returns the line number where the error is located. Or returns null if no task is selected or the task is not found
  int getErrorLine() {
    return _errorLine;
  }

  String getCodeUpToFirstError() {
    return _taskCodeUpToError;
  }

  void resetProgress() {
    _currentProgress = 0;
    runButtonPressed = 0;

    clearCurrentTask(this);
  }
}