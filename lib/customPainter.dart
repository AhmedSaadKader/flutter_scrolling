import 'package:flutter/material.dart';
import 'dart:math';

class CustomScrollbarPainter extends ScrollbarPainter {
  CustomScrollbarPainter({
    required Color color,
    required Animation<double> fadeoutOpacityAnimation,
    EdgeInsets padding = EdgeInsets.zero,
    double thickness = 8.0,
    double mainAxisMargin = 0.0,
    double crossAxisMargin = 0.0,
    Radius? radius,
    OutlinedBorder? shape,
    double minLength = 18.0,
    double? minOverscrollLength,
    ScrollbarOrientation? scrollbarOrientation,
  }) : super(
          color: color,
          fadeoutOpacityAnimation: fadeoutOpacityAnimation,
          padding: padding,
          thickness: thickness,
          mainAxisMargin: mainAxisMargin,
          crossAxisMargin: crossAxisMargin,
          radius: radius,
          shape: shape,
          minLength: minLength,
          minOverscrollLength: minOverscrollLength,
          scrollbarOrientation: scrollbarOrientation,
        );

  @override
  void paintThumb(Canvas canvas, Rect thumbBounds, {required TextDirection textDirection}) {
    final Paint paint = Paint()..color = color.withOpacity(fadeoutOpacityAnimation.value);

    // Draw semicircle
    final Rect arcRect = Rect.fromLTWH(
      thumbBounds.left,
      thumbBounds.top,
      thumbBounds.width,
      thumbBounds.height,
    );
    final double startAngle = -pi / 2;
    final double sweepAngle = pi;

    canvas.drawArc(
      arcRect,
      startAngle, // Start angle (top-center of the arc)
      sweepAngle, // Sweep 180 degrees (pi radians) to make a semicircle
      true,
      paint,
    );

    // Draw arrows on the semicircle
    _drawArrow(canvas, thumbBounds, paint, isUp: true); // Upward arrow
    _drawArrow(canvas, thumbBounds, paint, isUp: false); // Downward arrow
  }

  void _drawArrow(Canvas canvas, Rect thumbBounds, Paint paint, {required bool isUp}) {
    // Arrow size and positioning
    final double arrowWidth = thumbBounds.width / 2;
    final double arrowHeight = thumbBounds.height / 4;
    final double arrowXCenter = thumbBounds.center.dx;
    final double arrowYCenter = isUp ? thumbBounds.top + arrowHeight : thumbBounds.bottom - arrowHeight;

    // Define arrow path
    Path arrowPath = Path();
    if (isUp) {
      // Upward pointing triangle
      arrowPath.moveTo(arrowXCenter, arrowYCenter - arrowHeight / 2); // Top of the arrow
      arrowPath.lineTo(arrowXCenter - arrowWidth / 2, arrowYCenter + arrowHeight / 2); // Bottom left
      arrowPath.lineTo(arrowXCenter + arrowWidth / 2, arrowYCenter + arrowHeight / 2); // Bottom right
    } else {
      // Downward pointing triangle
      arrowPath.moveTo(arrowXCenter, arrowYCenter + arrowHeight / 2); // Bottom of the arrow
      arrowPath.lineTo(arrowXCenter - arrowWidth / 2, arrowYCenter - arrowHeight / 2); // Top left
      arrowPath.lineTo(arrowXCenter + arrowWidth / 2, arrowYCenter - arrowHeight / 2); // Top right
    }

    arrowPath.close();
    canvas.drawPath(arrowPath, paint);
  }
}

class CustomRawScrollbar extends StatefulWidget {
  final Widget child;

  CustomRawScrollbar({required this.child});

  @override
  _CustomRawScrollbarState createState() => _CustomRawScrollbarState();
}

class _CustomRawScrollbarState extends State<CustomRawScrollbar> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RawScrollbar(
      thumbVisibility: true,
      thickness: 12.0,
      controller: ScrollController(),
      // painter: CustomScrollbarPainter(
      //   color: Colors.blue,
      //   fadeoutOpacityAnimation: _controller,
      // ),
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
