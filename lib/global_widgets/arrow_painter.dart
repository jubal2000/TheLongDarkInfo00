import 'package:arrow_path/arrow_path.dart';
import 'package:flutter/material.dart';

class ArrowPainterItem {
  double sx;
  double sy;
  double dx;
  double dy;
  Color color;
  ArrowPainterItem(
      this.sx,
      this.sy,
      this.dx,
      this.dy,
      this.color,
      );
}

class ArrowPainter extends CustomPainter {
  List<ArrowPainterItem> itemList;

  ArrowPainter(this.itemList);

  @override
  void paint(Canvas canvas, Size size) {
    /// The arrows usually looks better with rounded caps.
    final Paint paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2;

    /// Draw a single arrow.
    for (var item in itemList) {
      Path path = Path();
      path.moveTo(item.sx, item.sy);
      path.relativeCubicTo(0, 0, (item.dx - item.sx) * 0.5, (item.dy - item.sy) * 0.02, item.dx - item.sx, item.dy - item.sy);
      path = ArrowPath.make(path: path);
      canvas.drawPath(path, paint..color = item.color);

      // final TextSpan textSpan = TextSpan(
      //   text: 'Single arrow',
      //   style: TextStyle(color: Colors.blue),
      // );
      // final TextPainter textPainter = TextPainter(
      //   text: textSpan,
      //   textAlign: TextAlign.center,
      //   textDirection: TextDirection.ltr,
      // );
      // textPainter.layout(minWidth: size.width);
      // textPainter.paint(canvas, Offset(0, 36));
    }
  }

  @override
  bool shouldRepaint(ArrowPainter oldDelegate) => false;
}