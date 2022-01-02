


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stock_chart/second_painter_type.dart';
import 'package:flutter_stock_chart/viewmodels/stock_chart_view_model.dart';
import 'package:flutter_stock_chart/widgets/main_chart_widget.dart';
import 'package:flutter_stock_chart/widgets/second_chart_widget.dart';
import 'package:provider/provider.dart';

import '../chart_constants.dart';


class StockChartScreen extends StatefulWidget {
  @override
  _StockChartScreenState createState() => _StockChartScreenState();
}

class _StockChartScreenState extends State<StockChartScreen> {

  double scrollX = 0.0;  // 水平移動
  bool isHorizontalDrag = false; // 偵測是否水平移動
  bool isScaling = false; // 偵測是否縮放
  double scale = 1.0, lastScale = 1.0;
  int typeIndex = 0;

  GlobalKey<SecondChartWidgetState> secondKey = GlobalKey();
  GlobalKey<SecondChartWidgetState> secondKey2 = GlobalKey();

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

    return SafeArea(
      child: Container(
        color: Colors.black,
        child: Flex(
          direction: Axis.vertical,
          children: [
            Expanded(
              flex: 3,
              child: GestureDetector(
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
                  setState(() {
                    scrollX = ((detail.primaryDelta ?? 0.0) + scrollX).clamp(0.0, maxScrollX);
                  });
                },
                onHorizontalDragEnd: (_ ) {
                  isHorizontalDrag = false;
                },
                onScaleStart: (_ ) {
                  isScaling = true;
                },
                onScaleUpdate: (details) {
                  if (isHorizontalDrag) return;
                  setState(() {
                    scale = (lastScale * details.scale).clamp(0.5, 2.2);
                  });
                },
                onScaleEnd: (_) {
                  isScaling = false;
                  lastScale = scale;
                },
              )
            ),
            Expanded(
              flex: 1,
              child: GestureDetector(
                child: (viewModel.quote == null) ? Container() :
                SecondChartWidget(
                    key: secondKey,
                    quote: viewModel.quote!,
                    scale: scale,
                    scrollX: scrollX,
                    types: types),
                onTap: () {
                  secondKey.currentState?.changeChart();
                },
                onHorizontalDragStart: (_ ) {
                  // 水平移動開始
                  isHorizontalDrag = true;
                },
                onHorizontalDragUpdate: (detail) {
                  if (isScaling == true) return;

                  // 水平移動 更新 Chart
                  // clamp 用於約束數字的範圍
                  setState(() {
                    scrollX = ((detail.primaryDelta ?? 0.0) + scrollX).clamp(0.0, maxScrollX);
                  });
                },
                onHorizontalDragEnd: (_ ) {
                  isHorizontalDrag = false;
                },
                onScaleStart: (_) {
                  isScaling = true;
                },
                onScaleUpdate: (details) {
                  if (isHorizontalDrag) return;
                  setState(() {
                    scale = (lastScale * details.scale).clamp(0.5, 2.2);
                  });
                },
                onScaleEnd: (_) {
                  isScaling = false;
                  lastScale = scale;
                },
              )
            ),
            Expanded(
              flex: 1,
              child: GestureDetector(
                child: (viewModel.quote == null) ? Container() :
                SecondChartWidget(
                    key: secondKey2,
                    quote: viewModel.quote!,
                    scale: scale,
                    scrollX: scrollX,
                    types: types),
                onTap: () {
                  secondKey2.currentState?.changeChart();
                },
                onScaleStart: (_) {
                  isScaling = true;
                },
                onScaleUpdate: (details) {
                  if (isHorizontalDrag) return;
                  setState(() {
                    scale = (lastScale * details.scale).clamp(0.5, 2.2);
                  });
                },
                onScaleEnd: (_) {
                  isScaling = false;
                  lastScale = scale;
                },
              )
            )
          ],
        ),
      ),
    );
  }
}
