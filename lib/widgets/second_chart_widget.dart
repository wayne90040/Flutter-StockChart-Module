

import 'package:flutter/cupertino.dart';

import '../models/quote.dart';
import '../painters/second_painter.dart';
import '../second_painter_type.dart';

class SecondChartWidget extends StatefulWidget {

  const SecondChartWidget({
    Key? key,
    required this.quote,
    required this.scale,
    required this.scrollX,
    required this.types
  }) : super(key: key);

  final Quote quote;
  final double scale;
  final double scrollX;
  final List<SecondPainterType> types;


  @override
  State<SecondChartWidget> createState() => SecondChartWidgetState();
}

class SecondChartWidgetState extends State<SecondChartWidget> {

  int typeIndex = 0;

  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: CustomPaint(
        painter: SecondPainter(
            quote: widget.quote,
            scale: widget.scale,
            scrollX: widget.scrollX,
            isShowBorder: true,
            type: widget.types[typeIndex]
        ),
      ),
    );
  }

  void changeChart() {
    setState(() {
      typeIndex = (typeIndex + 1) % widget.types.length;
    });
  }
}