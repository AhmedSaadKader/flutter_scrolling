import 'package:custom_scrollbar/sidepane_scrollbar.dart';
import 'package:flutter/material.dart';
import 'scrollbar_with_category_menu.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Category Scroll Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CategoryScrollPage(),
    );
  }
}

class CategoryScrollPage extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();
  final List<String> _categories = List.generate(20, (index) => 'Category $index');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scrollable Category Menu'),
      ),
      body: ScrollbarWithOverlayMenu(
        categories: _categories,
      ),
    );
  }
}
