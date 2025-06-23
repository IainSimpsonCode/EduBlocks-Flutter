// Additional Features
import 'package:edublocks_flutter/Services/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const bool isProduction = true;     // Is the code in production or debug mode
const bool requireLogin = true;     // Should the app load a login screen on start, or go straight to the codeScreen

bool lineNumbering(BuildContext context) {
  return (Provider.of<ParticipantInformation>(context, listen: false).currentParticipant?.getFeature() == "A" && Provider.of<TaskTracker>(context, listen: false).isFeatureVisible);
}

bool detailedErrorMessages(BuildContext context) {
  return (Provider.of<ParticipantInformation>(context, listen: false).currentParticipant?.getFeature() == "B" && Provider.of<TaskTracker>(context, listen: false).isFeatureVisible);
}

bool altColours(BuildContext context) {
  return (Provider.of<ParticipantInformation>(context, listen: false).currentParticipant?.getFeature() == "C" && Provider.of<TaskTracker>(context, listen: false).isFeatureVisible);
}

bool redBorder(BuildContext context) {
  return (Provider.of<ParticipantInformation>(context, listen: false).currentParticipant?.getFeature() == "D" && Provider.of<TaskTracker>(context, listen: false).isFeatureVisible);
}

bool greyscaleHighlight(BuildContext context) {
  return (Provider.of<ParticipantInformation>(context, listen: false).currentParticipant?.getFeature() == "E" && Provider.of<TaskTracker>(context, listen: false).isFeatureVisible);
}
