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
  int? selectedIndex;

  Widget build(BuildContext context) {
    final categories =
        Provider.of<BlockLibrary>(context, listen: false).categories;
    final _codeTracker = Provider.of<CodeTracker>(context, listen: false);

    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        bool isHovered = false;
        final isSelected = selectedIndex == index;

        return StatefulBuilder(
          builder: (context, setState) {
            return MouseRegion(
              onEnter: (_) => setState(() => isHovered = true),
              onExit: (_) => setState(() => isHovered = false),
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(isHovered || isSelected ? 3.0 : 0.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                    Provider.of<BlockLibrary>(
                      context,
                      listen: false,
                    ).setCategorySelected(category.category);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? category.color.withOpacity(1)
                              : (isHovered ? buttonGreyColour : null),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 32,
                        height: 32,
                        margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
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
                          padding: const EdgeInsets.all(6),
                          child: SvgPicture.asset(
                            'category_icons/${category.iconName}.svg',
                            color: Colors.white,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.broken_image, size: 80);
                            },
                          ),
                        ),
                      ),
                      title: Text(
                        category.category,
                        style: bodyMedium.copyWith(
                          color: isSelected ? Colors.white : buttonTextColour,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
