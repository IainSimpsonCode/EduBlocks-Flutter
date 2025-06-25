import 'package:edublocks_flutter/Classes/Participant.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Initialise firebase firestore instance
var db = FirebaseFirestore.instance;

void getData() async {

  try {
    final CollectionReference collectionReference = db.collection("Classes").doc("01").collection("Participants");

    QuerySnapshot querySnapshot = await collectionReference.get();

    for (var doc in querySnapshot.docs) {
      print(doc.data() as Map<String, dynamic>);
    }

  } catch (e) {
    print("Error retrieving documents $e");
  }

}

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
      "featureA": participant.featureA,
      "featureB": participant.featureB,
      "featureC": participant.featureC,
      "featureD": participant.featureD,
      "featureE": participant.featureE,
    });

    return true;
  } catch (e) {
    print("saveParticipantData(): \nError saving data: $e");
    return false;
  }
}
