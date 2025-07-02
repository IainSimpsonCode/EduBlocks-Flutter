import 'dart:convert';

import 'package:http/http.dart' as http;

Future<bool> logAnalytics(int PID, String AID, String FID, int version, String action_type, dynamic value) async {
  //https://mongodbserver-h5f1.onrender.com

  final jsonBody = {
    "PID": PID,
    "AID": AID,
    "FID": FID,
    "VID": version,
    "activity": action_type,
    "value": value,
    "timestamp": DateTime.now()
  };

  try {
    final url = Uri.parse("https://mongodbserver-h5f1.onrender.com/log");
    final headers = {"Content-Type": "application/json"};
    final body = jsonEncode(jsonBody);

    final response = await http.post(url, headers: headers, body: body);
    
    if (response.statusCode == 200) {
      print("Activity logged successfully");
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