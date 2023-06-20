import 'package:flutter/material.dart';
import '../rendering/staggered_grid.dart';
import '../widgets/staggered_grid.dart';

/// Represents the size of a [StaggeredGrid]'s tile.
class StaggeredGridTile extends ParentDataWidget<StaggeredGridParentData> {
  const StaggeredGridTile._({
    Key? key,
    required this.crossAxisCellCount,
    required this.mainAxisCellCount,
    required this.mainAxisExtent,
    required Widget child,
  })  : assert(crossAxisCellCount > 0),
        assert(mainAxisCellCount == null || mainAxisCellCount > 0),
        assert(mainAxisExtent == null || mainAxisExtent > 0),
        super(key: key, child: child);

  /// Creates a [StaggeredGrid]'s tile that takes a fixed number of cells along
  /// the main axis.
  const StaggeredGridTile.count({
    Key? key,
    required int crossAxisCellCount,
    required num mainAxisCellCount,
    required Widget child,
  }) : this._(
          key: key,
          crossAxisCellCount: crossAxisCellCount,
          mainAxisCellCount: mainAxisCellCount,
          mainAxisExtent: null,
          child: child,
        );

  /// Creates a [StaggeredGrid]'s tile that takes a specific amount of space
  /// along the main axis.
  const StaggeredGridTile.extent({
    Key? key,
    required int crossAxisCellCount,
    required double mainAxisExtent,
    required Widget child,
  }) : this._(
          key: key,
          crossAxisCellCount: crossAxisCellCount,
          mainAxisCellCount: null,
          mainAxisExtent: mainAxisExtent,
          child: child,
        );

  /// Creates a [StaggeredGrid]'s tile that fits its main axis extent to its
  /// [child]'s content
  const StaggeredGridTile.fit({
    Key? key,
    required int crossAxisCellCount,
    required Widget child,
  }) : this._(
          key: key,
          crossAxisCellCount: crossAxisCellCount,
          mainAxisCellCount: null,
          mainAxisExtent: null,
          child: child,
        );

  /// The number of cells that this tile takes along the cross axis.
  final int crossAxisCellCount;

  /// The number of cells that this tile takes along the main axis.
  final num? mainAxisCellCount;

  /// The amount of space that this tile takes along the main axis.
  final double? mainAxisExtent;

  @override
  void applyParentData(RenderObject renderObject) {
    final parentData = renderObject.parentData;
    if (parentData is StaggeredGridParentData) {
      bool needsLayout = false;

      if (parentData.crossAxisCellCount != crossAxisCellCount) {
        parentData.crossAxisCellCount = crossAxisCellCount;
        needsLayout = true;
      }

      if (parentData.mainAxisCellCount != mainAxisCellCount) {
        parentData.mainAxisCellCount = mainAxisCellCount;
        needsLayout = true;
      }

      if (parentData.mainAxisExtent != mainAxisExtent) {
        parentData.mainAxisExtent = mainAxisExtent;
        needsLayout = true;
      }

      if (needsLayout) {
        final targetParent = renderObject.parent;
        if (targetParent is RenderStaggeredGrid) {
          targetParent.markNeedsLayout();
        }
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => StaggeredGrid;
}
