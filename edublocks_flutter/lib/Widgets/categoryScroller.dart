import 'package:edublocks_flutter/Services/providers.dart';
import 'package:edublocks_flutter/style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class categoryScroller extends StatefulWidget {
  const categoryScroller({super.key});

  @override
  State<categoryScroller> createState() => _categoryScrollerState();
}

class _categoryScrollerState extends State<categoryScroller> {

  @override
  Widget build(BuildContext context) {

    final categories = Provider.of<BlockLibrary>(context).categories;

    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {

        final category = categories[index];

        // return Card(
        //   margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        //   child: ListTile(
        //     leading: Container(
        //       width: 40,
        //       height: 40,
        //       decoration: BoxDecoration(
        //         color: category.color,
        //         borderRadius: BorderRadius.circular(8),
        //       ),
        //       padding: const EdgeInsets.all(6), // optional padding inside container
        //       child: SvgPicture.asset(
        //         'category_icons/${category.iconName}.svg', // Use the field that stores icon filename or name
        //         color: Colors.white, // tint SVG white if possible
        //         fit: BoxFit.contain,
        //         errorBuilder: (context, error, stackTrace) {
        //           return const Icon(Icons.broken_image, size: 80);
        //         },
        //       ),
        //     ),
        //     title: Text(
        //       category.category,
        //       style: GoogleFonts.roboto(
        //         fontSize: 14,
        //         fontWeight: FontWeight.w400,
        //       ),
        //     ),
        //   ),
        // );
        return ListTile(
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: category.color,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(6), // optional padding inside container
            margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: SvgPicture.asset(
              'category_icons/${category.iconName}.svg', // Use the field that stores icon filename or name
              color: Colors.white, // tint SVG white if possible
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.broken_image, size: 80);
              },
            ),
          ),
          title: Text(
            category.category,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      },
    );
    
  }
}