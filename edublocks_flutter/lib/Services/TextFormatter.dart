import 'package:flutter/widgets.dart';

class TextFormatter {
  /// Returns the main command from a body of code <br>
  /// E.g. print("count") => print <br>
  /// E.g. while True: => while
  static String getCentralCommand(String line) {
    // List of characters that can denote the end of a command
    const stopCharacters = ["!", "(", ")", " ", '"', "'"];

    // Check each character to see if it matches the stop character
    for (int i = 0; i < line.length; i++) {
      if (stopCharacters.contains(line[i])) {
        // If a stop character is found, return the string
        return line.substring(0, i);
      }
    }

    // If no stop character found, return the original string
    return line;
  }

  static Widget? formatCodeLine(String line) {
    final mainCommand = getCentralCommand(line);

    final remainingLine = line.substring(mainCommand.length);

    return null;
  }

  static List<Widget> formatCode(List<String> codeBlock) {
    return [];
  }
}