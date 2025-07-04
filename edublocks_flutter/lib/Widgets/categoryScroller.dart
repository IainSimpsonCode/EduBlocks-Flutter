import 'package:edublocks_flutter/Services/providers.dart';
import 'package:edublocks_flutter/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class categoryScroller extends StatefulWidget {
  const categoryScroller({super.key});

  @override
  State<categoryScroller> createState() => _categoryScrollerState();
}

class _categoryScrollerState extends State<categoryScroller> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    final categories =
        Provider.of<BlockLibrary>(context, listen: false).categories;
    final isCategorySelected =
        Provider.of<BlockLibrary>(context).hasCategorySelected();

    return LayoutBuilder(
      // ‹constraints› reflects the width actually allotted to this sidebar.
      builder: (context, constraints) {
        // Reveal text only if there’s enough room for icon + gap + ~90 px of text.
        final bool showText = constraints.maxWidth > 75;
        final double maxWidth = constraints.maxWidth;

        // Shrink icon size at smaller widths
        double iconSize;
        if (maxWidth > 60) {
          iconSize = 32;
        } else if (maxWidth > 25) {
          iconSize = 24;
        } else {
          iconSize = 20;
        }
        return ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final bool isSelected = selectedIndex == index;
            bool isHovered = false;

            return StatefulBuilder(
              builder: (context, setState) {
                return MouseRegion(
                  onEnter: (_) => setState(() => isHovered = true),
                  onExit: (_) => setState(() => isHovered = false),
                  child: AnimatedPadding(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.all(
                      isHovered || (isSelected && isCategorySelected)
                          ? 3.0
                          : 0.0,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => selectedIndex = index);
                        Provider.of<BlockLibrary>(
                          context,
                          listen: false,
                        ).setCategorySelected(category.category);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              isSelected && isCategorySelected
                                  ? category.color
                                  : (isHovered ? buttonGreyColour : null),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildIcon(category, iconSize),
                            if (showText) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  category.category,
                                  overflow: TextOverflow.ellipsis,
                                  style: bodyMedium.copyWith(
                                    color:
                                        isSelected && isCategorySelected
                                            ? Colors.white
                                            : buttonTextColour,
                                    fontWeight:
                                        isSelected && isCategorySelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  /// Builds the coloured square icon for a category.
  Widget _buildIcon(category, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: category.color,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(4),
        child: SvgPicture.asset(
          'app_assets/category_icons/${category.iconName}.svg',
          color: Colors.white,
          fit: BoxFit.contain,
          width: size * 0.6,
          height: size * 0.6,
          errorBuilder:
              (_, __, ___) => Icon(Icons.broken_image, size: size * 0.6),
        ),
      ),
    );
  }
}
