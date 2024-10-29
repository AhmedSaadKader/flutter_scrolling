import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class CategoryListWithScroll extends StatefulWidget {
  final List<String> categories;
  final ItemPositionsListener itemPositionsListener;
  final int itemCount;
  final bool isVisible;
  final void Function(int index)? onCategoryTap;

  const CategoryListWithScroll({
    super.key,
    required this.categories,
    required this.itemPositionsListener,
    required this.itemCount,
    this.isVisible = false,
    this.onCategoryTap,
  });

  @override
  _CategoryListWithScrollState createState() => _CategoryListWithScrollState();
}

class _CategoryListWithScrollState extends State<CategoryListWithScroll> {
  int _activeCategory = 0;
  final ScrollController _categoryScrollController = ScrollController();

  // Constants for better control
  static const double _itemHeight = 50.0;
  static const Duration _scrollDuration = Duration(milliseconds: 100); // Faster scrolling

  @override
  void initState() {
    super.initState();
    widget.itemPositionsListener.itemPositions.addListener(_updateActiveCategory);
  }

  @override
  void dispose() {
    widget.itemPositionsListener.itemPositions.removeListener(_updateActiveCategory);
    _categoryScrollController.dispose();
    super.dispose();
  }

  void _updateActiveCategory() {
    final positions = widget.itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;

    int firstVisibleIndex = positions
        .where((ItemPosition position) => position.itemLeadingEdge >= 0)
        .map((e) => e.index)
        .reduce((value, element) => element < value ? element : value);

    int itemsPerCategory = widget.itemCount ~/ widget.categories.length;
    int newActiveCategory = firstVisibleIndex ~/ itemsPerCategory;

    if (newActiveCategory != _activeCategory) {
      setState(() {
        _activeCategory = newActiveCategory;
      });
      _scrollToCenter(newActiveCategory);
    }
  }

  void _scrollToCenter(int index) {
    if (!_categoryScrollController.hasClients) return;

    final screenHeight = MediaQuery.of(context).size.height;
    final listViewHeight = screenHeight * 0.8; // Assuming list takes full height
    final itemPosition = index * _itemHeight;

    // Calculate the offset that would center the selected item
    double targetOffset = itemPosition - (listViewHeight / 2) + (_itemHeight / 2);

    // Clamp the offset to valid scroll bounds
    targetOffset = targetOffset.clamp(
      0.0,
      _categoryScrollController.position.maxScrollExtent,
    );

    _categoryScrollController.animateTo(
      targetOffset,
      duration: _scrollDuration,
      curve: Curves.easeOut, // Changed to easeOut for smoother feel
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return Container(
      width: 150,
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        controller: _categoryScrollController,
        itemCount: widget.categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              widget.onCategoryTap?.call(index);
              setState(() {
                _activeCategory = index;
              });
              _scrollToCenter(index);
            },
            child: Container(
              height: _itemHeight,
              color: _activeCategory == index ? Colors.blue : Colors.transparent,
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  widget.categories[index],
                  style: TextStyle(
                    color: _activeCategory == index ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
