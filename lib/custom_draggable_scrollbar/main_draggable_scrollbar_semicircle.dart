// import 'package:custom_scrollbar/custom_draggable_scrollbar/extended_draggable_scrollbar_semicircle.dart';
import 'package:custom_scrollbar/custom_draggable_scrollbar/custom_draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

void main() {
  runApp(const DraggableScrollBarDemo());
}

class DraggableScrollBarDemo extends StatelessWidget {
  const DraggableScrollBarDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Draggable Scroll Bar Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ItemScrollController itemScrollController = ItemScrollController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Draggable Scrollbar with List'),
      ),
      body: SemicircleDemo(controller: itemScrollController),
    );
  }
}

class SemicircleDemo extends StatefulWidget {
  final ItemScrollController controller;
  static int numItems = 1000;
  final bool showDragScroll = true;

  const SemicircleDemo({
    super.key,
    required this.controller,
  });

  @override
  SemicircleDemoState createState() => SemicircleDemoState();
}

class SemicircleDemoState extends State<SemicircleDemo> {
  bool _scrolling = false;

  // Create an ItemPositionsListener to track the positions of the items
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();

  // Determines if drag scrolling should be active based on item count
  bool get useDragScrolling => widget.showDragScroll && SemicircleDemo.numItems >= 20;

  // Handles scroll activity and visibility of the scroll thumb
  void dragScrolling(bool active) {
    if (active != _scrolling) {
      setState(() {
        _scrolling = active;
      });
    }
  }

  // Simplified label builder showing the current item index
  Text _labelBuilder(int pos) {
    return Text(
      "Item $pos",
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        overflow: TextOverflow.visible,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollbar.semicircle(
      alwaysVisibleScrollThumb: true,
      scrollStateListener: dragScrolling,
      labelTextBuilder: _labelBuilder,
      controller: widget.controller,
      itemPositionsListener: _itemPositionsListener, // Add this listener
      labelConstraints: const BoxConstraints.tightFor(width: 80.0, height: 30.0),
      onDragInProcessChanged: (bool value) {},
      child: ScrollablePositionedList.builder(
        itemScrollController: widget.controller,
        itemPositionsListener: _itemPositionsListener, // Add here as well
        itemCount: SemicircleDemo.numItems,
        itemBuilder: (context, index) {
          return RepaintBoundary(
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(2.0),
              color: Colors.grey[300],
              height: 100, // Set item height to differentiate from Grid
              child: Text("Item $index"), // Simple text for each item
            ),
          );
        },
      ),
    );
  }
}
