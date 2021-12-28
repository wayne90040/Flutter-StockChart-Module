

import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stock_chart/models/quote.dart';
import 'package:flutter_stock_chart/second_painter_type.dart';
import 'package:flutter_stock_chart/extensions.dart';
import '../chart_constants.dart';


class SecondPainter extends CustomPainter {

  final Quote quote;
  final double scale;
  final double scrollX;
  final bool isShowBorder;
  final SecondPainterType type;

  SecondPainter({
    required this.quote,
    required this.scale,
    required this.scrollX,
    required this.isShowBorder,
    required this.type
  });

  late double _maxValue;
  late double _minValue;

  Paint _paint = new Paint()
    ..color = Colors.grey
    ..strokeCap = StrokeCap.square
    ..isAntiAlias = true
    ..strokeWidth = 1.0
    ..style = PaintingStyle.stroke
  ;

  @override
  void paint(Canvas canvas, Size size) {

    if (quote.open.length <= 0) return;

    canvas.save();
    canvas.translate(0, 20);

    _paint.color = Colors.grey.shade300;
    Size newSize = Size(size.width, size.height - 20);

    // 一頁放幾個
    int count = size.width ~/ (candleSpace * scale);
    count = count > quote.open.length ? quote.open.length : count;

    // 滾動了幾個
    int scrollCount = scrollX ~/ (candleSpace * scale) >= 0
        ? scrollX ~/ (candleSpace * scale)
        : 0;
    if (scrollCount > quote.open.length - count) {
      scrollCount = quote.open.length - count;
    }

    // 起始位置
    int startIndex = quote.open.length - count - scrollCount;

    if (isShowBorder)
      drawBorder(canvas, newSize);

    switch (type) {
      case SecondPainterType.VOL:
        getVolMaxMin(quote, count, startIndex);
        drawVolLeftText(canvas, size);
        drawVolChart(canvas, quote, newSize, count, startIndex);
        break;
      case SecondPainterType.MACD:
        getMACDMaxMin(quote, count, startIndex);
        drawMACDChart(canvas, quote, newSize, count, startIndex);
        drawLeftText(canvas, size);
        break;
      case SecondPainterType.KD:
        getKDMaxMin(quote, count, startIndex);
        drawKDJChart(canvas, quote, newSize, count, startIndex);
        drawLeftText(canvas, size);
        break;
      case SecondPainterType.BOLL:
        getBOLLMaxMin(quote, count, startIndex);
        drawBOLLChart(canvas, quote, newSize, count, startIndex);
        drawLeftText(canvas, size);
        break;
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  // 畫邊框
  void drawBorder(Canvas canvas, Size size) {
    _paint.color = Colors.grey.shade300;

    canvas.drawLine(Offset(0, 0), Offset(size.width, 0), _paint);
    canvas.drawLine(Offset(0, 0), Offset(0, size.height), _paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, size.height), _paint);
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), _paint);
  }


  //region VOL Chart
  void drawVolChart(Canvas canvas, Quote quote, Size size, int count, int startIndex) {

    double candleWidth = candleSpace * scale;
    Path ma5VolPath = Path();
    Path ma10VolPath = Path();

    for (var i = 0; i < count; i++) {
      int curIndex = startIndex + i;
      double open = getVolY(quote.open[curIndex].toDouble(), size);
      double close = getVolY(quote.close[curIndex].toDouble(), size);

      if (open > close) {
        _paint.color = upColor;
      } else {
        _paint.color = dnColor;
      }

      double x = candleWidth * i;
      double lineX = candleWidth * i + candleWidth / 2;
      double y = getVolY(quote.volume[curIndex].toDouble(), size);
      double ma5Vol = quote.ma5Vol[curIndex];
      double ma10Vol = quote.ma10Vol[curIndex];

      if (i == 0) {
        ma5VolPath.moveTo(lineX, getVolY(ma5Vol, size));
        ma10VolPath.moveTo(lineX, getVolY(ma10Vol, size));
      } else {
        ma5VolPath.lineTo(lineX, getVolY(ma5Vol, size));
        ma10VolPath.lineTo(lineX, getVolY(ma10Vol, size));
      }

      double endY = size.height;
      _paint.style = PaintingStyle.fill;
      canvas.drawRect(
          Rect.fromPoints(Offset(x, y), Offset(x + candleWidth - 1, endY)), _paint
      );
    }
    _paint.color = kValue1Color;
    _paint.style = PaintingStyle.stroke;
    canvas.drawPath(ma5VolPath, _paint);
    _paint.color = kValue2Color;
    canvas.drawPath(ma10VolPath, _paint);
  }

  void drawVolLeftText(Canvas canvas, Size size) {
    TextSpan span = TextSpan(
        text: _maxValue.toStringAsFixed(0),
        style: TextStyle(color: Colors.grey, fontSize: leftFontSize)
    );
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(2, 2));
  }

  double getVolY(double value, Size size) =>
      size.height * (1 - (value / _maxValue));

  void getVolMaxMin(Quote quote, int count, int index) {

    _maxValue = 0;
    _minValue = 999999999;

    for (var i = 0; i < count; i++) {

      _maxValue = [_maxValue, (quote.volume[index + i] as int).toDouble(), quote.ma5Vol[index + i],
        quote.ma10Vol[index + i]].findMax();

      _minValue = [_minValue, (quote.volume[index + i] as int).toDouble(), quote.ma5Vol[index + i],
        quote.ma10Vol[index + i]].findMin();

      _minValue = max(0, _minValue);

    }
  }
  //endregion

  //region MACD Chart
  void getMACDMaxMin(Quote quote, int count, int index) {
    _maxValue = 0;
    _minValue = double.infinity;

    for (var i = 0; i < count; i++) {
      int curIndex = index + i;

      _maxValue = [_maxValue, quote.macd[curIndex], quote.dif[curIndex], quote.dea[curIndex]].findMax();
      _minValue = [_minValue, quote.macd[curIndex], quote.dif[curIndex], quote.dea[curIndex]].findMin();
    }
  }

  void drawMACDChart(Canvas canvas, Quote quote, Size size, int count, int startIndex) {
    double candleWidth = candleSpace * scale;
    Path difPath = Path();
    Path deaPath = Path();
    _paint.color = Colors.black54;
    canvas.drawLine(Offset(0, getY(0, size)), Offset(size.width, getY(0, size)), _paint);

    for (var i = 0; i < count; i++) {
      int curIndex = startIndex + i;

      double open = getY(quote.open[curIndex].toDouble(), size);
      double close = getY(quote.close[curIndex].toDouble(), size);

      _paint.color = open > close ? dnColor : upColor;

      double lineX = candleWidth * i + candleWidth / 2;
      double y = getY(quote.macd[curIndex], size);
      double dif = quote.dif[curIndex];
      double dea = quote.dea[curIndex];

      if (i == 0) {
        difPath.moveTo(lineX, getY(dif, size));
        deaPath.moveTo(lineX, getY(dea, size));
      } else {
        difPath.lineTo(lineX, getY(dif, size));
        deaPath.lineTo(lineX, getY(dea, size));
      }

      _paint.style = PaintingStyle.fill;

      _paint.color = quote.macd[curIndex] > 0 ? upColor : dnColor;
      canvas.drawLine(Offset(lineX, y), Offset(lineX, getY(0, size)), _paint);
    }
    _paint.color = kValue1Color;
    _paint.style = PaintingStyle.stroke;
    canvas.drawPath(difPath, _paint);
    _paint.color = kValue2Color;
    canvas.drawPath(deaPath, _paint);
  }

  //endregion

  //region KD Chart
  void getKDMaxMin(Quote quote, int count, int index) {

    _maxValue = 0;
    _minValue = 999999999999;

    for (var i = 0; i < count - 1; i++) {

      int curIndex = index + i;

      _maxValue = [_maxValue, quote.k[curIndex], quote.d[curIndex], quote.j[curIndex]].findMax();
      _minValue = [_minValue, quote.k[curIndex], quote.d[curIndex], quote.j[curIndex]].findMin();
    }
  }

  void drawKDJChart(Canvas canvas, Quote quote, Size size, int count, int startIndex) {

    double width = candleSpace * scale;
    Path kPath = Path();
    Path dPath = Path();
    Path jPath = Path();

    for (var i = 0; i < count; i ++) {
      int curIndex = startIndex + i;
      double lineX = width * i + candleSpace / 2;

      double k = getY(quote.k[curIndex], size);
      double d = getY(quote.d[curIndex], size);
      double j = getY(quote.j[curIndex], size);

      if (i == 0) {
        kPath.moveTo(lineX, k);
        dPath.moveTo(lineX, d);
        jPath.moveTo(lineX, j);
      } else {
        kPath.lineTo(lineX, k);
        dPath.lineTo(lineX, d);
        jPath.lineTo(lineX, j);
      }
    }
    _paint.style = PaintingStyle.stroke;

    _paint.color = kValue1Color;
    canvas.drawPath(kPath, _paint);

    _paint.color = kValue2Color;
    canvas.drawPath(dPath, _paint);

    _paint.color = kValue3Color;
    canvas.drawPath(jPath, _paint);
  }
  //endregion

  //region BOLL Chart

  void getBOLLMaxMin(Quote quote, int count, int index) {
    _maxValue = 0;
    _minValue = 999999999999;

    for (var i = 0; i < count; i ++) {
      int curIndex = index + i;
      _maxValue = [_maxValue, quote.high[curIndex].toDouble(), quote.up[curIndex]].findMax();
      _minValue = [_minValue, quote.low[curIndex].toDouble(), quote.dn[curIndex]].findMin();
    }
  }

  void drawBOLLChart(Canvas canvas, Quote quote, Size size, int count, int startIndex) {
    _paint.style = PaintingStyle.fill;
    double pwidth = candleSpace * scale;
    Path upPath = Path();
    Path mbPath = Path();
    Path dnPath = Path();
    //遍历画蜡烛
    for (var i = 0; i < count; i++) {
      int curIndex = startIndex + i;
      _paint.style = PaintingStyle.fill;
      drawCandle(canvas, quote, curIndex, size, i * candleSpace + candleSpace / 2);

      double linex = pwidth * i + pwidth / 2;
      double up = getY(quote.up[curIndex], size);
      double mb = getY(quote.mb[curIndex], size);
      double dn = getY(quote.dn[curIndex], size);
      if (i == 0) {
        upPath.moveTo(linex, up);
        mbPath.moveTo(linex, mb);
        dnPath.moveTo(linex, dn);
      } else {
        upPath.lineTo(linex, up);
        mbPath.lineTo(linex, mb);
        dnPath.lineTo(linex, dn);
      }
    }
    _paint.style = PaintingStyle.stroke;
    _paint.color = kValue1Color;

    canvas.drawPath(mbPath, _paint);
    _paint.color = kValue2Color;
    canvas.drawPath(upPath, _paint);
    _paint.color = kValue3Color;
    canvas.drawPath(dnPath, _paint);
  }

  void drawCandle(Canvas canvas, Quote quote, int index, Size size, double curX) {
    double high = getY(quote.high[index].toDouble(), size);
    double low = getY(quote.low[index].toDouble(), size);
    double open = getY(quote.open[index].toDouble(), size);
    double close = getY(quote.close[index].toDouble(), size);
    double r = candleWidth / 2 * scale;
    double lineR = candleLineWidth / 2 * scale;

    if (open > close) {
      _paint.color = dnColor;
      canvas.drawRect(Rect.fromLTRB(curX - r, close, curX + r, open), _paint);
      canvas.drawRect(
          Rect.fromLTRB(curX - lineR, high, curX + lineR, low), _paint);
    } else {
      _paint.color = upColor;
      canvas.drawRect(Rect.fromLTRB(curX - r, open, curX + r, close), _paint);
      canvas.drawRect(
          Rect.fromLTRB(curX - lineR, high, curX + lineR, low), _paint);
    }
  }
  //endregion


  void drawLeftText(Canvas canvas, Size size) {
    TextSpan span = TextSpan(
        text: _maxValue.toStringAsFixed(2),
        style: TextStyle(color: Colors.grey, fontSize: leftFontSize)
    );
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(2, 2));

    TextSpan span2 = TextSpan(
        text: _minValue.toStringAsFixed(2),
        style: TextStyle(color: Colors.grey, fontSize: leftFontSize)
    );
    TextPainter tp2 = TextPainter(text: span2, textDirection: TextDirection.ltr);
    tp2.layout();
    tp2.paint(canvas, Offset(2, size.height - 15));
  }

  double getY(double value, Size size) {
    double d = _maxValue - _minValue;
    double currentD = value - _minValue;
    double p = 1 - currentD / d;
    return size.height * p;
  }
}