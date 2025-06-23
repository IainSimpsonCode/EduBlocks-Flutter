import 'dart:convert';
import 'package:edublocks_flutter/Classes/Block.dart';
import 'package:edublocks_flutter/Classes/Category.dart';
import 'package:edublocks_flutter/Views/codeScreen.dart';
import 'package:edublocks_flutter/Views/loginPage.dart';
import 'package:edublocks_flutter/style.dart';
import 'package:flutter/material.dart';
import 'package:edublocks_flutter/Services/firestore.dart';
import 'package:flutter/services.dart';
import 'package:edublocks_flutter/features.dart';

Future<List<int>> loadAllResources(BuildContext context) async {
  return await Future.wait([
    loadCategories(context),
    loadBlocks(context)
  ]).then((successCodes) async {

    getData();

    List<int> additionalSuccessCodes = [];

    // Ensure the widget is still in the widget tree before accessing context to prevent using a BuildContext after an async gap.
    // If the widget is not mounted, leave unsucessfully.
    if (!context.mounted) {
      additionalSuccessCodes.add(1);
    }
    else {
      additionalSuccessCodes.addAll(await Future.wait([
        assignAlternateColours(context)
      ]));      
    }


    successCodes.addAll(additionalSuccessCodes);
    return successCodes;
  });
}

/// Loads all resources and primes the app, read for use by a user in research.
/// ## Adding something to be loaded
/// If a feature requires something to be loaded when the app starts, wrap the code required to load the required items into an async function,
/// and add the function to the list in ```loadAllResources()```. This will add the function to the queue of items being loaded during this state.
/// Your function should return an integer ```0``` if sucessful. If not sucessful, it should return the appropriate C exit code (e.g. ```1``` for a generic unsucessful operation).
/// ### Future Returns
/// Note: Do **not** expect a return from your function. All returns or any loaded objects should be stored in a variable or a ChangeNotifier
/// outside of the function.
class loadingScreen extends StatelessWidget {
  const loadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<int>>(
      // Load all the resources required for the app
      future: loadAllResources(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While the async functions are running
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          // If something went wrong
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else if (snapshot.hasData) {
          // When all futures complete
          final results = snapshot.data!;

          // ignore: avoid_print
          print(" -- Loading Screen Function Results -- ");
          // ignore: avoid_print
          print(results);

          return requireLogin ? loginPage() : CodeScreen();

        } else {
          return const Scaffold(
            body: Center(child: Text('Unknown state')),
          );
        }
      },
    );
  }

}