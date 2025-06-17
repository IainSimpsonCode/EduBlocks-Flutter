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
    return Participant.fromJson(doc.id, doc.data() as Map<String, dynamic>);    
  } catch (e) {
    print('getParticipantInfo(): \nError loading document: $e');
    return null;
  }
}