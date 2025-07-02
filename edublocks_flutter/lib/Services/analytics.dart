import 'dart:convert';

import 'package:http/http.dart' as http;

Future<bool> logAnalytics(String PID, String activity) async {

  const endpoint = 'https://data.mongodb-api.com/app/<your-app-id>/endpoint/data/v1/action/insertOne';
  const apiKey = '<your-api-key>'; // Keep this secret in real apps

  final time = DateTime.now().toIso8601String();

  final body = {
    "dataSource": "EduBlocks-Flutter",
    "database": "analytics",
    "collection": "logs",
    "document": {
      "PID": PID,
      "Activity": activity,
      "Time": time,
    }
  };

  final headers = {
    'Content-Type': 'application/json',
    'api-key': apiKey,
  };

  try {
    final response = await http.post(
      Uri.parse(endpoint),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Error uploading analytics: ${response.statusCode} - ${response.body}');
      return false;
    }
  } catch (e) {
    print('Exception uploading analytics: $e');
    return false;
  }
}