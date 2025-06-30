import 'package:edublocks_flutter/Classes/Participant.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Initialise firebase firestore instance
var db = FirebaseFirestore.instance;

Future<bool> doesParticipantExist(String classID, String participantID) async {
  try {
    var db = FirebaseFirestore.instance;

    DocumentReference docRef = db
        .collection('Classes')
        .doc(classID)
        .collection('Participants')
        .doc(participantID);

    DocumentSnapshot doc = await docRef.get();

    if (doc.exists) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    print('doesParticipantExist(): \nError checking document: $e');
    return false;
  }
}

Future<Participant?> getParticipantInfo(String classID, String participantID) async {
  try {
    var db = FirebaseFirestore.instance;

    DocumentReference docRef = db
        .collection('Classes')
        .doc(classID)
        .collection('Participants')
        .doc(participantID);

    DocumentSnapshot doc = await docRef.get();
    return Participant.fromJson(classID, participantID, doc.data() as Map<String, dynamic>);    
  } catch (e) {
    print('getParticipantInfo(): \nError loading document: $e');
    return null;
  }
}

Future<bool> saveParticipantData(Participant participant) async {
  try {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('Classes')
        .doc(participant.classID)
        .collection('Participants')
        .doc(participant.ID);

    await docRef.set({
      "task1": participant.task1,
      "task2": participant.task2,
      "task3": participant.task3,
      "task4": participant.task4,
      "task5": participant.task5,
      "task6": participant.task6,
      "featureA": participant.featureA,
      "featureB": participant.featureB,
      "featureC": participant.featureC,
      "featureD": participant.featureD,
      "featureE": participant.featureE,
      "featureF": participant.featureF
    });

    return true;
  } catch (e) {
    print("saveParticipantData(): \nError saving data: $e");
    return false;
  }
}

/// Saves the task the user is currently working on to the database. If the user leaves mid-task, this saved data will allow the user to pick up where they left off 
Future<bool> saveCurrentTask(Participant participant) async {
  try {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('Classes')
        .doc(participant.classID)
        .collection('Participants')
        .doc(participant.ID);

    await docRef.set({
      "currentTask": participant.getTask(),
    }, SetOptions(merge: true));

    return true;
  } catch (e) {
    print("saveCurrentTask(): \nError saving data: $e");
    return false;
  }
}

/// Saves the feature the user is currently working on to the database. If the user leaves mid-task, this saved data will allow the user to pick up where they left off 
Future<bool> saveCurrentFeature(Participant participant) async {
  try {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('Classes')
        .doc(participant.classID)
        .collection('Participants')
        .doc(participant.ID);

    await docRef.set({
      "currentFeature": participant.getFeature()
    }, SetOptions(merge: true));

    return true;
  } catch (e) {
    print("saveCurrentTask(): \nError saving data: $e");
    return false;
  }
}

/// Clears the data on which task is currently being worked on from the database. It is important to clear this data otherwise the user will be forced to repeat the same task everytime they load the app.
Future<bool> clearCurrentTask(Participant participant) async {
  try {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('Classes')
        .doc(participant.classID)
        .collection('Participants')
        .doc(participant.ID);

    await docRef.set({
      "currentTask": null,
      "currentFeature": null
    });

    return true;
  } catch (e) {
    print("clearCurrentTask(): \nError saving data: $e");
    return false;
  }
}
