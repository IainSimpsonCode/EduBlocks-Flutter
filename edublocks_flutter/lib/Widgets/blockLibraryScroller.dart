import 'package:edublocks_flutter/Services/providers.dart';
import 'package:edublocks_flutter/style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class blockLibraryScroller extends StatefulWidget {
  const blockLibraryScroller({super.key, this.category});

  final String? category;

  @override
  State<blockLibraryScroller> createState() => _blockLibraryScrollerState();
}

class _blockLibraryScrollerState extends State<blockLibraryScroller> {
  final Map<int, bool> _isHovering = {};

  @override
  Widget build(BuildContext context) {
    final blocks = Provider.of<BlockLibrary>(
      context,
      listen: false,
    ).getBlocksByCategoryAndTask(widget.category, context);

    return ListView.builder(
      
      itemCount: blocks.length,
      itemBuilder: (context, index) {
        final block = blocks[index];
        final isHovered = _isHovering[index] ?? false;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovering[index] = true),
            onExit: (_) => setState(() => _isHovering[index] = false),
            child: GestureDetector(
              onTap: () {
                Provider.of<BlocksToLoad>(
                  context,
                  listen: false,
                ).AddBlockToLoad(block);
              },
              child: AnimatedScale(
                scale: isHovered ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 250),
                child: Image.asset(
                  block.displayImageName,
                  height: block.displayImageHeight,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image, size: 80);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
