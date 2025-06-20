import 'dart:convert';
import 'package:edublocks_flutter/Classes/Category.dart';
import 'package:edublocks_flutter/Classes/Participant.dart';
import 'package:edublocks_flutter/Services/providers.dart';
import 'package:edublocks_flutter/Views/codeScreen.dart';
import 'package:edublocks_flutter/Views/loadingScreen.dart';
import 'package:edublocks_flutter/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Services/firebase_options.dart';

void main() async {

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    // Declare all event handlers
    MultiProvider(
      providers: [
        // BlockLibrary ChangeNotifier handles data relating to the blocks available from the block library fo users to use.
        ChangeNotifierProvider(create: (context) => BlockLibrary()),

        // CodeTracker tracks the code currently on the screen and the connection between blocks.
        ChangeNotifierProvider(create: (context) => CodeTracker()),

        // BlocksToLoad manages the queue of blocks being loaded from the block library on the left of the screen.
        ChangeNotifierProvider(create: (context) => BlocksToLoad()),

        // Tracks whether the code panel or output panel is displays. Facilitates communication within the codeBar widget.
        ChangeNotifierProvider(create: (context) => CodeOutputTextPanelNotifier()),

        // Tracks which user is logged into the app
        ChangeNotifierProvider(create: (context) => ParticipantInformation()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: !isProduction,
      home: Scaffold(
        body: loadingScreen()
      ),
    );
  }
}
