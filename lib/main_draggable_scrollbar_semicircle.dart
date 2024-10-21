import 'package:custom_scrollbar/extended_draggable_scrollbar_semicircle.dart';
// import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const DraggableScrollBarDemo(
    title: 'Draggable Scroll Bar Demo',
  ));
}

class DraggableScrollBarDemo extends StatelessWidget {
  final String title;

  const DraggableScrollBarDemo({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      home: MyHomePage(title: title),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final ScrollController _semicircleController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SemicircleDemo(controller: _semicircleController),
    );
  }
}

class SemicircleDemo extends StatelessWidget {
  static int numItems = 1000;

  final ScrollController controller;

  const SemicircleDemo({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollbar.semicircle(
      alwaysVisibleScrollThumb: true,
      labelTextBuilder: (offset) {
        final int currentItem =
            controller.hasClients ? (controller.offset / controller.position.maxScrollExtent * numItems).floor() : 0;

        return Text("$currentItem");
      },
      labelConstraints: const BoxConstraints.tightFor(width: 80.0, height: 30.0),
      controller: controller,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        controller: controller,
        padding: EdgeInsets.zero,
        itemCount: numItems,
        itemBuilder: (context, index) {
          return RepaintBoundary(
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(2.0),
              color: Colors.grey[300],
            ),
          );
        },
      ),
    );
  }
}
