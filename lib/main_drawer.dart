import 'package:flutter/material.dart';
import 'dart:ui'; // For backdrop filter

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Custom Scrollbar with Drawer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ScrollbarWithRightDrawer(
        controller: ScrollController(),
        categories: List.generate(10, (index) => 'Category $index'),
      ),
    );
  }
}

class ScrollbarWithRightDrawer extends StatefulWidget {
  final ScrollController controller;
  final List<String> categories;

  const ScrollbarWithRightDrawer({Key? key, required this.controller, required this.categories}) : super(key: key);

  @override
  _ScrollbarWithRightDrawerState createState() => _ScrollbarWithRightDrawerState();
}

class _ScrollbarWithRightDrawerState extends State<ScrollbarWithRightDrawer> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDrawerOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Custom Scrollbar Example"),
      ),
      endDrawer: _buildRightDrawer(),
      body: Stack(
        children: [
          // Apply blur effect when drawer is open
          _isDrawerOpen
              ? BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    color: Colors.black.withOpacity(0.3), // Semi-transparent background
                  ),
                )
              : Container(), // No filter when drawer is closed
          CustomScrollView(
            controller: widget.controller,
            slivers: [
              SliverAppBar(
                expandedHeight: 150.0,
                floating: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text('Scrollable Content'),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => ListTile(
                    title: Text('Item $index'),
                  ),
                  childCount: 50,
                ),
              ),
            ],
          ),
          Positioned(
            right: 8.0,
            top: 0.0,
            bottom: 0.0,
            child: GestureDetector(
              onTap: () {
                _toggleDrawer();
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
      ),
    );
  }

  Widget _buildRightDrawer() {
    return Drawer(
      child: ListView.builder(
        itemCount: widget.categories.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(widget.categories[index]),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              _scrollToCategory(index); // Scroll to the selected category
              setState(() {
                _isDrawerOpen = false;
              });
            },
          );
        },
      ),
    );
  }

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
    if (_isDrawerOpen) {
      _scaffoldKey.currentState?.openEndDrawer(); // Use GlobalKey to open drawer
    }
  }

  void _scrollToCategory(int index) {
    double targetScrollOffset = (index * 100.0); // Example scroll position calculation
    widget.controller.animateTo(
      targetScrollOffset,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
