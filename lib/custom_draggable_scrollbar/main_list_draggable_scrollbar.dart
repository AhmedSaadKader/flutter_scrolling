import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'custom_draggable_scrollbar.dart';
import 'list_draggable_scrollbar.dart';

void main() {
  runApp(const DraggableScrollBarDemo());
}

class DraggableScrollBarDemo extends StatelessWidget {
  const DraggableScrollBarDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'List Draggable Scroll Bar Demo',
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
    final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

    return Scaffold(
      appBar: AppBar(
        title: const Text('List Draggable Scrollbar with List'),
      ),
      body: SemicircleDemo(
        controller: itemScrollController,
        itemPositionsListener: itemPositionsListener,
        categories: List.generate(20, (index) => "Category ${index + 1}"),
      ),
    );
  }
}

class SemicircleDemo extends StatefulWidget {
  final ItemScrollController controller;
  final ItemPositionsListener itemPositionsListener;
  final List<String> categories;
  static int numItems = 1000;

  const SemicircleDemo({
    super.key,
    required this.controller,
    required this.itemPositionsListener,
    required this.categories,
  });

  @override
  SemicircleDemoState createState() => SemicircleDemoState();
}

class SemicircleDemoState extends State<SemicircleDemo> {
  bool _scrolling = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CategoryListWithScroll(
          categories: widget.categories,
          itemPositionsListener: widget.itemPositionsListener,
          itemCount: SemicircleDemo.numItems,
          isVisible: _scrolling,
        ),
        Expanded(
          child: DraggableScrollbar.semicircle(
            alwaysVisibleScrollThumb: true,
            scrollStateListener: (scrolling) {
              setState(() => _scrolling = scrolling);
            },
            labelTextBuilder: (pos) {
              int itemsPerCategory = SemicircleDemo.numItems ~/ widget.categories.length;
              int categoryIndex = pos ~/ itemsPerCategory;
              return Text(
                widget.categories[categoryIndex],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.visible,
                ),
              );
            },
            controller: widget.controller,
            itemPositionsListener: widget.itemPositionsListener,
            labelConstraints: const BoxConstraints.tightFor(width: 80.0, height: 30.0),
            child: ScrollablePositionedList.builder(
              itemScrollController: widget.controller,
              itemPositionsListener: widget.itemPositionsListener,
              itemCount: SemicircleDemo.numItems,
              itemBuilder: (context, index) {
                return RepaintBoundary(
                  child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.all(2.0),
                    color: Colors.grey[300],
                    height: 100,
                    child: Text("Item $index"),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
