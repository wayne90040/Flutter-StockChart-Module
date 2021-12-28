

import 'package:flutter/cupertino.dart';

import '../painters/main_painter.dart';
import '../models/quote.dart';

class MainChartWidget extends StatelessWidget {

  const MainChartWidget({
    Key? key,
    required this.quote,
    required this.scrollX,
    required this.scale,
  }) : super(key: key);

  final Quote quote;
  final double scrollX;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: CustomPaint(
        painter: MainPainter(
            quote: quote,
            scrollX: scrollX,
            scale: scale,
            isShowBorder: true,
            isShowDate: true
        ),
      ),
    );
  }
}