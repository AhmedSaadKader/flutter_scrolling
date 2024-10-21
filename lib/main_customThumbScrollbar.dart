import 'package:flutter/material.dart';
import 'package:custom_scrollbar/customrawscrollbar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Custom Scrollbar Example')),
        body: const ScrollbarDemo(),
      ),
    );
  }
}

class ScrollbarDemo extends StatefulWidget {
  const ScrollbarDemo({super.key});

  @override
  State<ScrollbarDemo> createState() => _ScrollbarDemoState();
}

class _ScrollbarDemoState extends State<ScrollbarDemo> {
  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Native RawScrollbar or CustomScrollbar
        CustomThumbScrollbar(
          controller: _controller,
          thumbColor: Colors.blueAccent,
          radius: const Radius.circular(10),
          thickness: 8.0,
          child: _buildGridView(),
          labelTextBuilder: (offset) {
            final int currentItem = _getCurrentItem(offset);
            return '$currentItem'; // Must return a string for labelTextBuilder
          },
        ),
      ],
    );
  }

  // Build the grid view
  GridView _buildGridView() {
    return GridView.builder(
      controller: _controller,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: 1000,
      itemBuilder: (context, index) {
        return Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.all(2.0),
          color: Colors.grey[300],
        );
      },
    );
  }

  // Calculate the current item based on offset
  int _getCurrentItem(double offset) {
    if (!_controller.hasClients) return 0;
    final double maxScrollExtent = _controller.position.maxScrollExtent;
    final int totalItems = 1000; // Total item count
    return (offset / maxScrollExtent * totalItems).floor();
  }
}
