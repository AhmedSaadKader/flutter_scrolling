import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

/// A custom widget that displays a list of categories and highlights
/// the active category based on the current scroll position.
class CategoryListWithScroll extends StatefulWidget {
  final List<String> categories;
  final ItemPositionsListener itemPositionsListener;
  final int itemCount;
  final bool isVisible;

  /// Callback when a category is selected.
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
    if (positions.isNotEmpty) {
      int firstVisibleIndex = positions
          .where((ItemPosition position) => position.itemLeadingEdge >= 0)
          .map((e) => e.index)
          .reduce((value, element) => element < value ? element : value);

      setState(() {
        int itemsPerCategory = widget.itemCount ~/ widget.categories.length;
        _activeCategory = firstVisibleIndex ~/ itemsPerCategory;
      });

      // Scroll the categories list to keep the active category visible.
      if (_categoryScrollController.hasClients) {
        _categoryScrollController.animateTo(
          _activeCategory * 40.0, // Assuming each category item has a height of 50.0
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return Container(
      width: 100,
      color: Colors.grey[200],
      child: ListView.builder(
        controller: _categoryScrollController, // Attach the ScrollController here
        itemCount: widget.categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              widget.onCategoryTap?.call(index);
              setState(() {
                _activeCategory = index;
              });
              // Scroll to the corresponding main list item
              int itemsPerCategory = widget.itemCount ~/ widget.categories.length;
              int targetIndex = index * itemsPerCategory;
              widget.itemPositionsListener.itemPositions
                  .removeListener(_updateActiveCategory); // Temporarily remove listener to avoid feedback loop
              widget.itemPositionsListener.itemPositions.addListener(() {
                widget.itemPositionsListener.itemPositions
                    .removeListener(_updateActiveCategory); // Re-attach listener after jump completes
              });
            },
            child: Container(
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
