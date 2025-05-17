import 'package:flutter/material.dart';

class OrderTabIndicator extends Decoration {
  final BoxPainter _painter;

  OrderTabIndicator({
    required Color color,
    required double height,
    double radius = 3.0,
  }) : _painter = _OrderIndicatorPainter(color, height, radius);

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _painter;
}

class _OrderIndicatorPainter extends BoxPainter {
  final Paint _paint;
  final double height;
  final double radius;

  _OrderIndicatorPainter(Color color, this.height, this.radius)
      : _paint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);
    final Rect rect = Offset(
            offset.dx,
            offset.dy + configuration.size!.height - height) &
        Size(configuration.size!.width, height);
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      _paint,
    );
  }
} 