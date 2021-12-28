

import 'package:flutter/cupertino.dart';

import '../models/quote.dart';
import '../painters/second_painter.dart';
import '../second_painter_type.dart';

class SecondChartWidget extends StatelessWidget {

  const SecondChartWidget({
    Key? key,
    required this.quote,
    required this.scale,
    required this.scrollX,
    required this.types,
    required this.typeIndex,
  }) : super(key: key);

  final Quote quote;
  final double scale;
  final double scrollX;
  final List<SecondPainterType> types;
  final int typeIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: CustomPaint(
        painter: SecondPainter(
            quote: quote,
            scale: scale,
            scrollX: scrollX,
            isShowBorder: true,
            type: types[typeIndex]
        ),
      ),
    );
  }
}