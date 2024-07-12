// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import '../rendering/uniform_track.dart';

class UniformTrack extends MultiChildRenderObjectWidget {
  UniformTrack({
    Key? key,
    required this.division,
    this.spacing = 0,
    required this.direction,
    required List<Widget> children,
  })  : assert(spacing >= 0),
        assert(division > 0),
        assert(children.length <= division),
        super(key: key, children: children);

  final double spacing;
  final int division;
  final AxisDirection direction;

  @override
  RenderUniformTrack createRenderObject(BuildContext context) {
    return RenderUniformTrack(
      direction: direction,
      division: division,
      spacing: spacing,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderUniformTrack renderObject,
  ) {
    renderObject
      ..direction = direction
      ..division = division
      ..spacing = spacing;
  }
}
