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
  bool seenGavin;

  int? _currentTask;
  int? _currentFeature;

  Participant({
    required this.ID,
    this.task1 = false,
    this.task2 = false,
    this.task3 = false,
    this.task4 = false,
    this.task5 = false,
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
  
  /// Returns the number of task to complete next (```int?``` between 1 and 5, inclusive). The next task is selected randomly from the pool of tasks that have not already been completed.
  /// If all tasks have been completed, function will return ```null```
  int? assignTask() {
    final random = Random();
    int? number;

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

    number = random.nextInt(incompleteTasks.length);
    return incompleteTasks[number];
  }

  /// Returns the number of feature to complete next (```int?``` between 1 and 5, inclusive). The next feature is selected randomly from the pool of features that have not already been completed.
  /// If all features have been completed, function will return ```null```
  int? getFeature() {
    return 1;
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
    final String response = await rootBundle.loadString('assets/solutions.json');
    final data = json.decode(response);

    print("Correct Solution: ${data[_currentTask.toString()]}");
    print("Given Solution: $solution");

    if (solution == data[_currentTask.toString()]) {
      return true;
    }
    else {
      return false;
    }
  }
}