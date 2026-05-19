import 'package:flutter/material.dart';

typedef ResponsiveLayoutBuilder = Widget Function(
    BuildContext context, BoxConstraints constraints, bool isNarrow);

/// A reusable layout that centers a card-like child with a maximum width
/// while ensuring the scrollbar remains at the edge of the viewport.
class ResponsiveCenteredLayout extends StatelessWidget {
  final ResponsiveLayoutBuilder builder;
  final double maxWidth;
  final EdgeInsets? padding;
  final Color? backgroundColor;

  const ResponsiveCenteredLayout({
    super.key,
    required this.builder,
    this.maxWidth = 450,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 450;
          final effectivePadding = padding ?? EdgeInsets.symmetric(
            vertical: isNarrow ? 0 : 40,
            horizontal: isNarrow ? 0 : 24,
          );

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
                minWidth: constraints.maxWidth,
              ),
              child: Center(
                child: Padding(
                  padding: effectivePadding,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: builder(context, constraints, isNarrow),
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
