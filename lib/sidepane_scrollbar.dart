import 'package:flutter/material.dart';

class ScrollbarWithOverlayMenu extends StatefulWidget {
  final List<String> categories;

  const ScrollbarWithOverlayMenu({
    Key? key,
    required this.categories,
  }) : super(key: key);

  @override
  _ScrollbarWithOverlayMenuState createState() => _ScrollbarWithOverlayMenuState();
}

class _ScrollbarWithOverlayMenuState extends State<ScrollbarWithOverlayMenu> {
  late ScrollController _mainController;
  late ScrollController _menuController;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _mainController = ScrollController();
    _menuController = ScrollController();
    _mainController.addListener(_syncScrollControllers);
  }

  @override
  void dispose() {
    _mainController.removeListener(_syncScrollControllers);
    _mainController.dispose();
    _menuController.dispose();
    super.dispose();
  }

  void _syncScrollControllers() {
    if (!_menuController.hasClients || !_mainController.hasClients) return;
    if (_menuController.position.maxScrollExtent > 0) {
      _menuController.jumpTo(_mainController.position.pixels *
          _menuController.position.maxScrollExtent /
          _mainController.position.maxScrollExtent);
    }
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          // Main ScrollView with Scrollbar
          RawScrollbar(
            controller: _mainController,
            thumbVisibility: true,
            thickness: 20.0,
            radius: const Radius.circular(10),
            thumbColor: Colors.grey.withOpacity(0.5),
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: CustomScrollView(
                controller: _mainController,
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Container(
                          height: 150, // Example height
                          color: Colors.blueGrey[(index % 9 + 1) * 100],
                          child: Center(child: Text('Item $index')),
                        );
                      },
                      childCount: 20, // Example item count
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Gesture detector for the scrollbar
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 20.0, // Same as scrollbar thickness
            child: GestureDetector(
              onTap: _toggleMenu,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          // Side overlay menu
          if (_isMenuOpen)
            Positioned(
              right: 20.0, // Position next to the scrollbar
              top: 0,
              bottom: 0,
              width: MediaQuery.of(context).size.width * 0.3, // Adjust width as needed
              child: Container(
                height: constraints.maxHeight,
                color: Colors.black.withOpacity(0.7),
                child: RawScrollbar(
                  controller: _menuController,
                  thumbVisibility: true,
                  thickness: 20.0,
                  radius: const Radius.circular(10),
                  thumbColor: Colors.grey.withOpacity(0.5),
                  child: ListView.builder(
                    controller: _menuController,
                    itemCount: widget.categories.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          widget.categories[index],
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.end,
                        ),
                        onTap: () => _scrollToCategory(index),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }

  void _scrollToCategory(int index) {
    double targetScrollOffset = index * 150.0; // Adjust based on your item height
    _mainController.animateTo(
      targetScrollOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
