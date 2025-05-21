import 'package:edublocks_flutter/style.dart';
import 'package:flutter/material.dart';

Widget printBlock(String message, {int indent = 0}) {
  return Padding(
    padding: EdgeInsets.only(left: 20.0 * indent, top: 8.0),
    child: Container(
      decoration: BoxDecoration(
        color: Color(0xFF4CAF50), // green like "print" block
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 16, color: Colors.white),
          children: [
            TextSpan(text: 'print('),
            TextSpan(
              text: '"$message"',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: ')'),
          ],
        ),
      ),
    ),
  );
}


class canvasWidget extends StatefulWidget {
  const canvasWidget({super.key});

  @override
  State<canvasWidget> createState() => _canvasWidgetState();
}

class _canvasWidgetState extends State<canvasWidget> {

  @override
  Widget build(BuildContext context) {
    return Expanded( child: Container(
      height: MediaQuery.sizeOf(context).height,
      //width: MediaQuery.sizeOf(context).width / canvasWidth,
      color: canvasColour,
      child: ListView(
        children: [
          printBlock("Hello World")
        ],
      ),
    ));
  }
}