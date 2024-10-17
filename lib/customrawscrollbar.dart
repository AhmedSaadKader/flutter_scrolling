import 'package:flutter/material.dart';

class CustomThumbScrollbar extends RawScrollbar {
  final String Function(double)? labelTextBuilder;

  const CustomThumbScrollbar({
    super.key,
    required Widget child,
    ScrollController? controller,
    bool? thumbVisibility,
    Radius? radius,
    double? thickness,
    Color? thumbColor,
    this.labelTextBuilder,
  }) : super(
          child: child,
          controller: controller,
          thumbVisibility: thumbVisibility,
          radius: radius,
          thickness: thickness,
          thumbColor: thumbColor,
        );

  @override
  _CustomThumbScrollbarState createState() => _CustomThumbScrollbarState();
}

class _CustomThumbScrollbarState extends RawScrollbarState<CustomThumbScrollbar> {
  @override
  Widget build(BuildContext context) {
    // Ensure the scroll controller is available
    final ScrollController scrollController = widget.controller ?? PrimaryScrollController.of(context)!;

    // Compute the current scroll offset to generate a label
    final double thumbOffset = scrollController.hasClients ? scrollController.offset : 0.0;
    final String label = widget.labelTextBuilder?.call(thumbOffset) ?? '';

    // Build the scrollbar and label
    return Stack(
      children: [
        super.build(context), // This builds the default RawScrollbar
        Positioned(
          right: 10, // Position the label close to the thumb
          top: thumbOffset, // You might need to adjust this depending on the scroll extent
          child: Container(
            color: Colors.black54,
            padding: const EdgeInsets.all(5),
            child: Text(
              label,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
