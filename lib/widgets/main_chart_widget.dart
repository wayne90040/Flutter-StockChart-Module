

import 'package:flutter/cupertino.dart';

import '../painters/main_painter.dart';
import '../models/quote.dart';

class MainChartWidget extends StatefulWidget {

  const MainChartWidget({
    Key? key,
    required this.quote,
  }) : super(key: key);

  final Quote quote;

  @override
  State<MainChartWidget> createState() => MainChartWidgetState();
}

class MainChartWidgetState extends State<MainChartWidget> {

  double scrollX = 0, scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: CustomPaint(
        painter: MainPainter(
            quote: widget.quote,
            scrollX: scrollX,
            scale: scale,
            isShowBorder: true,
            isShowDate: true
        ),
      ),
    );
  }

  void scrolling(double scrollX) {
    setState(() {
      this.scrollX = scrollX;
    });
  }

  void scaling(double scale) {
    setState(() {
      this.scale = scale;
    });
  }
}