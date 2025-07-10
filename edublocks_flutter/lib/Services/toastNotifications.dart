import 'package:flutter/material.dart';

void showToastWithIcon(BuildContext context, String message, IconData icon, Color iconColor, int seconds, bool center) {
  final overlay = Overlay.of(context);
  final screenSize = MediaQuery.of(context).size;

  // Calculate horizontal padding to center it in the middle third
  final sidePadding = screenSize.width / 3;

  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: 50,
      left: center ? sidePadding : (2 * sidePadding),
      right: center ? sidePadding : 0,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.85),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                  softWrap: true,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(Duration(seconds: seconds)).then((_) => overlayEntry.remove());
}

