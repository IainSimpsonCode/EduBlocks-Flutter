import 'package:edublocks_flutter/Services/providers.dart';
import 'package:edublocks_flutter/style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class blockLibraryScroller extends StatefulWidget {
  const blockLibraryScroller({super.key});

  @override
  State<blockLibraryScroller> createState() => _blockLibraryScrollerState();
}

class _blockLibraryScrollerState extends State<blockLibraryScroller> {

  @override
  Widget build(BuildContext context) {

    final blocks = Provider.of<BlockLibrary>(context, listen: false).blocks;

    return ListView.builder(
      itemCount: blocks.length,
      itemBuilder: (context, index) {
        final block = blocks[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            block.imageName,
            height: 80,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.broken_image, size: 80);
            },
          )
        );
      },
    );
    
  }
}