

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
    required this.types,
    required this.typeIndex,
  }) : super(key: key);

  final Quote quote;
  final double scale;
  final double scrollX;
  final List<SecondPainterType> types;
  final int typeIndex;


  @override
  State<SecondChartWidget> createState() => SecondChartWidgetState();
}

class SecondChartWidgetState extends State<SecondChartWidget> {


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
            type: widget.types[widget.typeIndex]
        ),
      ),
    );
  }
}