import 'dart:convert';

import 'package:edublocks_flutter/Services/providers.dart';
import 'package:edublocks_flutter/features.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

Future<bool>logAnalytics(BuildContext context, String action_type, dynamic value) async {
  String PID = Provider.of<ParticipantInformation>(context, listen: false).currentParticipant?.getPID() ?? "0000";
  int AID = Provider.of<ParticipantInformation>(context, listen: false).currentParticipant?.getTask() ?? 0;
  String FID = Provider.of<ParticipantInformation>(context, listen: false).currentParticipant?.getFeature() ?? "X";
  int VID = 2;

  final result = await sendAnalyticsToMongo(PID, AID, FID, VID, action_type, value);
  return result;
}

Future<bool> sendAnalyticsToMongo(String PID, int AID, String FID, int version, String action_type, dynamic value) async {

  if (!(value is String || value is bool || value is int)) {
    print("Log: Value was not a valid type.");
    return false;
  }

  final jsonBody = {
    "PID": PID,
    "AID": AID.toString(),
    "FID": FID,
    "VID": version.toString(),
    "activity": action_type,
    "value": value,
    //"time": DateTime.now().toString()
    "time": 1973
  };

  try {
    final url = Uri.parse("/log");  
    final headers = {"Content-Type": "application/json"};
    final body = jsonEncode(jsonBody);

    final response = await http.post(url, headers: headers, body: body);
    
    if (response.statusCode == 200) {
      if (!isProduction) {print("Activity logged successfully");}
      return true;
    }
    else {
      print("Log failed for $action_type: ${response.body}");
      return false;
    }
  } catch (e) {
    print("Error: ${e.toString()}");
    return false;
  }
}