// Additional Features
import 'package:edublocks_flutter/Services/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const bool isProduction = true;     // Is the code in production or debug mode
const bool requireLogin = true;     // Should the app load a login screen on start, or go straight to the codeScreen

bool altColours(BuildContext context) {
  return (Provider.of<ParticipantInformation>(context, listen: false).currentParticipant?.getFeature() == "C" && Provider.of<TaskTracker>(context, listen: false).isFeatureVisible);
}

bool lineNumbering(BuildContext context) {
  return (Provider.of<ParticipantInformation>(context, listen: false).currentParticipant?.getFeature() == "A" && Provider.of<TaskTracker>(context, listen: false).isFeatureVisible);
}
