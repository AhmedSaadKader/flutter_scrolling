import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

/// Build the Scroll Thumb and label using the current configuration
typedef ScrollThumbBuilder = Widget Function(
  Color backgroundColor,
  Animation<double> thumbAnimation,
  Animation<double> labelAnimation,
  double height, {
  Text? labelText,
  BoxConstraints? labelConstraints,
});

/// Build a Text widget using the current scroll offset
typedef LabelTextBuilder = Text Function(int item);

/// A widget that will display a BoxScrollView with a ScrollThumb that can be dragged
/// for quick navigation of the BoxScrollView.
class DraggableScrollbar extends StatefulWidget {
  /// The view that will be scrolled with the scroll thumb
  final ScrollablePositionedList child;

  final ItemPositionsListener itemPositionsListener;

  /// The height of the scroll thumb
  final double heightScrollThumb;

  /// The background color of the label and thumb
  final Color backgroundColor;

  /// The amount of padding that should surround the thumb
  final EdgeInsetsGeometry? padding;

  /// The height offset of the thumb/bar from the bottom of the page
  final double? heightOffset;

  /// Determines how quickly the scrollbar will animate in and out
  final Duration scrollbarAnimationDuration;

  /// How long should the thumb be visible before fading out
  final Duration scrollbarTimeToFade;

  /// Build a Text widget from the current offset in the BoxScrollView
  final LabelTextBuilder? labelTextBuilder;

  /// Determines box constraints for Container displaying label
  final BoxConstraints? labelConstraints;

  /// The ScrollController for the BoxScrollView
  final ItemScrollController controller;

  /// Determines scrollThumb displaying. If you draw own ScrollThumb and it is true you just don't need to use animation parameters in [scrollThumbBuilder]
  final bool alwaysVisibleScrollThumb;

  final Function(bool scrolling) scrollStateListener;

  const DraggableScrollbar.semicircle({
    super.key,
    Key? scrollThumbKey,
    this.alwaysVisibleScrollThumb = false,
    required this.child,
    required this.controller,
    required this.itemPositionsListener,
    required this.scrollStateListener,
    this.heightScrollThumb = 48.0,
    this.backgroundColor = Colors.black,
    this.padding,
    this.heightOffset,
    this.scrollbarAnimationDuration = const Duration(milliseconds: 300),
    this.scrollbarTimeToFade = const Duration(milliseconds: 600),
    this.labelTextBuilder,
    this.labelConstraints,
  });

  @override
  DraggableScrollbarState createState() => DraggableScrollbarState();
}

class ScrollLabel extends StatelessWidget {
  final Animation<double>? animation;
  final Color backgroundColor;
  final Text child;

  final BoxConstraints? constraints;
  static const BoxConstraints _defaultConstraints = BoxConstraints.tightFor(width: 72.0, height: 28.0);

  const ScrollLabel({
    super.key,
    required this.child,
    required this.animation,
    required this.backgroundColor,
    this.constraints = _defaultConstraints,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation!,
      child: Container(
        margin: const EdgeInsets.only(right: 12.0),
        child: Material(
          elevation: 4.0,
          color: backgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(16.0)),
          child: Container(
            constraints: constraints ?? _defaultConstraints,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}

class DraggableScrollbarState extends State<DraggableScrollbar> with TickerProviderStateMixin {
  late double _barOffset;
  late bool _isDragInProcess;
  late int _currentItem;

  late AnimationController _thumbAnimationController;
  late Animation<double> _thumbAnimation;
  late AnimationController _labelAnimationController;
  late Animation<double> _labelAnimation;
  Timer? _fadeoutTimer;

  @override
  void initState() {
    super.initState();
    _barOffset = 0.0;
    _isDragInProcess = false;
    _currentItem = 0;

    _thumbAnimationController = AnimationController(
      vsync: this,
      duration: widget.scrollbarAnimationDuration,
    );

    _thumbAnimation = CurvedAnimation(
      parent: _thumbAnimationController,
      curve: Curves.fastOutSlowIn,
    );

    _labelAnimationController = AnimationController(
      vsync: this,
      duration: widget.scrollbarAnimationDuration,
    );

    _labelAnimation = CurvedAnimation(
      parent: _labelAnimationController,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    _thumbAnimationController.dispose();
    _labelAnimationController.dispose();
    _fadeoutTimer?.cancel();
    super.dispose();
  }

  double get barMaxScrollExtent => (context.size?.height ?? 0) - widget.heightScrollThumb - (widget.heightOffset ?? 0);

  double get barMinScrollExtent => 0;

  int get maxItemCount => widget.child.itemCount;

// Helper method to get all three labels
  List<Text?> _getLabels() {
    if (widget.labelTextBuilder == null || !_isDragInProcess) {
      return [null, null, null];
    }

    final prevItem = _currentItem > 0 ? _currentItem - 1 : null;
    final nextItem = _currentItem < maxItemCount - 1 ? _currentItem + 1 : null;

    return [
      prevItem != null ? widget.labelTextBuilder!(prevItem) : null,
      widget.labelTextBuilder!(_currentItem),
      nextItem != null ? widget.labelTextBuilder!(nextItem) : null,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final labels = _getLabels();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            changePosition(notification);
            return false;
          },
          child: Stack(
            children: <Widget>[
              RepaintBoundary(
                child: widget.child,
              ),
              RepaintBoundary(
                child: GestureDetector(
                  onVerticalDragStart: _onVerticalDragStart,
                  onVerticalDragUpdate: _onVerticalDragUpdate,
                  onVerticalDragEnd: _onVerticalDragEnd,
                  child: Container(
                    alignment: Alignment.topRight,
                    margin: EdgeInsets.only(top: _barOffset),
                    padding: widget.padding,
                    child: MultiLabelScrollThumb(
                      backgroundColor: widget.backgroundColor,
                      thumbAnimation: _thumbAnimation,
                      labelAnimation: _labelAnimation,
                      height: widget.heightScrollThumb,
                      prevLabel: labels[0],
                      currentLabel: labels[1],
                      nextLabel: labels[2],
                      labelConstraints: widget.labelConstraints,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // scroll bar has received notification that it's view was scrolled
  // so it should also changes his position
  // but only if it isn't dragged
  changePosition(ScrollNotification notification) {
    if (_isDragInProcess) {
      return;
    }

    setState(() {
      try {
        int firstItemIndex = widget.itemPositionsListener.itemPositions.value.first.index;

        if (notification is ScrollUpdateNotification) {
          _barOffset = (firstItemIndex / maxItemCount) * barMaxScrollExtent;

          if (_barOffset < barMinScrollExtent) {
            _barOffset = barMinScrollExtent;
          }
          if (_barOffset > barMaxScrollExtent) {
            _barOffset = barMaxScrollExtent;
          }
        }

        if (notification is ScrollUpdateNotification || notification is OverscrollNotification) {
          if (_thumbAnimationController.status != AnimationStatus.forward) {
            _thumbAnimationController.forward();
          }

          if (itemPosition < maxItemCount) {
            _currentItem = itemPosition;
          }

          _fadeoutTimer?.cancel();
          _fadeoutTimer = Timer(widget.scrollbarTimeToFade, () {
            _thumbAnimationController.reverse();
            _labelAnimationController.reverse();
            _fadeoutTimer = null;
          });
        }
      } catch (_) {}
    });
  }

  void _onVerticalDragStart(DragStartDetails details) {
    setState(() {
      _isDragInProcess = true;
      _labelAnimationController.forward();
      _fadeoutTimer?.cancel();
    });

    widget.scrollStateListener(true);
  }

  int get itemPosition {
    int numberOfItems = widget.child.itemCount;
    return ((_barOffset / barMaxScrollExtent) * numberOfItems).toInt();
  }

  void _jumpToBarPosition() {
    if (itemPosition > maxItemCount - 1) {
      return;
    }

    _currentItem = itemPosition;

    /// If the bar is at the bottom but the item position is still smaller than the max item count (due to rounding error)
    /// jump to the end of the list
    if (barMaxScrollExtent - _barOffset < 10 && itemPosition < maxItemCount) {
      widget.controller.jumpTo(
        index: maxItemCount,
      );

      return;
    }

    widget.controller.jumpTo(
      index: itemPosition,
    );
  }

  Timer? dragHaltTimer;
  int lastTimerPosition = 0;

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      if (_thumbAnimationController.status != AnimationStatus.forward) {
        _thumbAnimationController.forward();
      }
      if (_isDragInProcess) {
        _barOffset += details.delta.dy;

        if (_barOffset < barMinScrollExtent) {
          _barOffset = barMinScrollExtent;
        }
        if (_barOffset > barMaxScrollExtent) {
          _barOffset = barMaxScrollExtent;
        }

        if (itemPosition != lastTimerPosition) {
          lastTimerPosition = itemPosition;
          dragHaltTimer?.cancel();
          widget.scrollStateListener(true);

          dragHaltTimer = Timer(
            const Duration(milliseconds: 500),
            () {
              widget.scrollStateListener(false);
            },
          );
        }

        _jumpToBarPosition();
      }
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    _fadeoutTimer = Timer(widget.scrollbarTimeToFade, () {
      _thumbAnimationController.reverse();
      _labelAnimationController.reverse();
      _fadeoutTimer = null;
    });

    setState(() {
      _jumpToBarPosition();
      _isDragInProcess = false;
    });

    widget.scrollStateListener(false);
  }
}

/// Draws 2 triangles like arrow up and arrow down
class ArrowCustomPainter extends CustomPainter {
  Color color;

  ArrowCustomPainter(this.color);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const width = 12.0;
    const height = 8.0;
    final baseX = size.width / 2;
    final baseY = size.height / 2;

    canvas.drawPath(
      _trianglePath(Offset(baseX, baseY - 2.0), width, height, true),
      paint,
    );
    canvas.drawPath(
      _trianglePath(Offset(baseX, baseY + 2.0), width, height, false),
      paint,
    );
  }

  static Path _trianglePath(Offset o, double width, double height, bool isUp) {
    return Path()
      ..moveTo(o.dx, o.dy)
      ..lineTo(o.dx + width, o.dy)
      ..lineTo(o.dx + (width / 2), isUp ? o.dy - height : o.dy + height)
      ..close();
  }
}

///This cut 2 lines in arrow shape
class ArrowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0.0);
    path.lineTo(0.0, 0.0);
    path.close();

    double arrowWidth = 8.0;
    double startPointX = (size.width - arrowWidth) / 2;
    double startPointY = size.height / 2 - arrowWidth / 2;
    path.moveTo(startPointX, startPointY);
    path.lineTo(startPointX + arrowWidth / 2, startPointY - arrowWidth / 2);
    path.lineTo(startPointX + arrowWidth, startPointY);
    path.lineTo(startPointX + arrowWidth, startPointY + 1.0);
    path.lineTo(
      startPointX + arrowWidth / 2,
      startPointY - arrowWidth / 2 + 1.0,
    );
    path.lineTo(startPointX, startPointY + 1.0);
    path.close();

    startPointY = size.height / 2 + arrowWidth / 2;
    path.moveTo(startPointX + arrowWidth, startPointY);
    path.lineTo(startPointX + arrowWidth / 2, startPointY + arrowWidth / 2);
    path.lineTo(startPointX, startPointY);
    path.lineTo(startPointX, startPointY - 1.0);
    path.lineTo(
      startPointX + arrowWidth / 2,
      startPointY + arrowWidth / 2 - 1.0,
    );
    path.lineTo(startPointX + arrowWidth, startPointY - 1.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class SlideFadeTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const SlideFadeTransition({
    super.key,
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => animation.value == 0.0 ? const SizedBox() : child!,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0.3, 0.0),
          end: const Offset(0.0, 0.0),
        ).animate(animation),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
  }
}

class MultiLabelScrollThumb extends StatelessWidget {
  final Color backgroundColor;
  final Animation<double> thumbAnimation;
  final Animation<double> labelAnimation;
  final double height;
  final Text? prevLabel;
  final Text? currentLabel;
  final Text? nextLabel;
  final BoxConstraints? labelConstraints;
  static const double thumbWidth = 40.0;

  const MultiLabelScrollThumb({
    super.key,
    required this.backgroundColor,
    required this.thumbAnimation,
    required this.labelAnimation,
    required this.height,
    this.prevLabel,
    this.currentLabel,
    this.nextLabel,
    this.labelConstraints,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Labels section
          if (currentLabel != null)
            FadeTransition(
              opacity: labelAnimation,
              child: Container(
                margin: const EdgeInsets.only(right: 12.0),
                constraints: BoxConstraints(
                  minWidth: labelConstraints?.minWidth ?? 72.0,
                  maxHeight: height,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 4.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (prevLabel != null)
                        Opacity(
                          opacity: 0.5,
                          child: DefaultTextStyle(
                            style: Theme.of(context).textTheme.labelSmall!,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.visible,
                            child: prevLabel!,
                          ),
                        ),
                      if (currentLabel != null)
                        DefaultTextStyle(
                          style: Theme.of(context).textTheme.labelMedium!,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.visible,
                          child: currentLabel!,
                        ),
                      if (nextLabel != null)
                        Opacity(
                          opacity: 0.5,
                          child: DefaultTextStyle(
                            style: Theme.of(context).textTheme.labelSmall!,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.visible,
                            child: nextLabel!,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

          // Semicircular thumb
          FadeTransition(
            opacity: thumbAnimation,
            child: CustomPaint(
              foregroundPainter: ArrowCustomPainter(Colors.white),
              child: Material(
                elevation: 4.0,
                color: backgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(height),
                  bottomLeft: Radius.circular(height),
                  topRight: const Radius.circular(4.0),
                  bottomRight: const Radius.circular(4.0),
                ),
                child: Container(
                  constraints: BoxConstraints.tight(Size(thumbWidth, height)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}