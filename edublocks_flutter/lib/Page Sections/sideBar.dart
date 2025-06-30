import 'package:edublocks_flutter/Services/providers.dart';
import 'package:edublocks_flutter/Widgets/blockLibraryScroller.dart';
import 'package:edublocks_flutter/Widgets/categoryScroller.dart';
import 'package:edublocks_flutter/style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class sideBarWidget extends StatefulWidget {
  const sideBarWidget({super.key});

  @override
  State<sideBarWidget> createState() => _sideBarWidgetState();
}

class _sideBarWidgetState extends State<sideBarWidget> {

  bool minimised = true;
  late BlockLibrary _blockLibrary;

  void _handleBlockLibraryUpdates() {
    setState(() {
      
    });
  }

  @override
  void initState() {
    super.initState();

    _blockLibrary = Provider.of<BlockLibrary>(context, listen: false);
    _blockLibrary.addListener(_handleBlockLibraryUpdates);
  }

  @override
  void dispose() {
    // Safely remove provider listener
    _blockLibrary.removeListener(_handleBlockLibraryUpdates);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    String? categorySelected = _blockLibrary.categorySelected;
    minimised = (categorySelected == null);

    // If the sideBar is minimised, it's size should be divided by 2.
    // If the sideBar is not minimised, it should be shown at full size, therefore it's size is divided by 1.
    double sizeMofifier = minimised ? 3 : 1;


    return Container(
      height: MediaQuery.sizeOf(context).height,
      width: MediaQuery.sizeOf(context).width / (sideBarWidth * sizeMofifier),
      color: sideBarColour,

      //child: blockLibraryScroller(),
      //child: categoryScroller(),

      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.sizeOf(context).width / (sideBarWidth * 3),
            child: categoryScroller(),
          ),
          minimised ? SizedBox() : SizedBox(
            width: MediaQuery.sizeOf(context).width / (sideBarWidth * 1) - MediaQuery.sizeOf(context).width / (sideBarWidth * 3),
            child: blockLibraryScroller(category: categorySelected),
          ),
        ],
      )
    );
  }
}