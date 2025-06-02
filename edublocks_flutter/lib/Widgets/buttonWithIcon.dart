import 'package:edublocks_flutter/Services/providers.dart';
import 'package:edublocks_flutter/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class buttonWithIcon extends StatefulWidget {
  const buttonWithIcon({super.key, this.icon, this.svgIconLocation, this.iconColor, required this.backgroundColor, required this.text, required this.onTap});

  final Icons? icon;
  final String? svgIconLocation;
  final Color? iconColor;
  final Color backgroundColor;
  final Text text;
  final Function(void) onTap;

  @override
  State<buttonWithIcon> createState() => _buttonWithIconState();
}

class _buttonWithIconState extends State<buttonWithIcon> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(8))
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
          child: Row(
            spacing: 16,
            children: [
              // SvgPicture.asset(
              //   'category_icons/play.svg', 
              //   color: Colors.white,
              //   fit: BoxFit.contain,
              //   width: 14,
              //   errorBuilder: (context, error, stackTrace) {
              //     return const Icon(Icons.broken_image, size: 20);
              //   },
              // ),
              // Text(
              //   "Run",
              //   style: bodyMedium.copyWith(color: Colors.white),
              // ),
              // widget.svgIconLocation != null ? SvgPicture.asset(
              //   widget.svgIconLocation!, 
              //   color: widget.iconColor ?? Colors.white,
              //   fit: BoxFit.contain,
              //   width: 14,
              //   errorBuilder: (context, error, stackTrace) {
              //     return const Icon(Icons.broken_image, size: 14);
              //   },
              // ) : ,
              widget.text,
            ],
          ),
        ),
      ),
      onTap: () {

      }
    );
  }
}