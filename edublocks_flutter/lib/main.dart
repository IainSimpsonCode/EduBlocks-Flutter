import 'dart:convert';
import 'package:edublocks_flutter/Classes/Category.dart';
import 'package:edublocks_flutter/Services/providers.dart';
import 'package:edublocks_flutter/Views/codeScreen.dart';
import 'package:edublocks_flutter/Views/loadingScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() async {

  runApp(
    // Declare all event handlers
    MultiProvider(
      providers: [
        //// PageNotifier handles which page is displayed currently
        //ChangeNotifierProvider(create: (context) => PageNotifier()),

        // BlockLibrary ChangeNotifier handles data relating to the blovk available from the block library fo users to use.
        ChangeNotifierProvider(create: (context) => BlockLibrary())
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
      home: Scaffold(
        body: loadingScreen()
      ),
    );
  }
}
