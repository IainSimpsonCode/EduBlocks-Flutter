import 'package:edublocks_flutter/features.dart';
import 'package:edublocks_flutter/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TextFormatter {
  /// Returns the main command from a body of code <br>
  /// E.g. print("count") => print <br>
  /// E.g. while True: => while
  static String getCentralCommand(String line) {

    // Ignore any leading whitespace
    String trimmed = line.trimLeft();

    // List of characters that can denote the end of a command
    const stopCharacters = ["!", "(", ")", " ", '"', "'", ".", ":"];

    // Check each character to see if it matches the stop character
    for (int i = 0; i < trimmed.length; i++) {
      if (stopCharacters.contains(trimmed[i])) {
        // If a stop character is found, return the string
        return trimmed.substring(0, i);
      }
    }

    // If no stop character found, return the original string
    return trimmed;
  }

  static List<TextSpan> formatCodeLine(BuildContext context, String line, Color mainCommandColour) {

    List<TextSpan> textSpans = [];

    // Variable Explaination
    // Example input "    print("count")"
    // trimmedLine = "print("count")"
    // mainCommand = "print"
    // remainingCharacters = "("count")"

    // Check if the line is a comment before doing any other checks
    if (getCentralCommand(line) == "#") {
      textSpans.add(TextSpan(
        text: line,
        style: codeTextStyle
      ));

      return textSpans;
    }



    // Format the rest of the line after the main command
    /// Style Guide:
    /// True/False = Orange
    /// Parethasis and Colon = white
    /// Variables, Library Names and Keywords = red
    /// Text between speech marks = green
    /// Numbers = amber
    final mainCommand = getCentralCommand(line);

    final boolColour = Color(0xFFd19a66);
    final operandsColor = Color(0xFF56b6c2);
    final syntaxColor = Colors.white;
    final keywordColour = Color(0xFFe06c75);
    final stringColour = altColours(context) ? Colors.white : Colors.green;
    final numberColour = Color(0xFFe5c07b);
    final inputColour = Color(0xFFf59421);
    final appendColour = Color(0xFF15b9d3);
    final variableColour = altColours(context) ? Color(0xFF364fd7) : keywordColour;

    final keywords = ["time", "random", "math", "sleep"];
    final variables = ["count", "age", "friends", "number1", "number2"];

    final String keywordPattern = keywords.map(RegExp.escape).join('|');
    final String variablePattern = variables.map(RegExp.escape).join('|');

    final RegExp regex = RegExp(r'''(?<space>\s+|^\s+)|(?<keyword>\b(?:''' + keywordPattern + r''')\b)|(?<variables>\b(?:''' + variablePattern + r''')\b)|(?<input>\binput\b|\bint\b)|(?<append>\bappend\b)|(?<mainCommand>\b''' + mainCommand + r'''\b)|(?<string>["'](?:\\.|[^\\])*?["'])|(?<comment>#.*$)|(?<bool>\bTrue\b|\bFalse\b)|(?<number>\b\d+(?:\.\d+)?\b)|(?<syntax>[()\[\]:,\.])|(?<operands>[+=<>\-])|(?<word>\b\w+\b)
    ''', multiLine: true, caseSensitive: false, dotAll: true);

    final matches = regex.allMatches(line);

    for (final match in matches) {
      final String text = match[0]!;
      TextStyle style = codeTextStyle;

      if (match.namedGroup('mainCommand') != null) {
        style = codeTextStyle.copyWith(color: mainCommandColour);
      } else if (match.namedGroup('input') != null) {
        style = codeTextStyle.copyWith(color: inputColour);
      } else if (match.namedGroup('append') != null) {
        style = codeTextStyle.copyWith(color: appendColour);
      } else if (match.namedGroup('variables') != null) {
        style = codeTextStyle.copyWith(color: variableColour);
      } else if (match.namedGroup('string') != null) {
        style = codeTextStyle.copyWith(color: stringColour);
      } else if (match.namedGroup('comment') != null) {
        style = codeTextStyle.copyWith(color: codeTextColour);
      } else if (match.namedGroup('bool') != null) {
        style = codeTextStyle.copyWith(color: boolColour);
      } else if (match.namedGroup('keyword') != null) {
        style = codeTextStyle.copyWith(color: keywordColour);
      } else if (match.namedGroup('number') != null) {
        style = codeTextStyle.copyWith(color: numberColour);
      } else if (match.namedGroup('syntax') != null) {
        style = codeTextStyle.copyWith(color: syntaxColor);
      } else if (match.namedGroup('operands') != null) {
        style = codeTextStyle.copyWith(color: operandsColor);
      } else if (match.namedGroup('word') != null) {
        style = codeTextStyle.copyWith(color: keywordColour);
      }

      textSpans.add(TextSpan(text: text, style: style));
    }

    return textSpans;
  }
}