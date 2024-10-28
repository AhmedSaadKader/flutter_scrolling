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
    Key? key,
    required this.categories,
    required this.itemPositionsListener,
    required this.itemCount,
    this.isVisible = false,
    this.onCategoryTap,
  }) : super(key: key);

  @override
  _CategoryListWithScrollState createState() => _CategoryListWithScrollState();
}

class _CategoryListWithScrollState extends State<CategoryListWithScroll> {
  int _activeCategory = 0;

  @override
  void initState() {
    super.initState();
    widget.itemPositionsListener.itemPositions.addListener(_updateActiveCategory);
  }

  @override
  void dispose() {
    widget.itemPositionsListener.itemPositions.removeListener(_updateActiveCategory);
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
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return Container(
      width: 100,
      color: Colors.grey[200],
      child: ListView.builder(
        itemCount: widget.categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => widget.onCategoryTap?.call(index),
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
