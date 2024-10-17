import 'package:flutter/material.dart';

class ScrollbarWithCategoryMenu extends StatefulWidget {
  final ScrollController controller;
  final List<String> categories;

  const ScrollbarWithCategoryMenu({Key? key, required this.controller, required this.categories}) : super(key: key);

  @override
  _ScrollbarWithCategoryMenuState createState() => _ScrollbarWithCategoryMenuState();
}

class _ScrollbarWithCategoryMenuState extends State<ScrollbarWithCategoryMenu> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          controller: widget.controller,
          slivers: [
            // Your slivers go here
          ],
        ),
        Positioned(
          right: 8.0,
          top: 0.0,
          bottom: 0.0,
          child: GestureDetector(
            onTap: () {
              _openCategoryMenu(context);
            },
            child: Container(
              width: 20,
              color: Colors.grey.withOpacity(0.5),
              child: Align(
                alignment: Alignment.center,
                child: Icon(Icons.menu, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openCategoryMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: widget.categories.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(widget.categories[index]),
              onTap: () {
                // Navigate to the selected category
                Navigator.pop(context); // Close the modal
                _scrollToCategory(index); // Scroll to the selected category
              },
            );
          },
        );
      },
    );
  }

  void _scrollToCategory(int index) {
    // Adjust the scroll behavior based on your category and section layout
    double targetScrollOffset = (index * 100.0); // Assuming each section is 100px tall
    widget.controller.animateTo(
      targetScrollOffset,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
