// Additional Features
import 'package:edublocks_flutter/Services/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const bool isProduction = true;       // Is the code in production or debug mode
const bool requireLogin = true;       // Should the app load a login screen on start, or go straight to the codeScreen
const bool showPIDonLogin = false;    // Should the app show the participant ID on screen after login in large font
const bool doExtentionTasks = false;  // Should the app load extention tasks after the main task, or just move straight to the next task
const bool showEmptyCategories = false; // Should the app show empty categories

const String supervisorCode = "1450"; // Code required to allow users to finish thier tasks early without figuring out the answer.

/// Feature A
bool lineNumbering(BuildContext context) {
  return (
    Provider.of<ParticipantInformation>(context, listen: false).currentParticipant?.getFeature() == "A" 
  );
}

/// Feature B
bool detailedErrorMessages(BuildContext context) {
  return (
    Provider.of<ParticipantInformation>(context, listen: false).currentParticipant?.getFeature() == "B" && 
    (Provider.of<ParticipantInformation>(context, listen: false).currentParticipant?.currentProgress ?? 0) >= 1 && 
    Provider.of<ParticipantInformation>(context, listen: false).currentParticipant?.getCodeUpToFirstError() == Provider.of<CodeTracker>(context, listen: false).JSONToPythonCode()
  );
}

/// Feature C
bool altColours(BuildContext context) {
  return (
    Provider.of<ParticipantInformation>(context, listen: false).currentParticipant?.getFeature() == "C"
  );
}

/// Feature D
bool redBorder(BuildContext context) {
  return (
    Provider.of<ParticipantInformation>(context, listen: false).currentParticipant?.getFeature() == "D" && 
    (Provider.of<ParticipantInformation>(context, listen: false).currentParticipant?.currentProgress ?? 0) >= 1 &&
    Provider.of<ParticipantInformation>(context, listen: false).currentParticipant?.getCodeUpToFirstError() == Provider.of<CodeTracker>(context, listen: false).JSONToPythonCode()
  );
}

/// Feature E
bool greyscaleHighlight(BuildContext context) {
  return (
    Provider.of<ParticipantInformation>(context, listen: false).currentParticipant?.getFeature() == "E" && 
    (Provider.of<ParticipantInformation>(context, listen: false).currentParticipant?.currentProgress ?? 0) >= 1 && 
    Provider.of<ParticipantInformation>(context, listen: false).currentParticipant?.getCodeUpToFirstError() == Provider.of<CodeTracker>(context, listen: false).JSONToPythonCode()
  );
}

/// Feature F
bool showCodeAndOutputSimultaniously(BuildContext context) {
  return (
    Provider.of<ParticipantInformation>(context, listen: false).currentParticipant?.getFeature() == "F"
  );
}

/// Feature G
bool highlightCodePanelGreen(BuildContext context) {
  return (
    Provider.of<ParticipantInformation>(context, listen: false).currentParticipant?.getFeature() == "G"
  );
}