import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

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

  void taskComplete(int task) {
    if (task == 1) {
      task1 = true;
    } 
    else if (task == 2) {
      task2 = true;
    } 
    else if (task == 3) {
      task3 = true;
    } 
    else if (task == 4) {
      task4 = true;
    } 
    else if (task == 5) {
      task5 = true;
    } 
  }

  Future<bool> checkSolution(String solution) async {
    final String response = await rootBundle.loadString('assets/solutions.json'); // Get the solutions from a json file
    final data = json.decode(response);

    if (solution == data[_currentTask.toString()]) { // If the solution given matches the solution for the currentTask
      return true;
    }
    else {
      return false;
    }
  }
}