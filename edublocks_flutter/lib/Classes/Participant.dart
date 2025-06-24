import 'dart:convert';
import 'dart:math';

import 'package:edublocks_flutter/Services/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class Participant {
  final String ID;
  bool task1;
  bool task2;
  bool task3;
  bool task4;
  bool task5;
  bool featureA;
  bool featureB;
  bool featureC;
  bool featureD;
  bool featureE;
  bool seenGavin;

  // What task and feature are they currently working on
  int? _currentTask;
  String? _currentFeature;

  /// For each task, what is their progress through the task. A number between 0 and 3.
  /// 0 = they are at the start; 1 = they have completed the task up to the first error; 2 = they have used the feature to fix the error; 3 = they have completed the extention
  int _currentProgress = 0; 

  String _errorLine = "# Start Here";
  String _taskCodeUpToError = "";

  Participant({
    required this.ID,
    this.task1 = false,
    this.task2 = false,
    this.task3 = false,
    this.task4 = false,
    this.task5 = false,
    this.featureA = false,
    this.featureB = false,
    this.featureC = false,
    this.featureD = false,
    this.featureE = false,
    this.seenGavin = false
  });

  factory Participant.fromJson(String id, Map<String, dynamic> json) {
    return Participant(
      ID: id,
      task1: json["task1"] ?? false,
      task2: json["task2"] ?? false,
      task3: json["task3"] ?? false,
      task4: json["task4"] ?? false,
      task5: json["task5"] ?? false,
      featureA: json["featureA"] ?? false,
      featureB: json["featureB"] ?? false,
      featureC: json["featureC"] ?? false,
      featureD: json["featureD"] ?? false,
      featureE: json["featureE"] ?? false,
      seenGavin: json["seenGavin"] ?? false
    );
  }

  /// Returns the current progress of the participant through thier current task.
  /// 0 = they are at the start; 1 = they have completed the task up to the first error; 2 = they have used the feature to fix the error; 3 = they have completed the extention
  int get currentProgress => _currentProgress;

  /// Returns the value of the current task to complete
  /// If all tasks have been completed, function will return ```null```
  int? getTask() {
    // If the current task is null, assign it a new task
    _currentTask ??= assignTask();

    return _currentTask;
  }

  /// Returns the value of the current feature to complete
  /// If all features have been used, function will return ```null```
  String? getFeature() {
    // If the current feature is null, assign it a new feature
    _currentFeature ??= assignFeature();

    return _currentFeature;
  }
  
  /// Returns the number of task to complete next (```int?``` between 1 and 5, inclusive). The next task is selected randomly from the pool of tasks that have not already been completed.
  /// If all tasks have been completed, function will return ```null```
  int? assignTask() {
    final random = Random();

    // If all tasks have been completed, return null
    if (task1 && task2 && task3 && task4 && task5) {
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

    return incompleteTasks[random.nextInt(incompleteTasks.length)];
  }

  /// Returns the number of feature to complete next (```int?``` between 1 and 5, inclusive). The next feature is selected randomly from the pool of features that have not already been completed.
  /// If all features have been completed, function will return ```null```
  String? assignFeature() {
    final random = Random();

    // If all tasks have been completed, return null
    if (featureA && featureA && featureC && featureD && featureE) {
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

    return incompleteTasks[random.nextInt(incompleteTasks.length)];
  }

  void taskComplete() {
    if (_currentTask == 1) {
      task1 = true;
    } 
    else if (_currentTask == 2) {
      task2 = true;
    } 
    else if (_currentTask == 3) {
      task3 = true;
    } 
    else if (_currentTask == 4) {
      task4 = true;
    } 
    else if (_currentTask == 5) {
      task5 = true;
    } 

    _currentTask = null;
    _currentProgress = 0;
  }

  Future<bool> checkSolution(BuildContext context, String solution) async {
    final String response = await rootBundle.loadString('assets/solutions.json'); // Get the solutions from a json file
    final data = json.decode(response);

    _errorLine = data["${_currentTask}ErrorCode"] ?? "# Start Here";
    _taskCodeUpToError = data["$_currentTask"] ?? "# Start Here";


    print("Solution: $solution");
    print("Answer ($_currentTask${_currentProgress == 1 ? "fixed" : ""}${_currentProgress == 2 ? "extention" : ""}): ${data["$_currentTask${_currentProgress == 1 ? "fixed" : ""}${_currentProgress == 2 ? "extention" : ""}"]}");

    if (solution == data["$_currentTask${_currentProgress == 1 ? "fixed" : ""}${_currentProgress == 2 ? "extention" : ""}"]) { // If the solution given matches the solution for the currentTask
      _currentProgress++; // If the solution was correct, increase thier progress
      if (_currentProgress == 1) { // If they have completed up to the first error
        Provider.of<TaskTracker>(context, listen: false).activateFeature(); // Show the new feature
      }
      else if (_currentProgress == 2) { // If they have successfully fixed the error
        Provider.of<TaskTracker>(context, listen: false).taskUpdate(); // Notify listeners that the task has been updated
      }
      else if (_currentProgress == 3) { // If they have completed the task (including the extention)
        taskComplete(); // Mark the task as complete
        Provider.of<TaskTracker>(context, listen: false).deactivateFeature(); // Hide the feature
      }

      return true;
    }
    else {
      return false;
    }
  }

  /// Returns the line number where the error is located. Or returns null if no task is selected or the task is not found
  String getErrorLine() {
    return _errorLine;
  }

  String getCodeUpToFirstError() {
    return _taskCodeUpToError;
  }
}