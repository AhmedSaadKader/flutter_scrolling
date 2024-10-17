import 'package:flutter/material.dart';

class AdvancedScrollbarExample extends StatefulWidget {
  @override
  _AdvancedScrollbarExampleState createState() => _AdvancedScrollbarExampleState();
}

class _AdvancedScrollbarExampleState extends State<AdvancedScrollbarExample> {
  final ScrollController _scrollController = ScrollController();
  final List<String> items = List.generate(50, (index) => 'Item ${index + 1}');
  int _currentIndex = 0;
  bool _isScrollbarActive = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    int index = (_scrollController.offset / 50).floor();
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Advanced Scrollbar Example')),
      body: Stack(
        children: [
          GestureDetector(
            onPanDown: (_) => setState(() => _isScrollbarActive = true),
            onPanEnd: (_) => Future.delayed(
              Duration(seconds: 2),
              () => setState(() => _isScrollbarActive = false),
            ),
            child: RawScrollbar(
              controller: _scrollController,
              thumbColor: Colors.grey.withOpacity(0.5),
              radius: Radius.circular(20),
              thickness: 6,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(items[index]),
                    tileColor: index == _currentIndex ? Colors.blue.withOpacity(0.3) : null,
                  );
                },
              ),
            ),
          ),
          if (_isScrollbarActive)
            Positioned(
              right: 20,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: 100,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                  ),
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(items[index], style: TextStyle(fontSize: 12)),
                        onTap: () {
                          _scrollController.animateTo(
                            index * 50.0,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }
}

void main() {
  runApp(MaterialApp(home: AdvancedScrollbarExample()));
}
