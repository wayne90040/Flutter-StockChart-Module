


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stock_chart/main_painter.dart';
import 'package:flutter_stock_chart/quote.dart';
import 'package:flutter_stock_chart/second_painter.dart';
import 'package:flutter_stock_chart/second_painter_type.dart';
import 'package:flutter_stock_chart/stock_chart_view_model.dart';
import 'package:provider/provider.dart';

import 'chart_constants.dart';


class StockChartScreen extends StatefulWidget {

  static String routeName = "/stock_main_screen";

  @override
  _StockChartScreenState createState() => _StockChartScreenState();
}


class _StockChartScreenState extends State<StockChartScreen> {

  double scrollX = 0.0;  // 水平移動
  bool isHorizontalDrag = false; // 偵測是否水平移動
  bool isScaling = false; // 偵測是否縮放
  double scale = 1.0;

  int typeIndex = 0;
  List<SecondPainterType> types = [
    SecondPainterType.VOL,
    SecondPainterType.MACD,
    SecondPainterType.KD,
    SecondPainterType.BOLL
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    var viewModel = Provider.of<StockChartViewModel>(context, listen: false);

    double width = MediaQuery.of(context).size.width;
    double maxScrollX = (viewModel.maxCount - (width ~/ candleSpace)).abs() * candleSpace;

    print("Quote${viewModel.quote}");

    return SafeArea(
      child: Column(
        children: <Widget>[
          SizedBox(height: 10),

          GestureDetector(
            child: viewModel.quote == null ? Container() :
              MainChartWidget(quote: viewModel.quote!, scrollX: scrollX, scale: scale),

            onHorizontalDragStart: (_ ) {
              // 水平移動開始
              isHorizontalDrag = true;
            },
            onHorizontalDragUpdate: (detail) {
              if (isScaling == true) return;

              // 水平移動 更新 Chart
              // clamp 用於約束數字的範圍
              scrollX = ((detail.primaryDelta ?? 0.0) + scrollX).clamp(0.0, maxScrollX);
              setState(() {

              });
            },
            onHorizontalDragEnd: (_ ) {
              isHorizontalDrag = false;
            },

            onScaleStart: (_ ) {
              isScaling = true;
            },
          ),

          SizedBox(height: 10),

          GestureDetector(
            child: (viewModel.quote == null) ? Container() :
              SecondChartWidget(
                  quote: viewModel.quote!,
                  scale: scale,
                  scrollX: scrollX,
                  types: types,
                  typeIndex: typeIndex),
            onTap: () {
              setState(() {
                typeIndex = (typeIndex + 1) % types.length;
              });
            },
          )
        ],
      ),
    );
  }
}

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
      height: 200,
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
      height: 300,
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