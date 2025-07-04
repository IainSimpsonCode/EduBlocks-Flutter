import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Size of each page section on screen
// Size calculated as ```MediaQuery.sizeOf(context).width / sideBarWidth;```
const sideBarWidth = 3; //was 3
const canvasWidth = 1;
const codeBarWidth = 3.25; //was 3

// Colour of page sections
const sideBarColour = Color(0xffffffff);
const canvasColour = Color(0xffe5e7eb);
const codeBarColour = Color(0xffffffff);
const codeTextPanelColour = Color(0xFF282c34);
const codeTextColour = Color(0xFF7d8799);
const codeOutputColour = Color(0xffffffff);
const buttonGreyColour = Color(0xFFf3f4f6);
const buttonTextColour = Color(0xFF6b7290);
const buttonTextSelectedColour = Color(0xFF374151);
const runButtonColour = Color(0xFF0ea5e9);
const topBarColour = Color(0xFFffffff);
const blockHighlightColour = Colors.amber;
final loginPageColour = Colors.grey[300];

// Text Styles
final bodyMedium = GoogleFonts.roboto(
  fontSize: 14,
  fontWeight: FontWeight.w500,
);

final codeTextStyle = GoogleFonts.firaCode(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: codeTextColour
);