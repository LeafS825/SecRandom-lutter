import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double minItemWidth;
  final double spacing;
  final EdgeInsets padding;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.minItemWidth = 300,
    this.spacing = 12,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth - padding.horizontal;
        final crossAxisCount = (availableWidth / minItemWidth).floor().clamp(1, 4);
        final itemWidth = (availableWidth - spacing * (crossAxisCount - 1)) / crossAxisCount;

        return SingleChildScrollView(
          padding: padding,
          child: _SameHeightWrap(
            spacing: spacing,
            runSpacing: spacing,
            crossAxisCount: crossAxisCount,
            children: children.map((child) {
              return SizedBox(
                width: itemWidth,
                child: child,
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

/// A Wrap-like widget that keeps children in the same row at the same height.
class _SameHeightWrap extends MultiChildRenderObjectWidget {
  final double spacing;
  final double runSpacing;
  final int crossAxisCount;

  const _SameHeightWrap({
    required super.children,
    required this.spacing,
    required this.runSpacing,
    required this.crossAxisCount,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderSameHeightWrap(
      spacing: spacing,
      runSpacing: runSpacing,
      crossAxisCount: crossAxisCount,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderSameHeightWrap renderObject) {
    renderObject
      ..spacing = spacing
      ..runSpacing = runSpacing
      ..crossAxisCount = crossAxisCount;
  }
}

class _SameHeightWrapParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderSameHeightWrap extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, _SameHeightWrapParentData>,
         RenderBoxContainerDefaultsMixin<RenderBox, _SameHeightWrapParentData> {
  double spacing;
  double runSpacing;
  int crossAxisCount;

  _RenderSameHeightWrap({
    required this.spacing,
    required this.runSpacing,
    required this.crossAxisCount,
  });

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _SameHeightWrapParentData) {
      child.parentData = _SameHeightWrapParentData();
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return 0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return 0;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return 0;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return 0;
  }

  @override
  void performLayout() {
    final maxWidth = constraints.maxWidth;
    final childConstraints = BoxConstraints(maxWidth: maxWidth);

    // Layout all children and collect them
    final childrenList = <RenderBox>[];
    var child = firstChild;
    while (child != null) {
      child.layout(childConstraints, parentUsesSize: true);
      childrenList.add(child);
      child = (child.parentData! as _SameHeightWrapParentData).nextSibling;
    }

    if (childrenList.isEmpty) {
      size = Size(maxWidth, 0);
      return;
    }

    // Group into rows
    final rows = <List<RenderBox>>[];
    final rowHeights = <double>[];
    var currentRow = <RenderBox>[];
    var currentRowHeight = 0.0;

    for (var i = 0; i < childrenList.length; i++) {
      final c = childrenList[i];
      currentRow.add(c);
      if (c.size.height > currentRowHeight) {
        currentRowHeight = c.size.height;
      }

      if (currentRow.length == crossAxisCount || i == childrenList.length - 1) {
        rows.add(List.from(currentRow));
        rowHeights.add(currentRowHeight);
        currentRow.clear();
        currentRowHeight = 0;
      }
    }

    // Position children with uniform row height
    var yOffset = 0.0;
    for (var rowIdx = 0; rowIdx < rows.length; rowIdx++) {
      final row = rows[rowIdx];
      final rowHeight = rowHeights[rowIdx];
      var xOffset = 0.0;

      for (final c in row) {
        final parentData = c.parentData! as _SameHeightWrapParentData;
        parentData.offset = Offset(xOffset, yOffset);
        xOffset += c.size.width + spacing;
      }

      yOffset += rowHeight + runSpacing;
    }

    size = Size(maxWidth, yOffset - runSpacing);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
