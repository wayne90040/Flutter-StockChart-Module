

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stock_chart/models/quote.dart';
import 'package:flutter_stock_chart/extensions.dart';

import '../chart_constants.dart';

class MainPainter extends CustomPainter {

  final Quote quote;
  final double scale;
  final double scrollX;
  final bool isShowBorder;
  final bool isShowDate;

  MainPainter({
    required this.quote,
    required this.scale,
    required this.scrollX,
    required this.isShowBorder,
    required this.isShowDate
  });

  late double _maxValue;
  late double _minValue;

  Paint _paint = new Paint()
    ..color = Colors.grey.shade300
    ..strokeCap = StrokeCap.square
    ..isAntiAlias = true
    ..strokeWidth = 1.0
    ..style = PaintingStyle.fill
  ;

  Paint _avePaint = new Paint()
    ..color = aveColor
    ..strokeCap = StrokeCap.square
    ..isAntiAlias = true
    ..strokeWidth = 1.0
    ..style = PaintingStyle.stroke
  ;

  @override
  void paint(Canvas canvas, Size size) {

    if (quote.open.length <= 0)
      return;

    canvas.save();
    canvas.translate(0, 20);
    _paint.color = Colors.grey;

    // 根據是否顯示時間設定 Size
    Size newSize = Size(size.width, size.height - 20);

    // 一頁放幾個
    int count = size.width ~/ (candleSpace * scale);
    count = count > quote.open.length ? quote.open.length : count;

    // 滾動幾個
    int scrollIndex = scrollX ~/(candleSpace * scale) >= 0
        ? scrollX ~/ (candleSpace * scale) : 0;

    if (scrollIndex > quote.open.length - count) {
      scrollIndex = quote.open.length - count;
    }

    // 起始位置
    int startIndex = quote.open.length - count - scrollIndex;
    // String startDate = dataList[beginIndex]["date"];
    // String endDate = dataList[beginIndex + count - 1]["date"];

    // 邊框
    if (isShowBorder)
      drawBorder(canvas, newSize);

    // 虛線
    drawDashLine(canvas, newSize);

    // K線
    drawCandleLineChart(canvas, quote, newSize, count, startIndex);

    // MA 線
    drawMALine(canvas, quote, newSize, count, startIndex);

    // 左側文字
    drawLeftText(canvas, newSize);

    canvas.restore();

    // 上方文字
    drawTopText(canvas, quote, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }

  // Draw 編框
  void drawBorder(Canvas canvas, Size size) {
    _paint.color = Colors.grey.shade300;

    canvas.drawLine(Offset(0, 0), Offset(size.width, 0), _paint);
    canvas.drawLine(Offset(0, 0), Offset(0, size.height), _paint);
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), _paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, size.height), _paint);
  }

  // 畫虛線
  void drawDashLine(Canvas canvas, Size size) {
    _paint.color = Colors.grey.shade300;

    var maxWidth = size.width - 10;
    var maxHeight = size.height - 10;
    var dashWidth = 5;
    var dashSpace = 5;

    double x = 0;
    double y = 0;

    final space = dashSpace + dashWidth;

    if (x < maxWidth) {
      while (x < maxWidth) {
        canvas.drawLine(Offset(x + dashSpace, size.height / 2),
            Offset(x + dashWidth + dashSpace, size.height / 2), _paint);
        x += space;
      }
    }
    if (y < maxHeight) {
      while (y < maxHeight) {
        canvas.drawLine(Offset(size.width / 2, y + dashSpace),
            Offset(size.width / 2, y + dashWidth + colMaxWidth), _paint);
        y += space;
      }
    }
  }

  // K 線
  void drawCandleLineChart(Canvas canvas, Quote quote, Size size, int count, int startIndex) {

    // Get Max & Min Value
    getMaxMinValue(quote, size, count, startIndex);

    // 遍歷畫蠟燭
    for (var i = 0; i < count; i ++) {
      drawCandle(canvas, quote, startIndex + i, size,
          i * candleSpace * scale + candleSpace * scale / 2
      );
    }
  }

  // 蠟燭圖
  void drawCandle(Canvas canvas, Quote quote, int index, Size size, double curX) {
    double high = getY(quote.high[index].toDouble(), size);
    double low = getY(quote.low[index].toDouble(), size);
    double open = getY(quote.open[index].toDouble(), size);
    double close = getY(quote.close[index].toDouble(), size);
    double r = candleWidth * scale / 2;
    double lineR = candleLineWidth * scale / 2;

    // 實心 K 線
    if (open > close) {
      _paint.color = upColor;
      canvas.drawRect(Rect.fromLTRB(curX - r, close, curX + r, open), _paint);
      canvas.drawRect(Rect.fromLTRB(curX - lineR, high, curX + lineR, low), _paint);
    } else {
      _paint.color = dnColor;
      canvas.drawRect(Rect.fromLTRB(curX - r, open, curX + r, close), _paint);
      canvas.drawRect(Rect.fromLTRB(curX - lineR, high, curX + lineR, low), _paint);
    }
  }

  // MA 線
  void drawMALine(Canvas canvas, Quote quote, Size size, int count, int startIndex) {
    Path ma5Path = Path();
    Path ma10Path = Path();
    Path ma20Path = Path();
    Path ma30Path = Path();
    // 是否有起點
    bool hasMA5 = false, hasMA10 = false, hasMA20 = false, hasMA30 = false;
    for (var i = 0; i < count; i ++) {
      double ma5 = quote.ma5[startIndex + i];
      double ma10 = quote.ma10[startIndex + i];
      double ma20 = quote.ma20[startIndex + i];
      double ma30 = quote.ma30[startIndex + i];
      double x = (i + 1) * candleSpace * scale - candleSpace * scale / 2;

      if (ma5 != 0) {
        if (hasMA5 == false) {
          ma5Path.moveTo(x, getY(ma5, size));
          hasMA5 = true;
        } {
          ma5Path.lineTo(x, getY(ma5, size));
        }
      }
      if (ma10 != 0) {
        if (hasMA10 == false) {
          ma10Path.moveTo(x, getY(ma10, size));
          hasMA10 = true;
        } {
          ma10Path.lineTo(x, getY(ma10, size));
        }
      }
      if (ma20 != 0) {
        if (hasMA20 == false) {
          ma20Path.moveTo(x, getY(ma20, size));
          hasMA20 = true;
        } {
          ma20Path.lineTo(x, getY(ma20, size));
        }
      }
      if (ma30 != 0) {
        if (hasMA30 == false) {
          ma30Path.moveTo(x, getY(ma30, size));
          hasMA30 = true;
        } {
          ma30Path.lineTo(x, getY(ma30, size));
        }
      }
      _avePaint.color = kValue1Color;
      canvas.drawPath(ma5Path, _avePaint);
      _avePaint.color = kValue2Color;
      canvas.drawPath(ma10Path, _avePaint);
      _avePaint.color = kValue3Color;
      canvas.drawPath(ma30Path, _avePaint);
    }
  }

  double getY(double value, Size size) {
    double d = _maxValue - _minValue;
    double currentD = value - _minValue;
    double p = 1 - currentD / d;
    return size.height * p;
  }

  void getMaxMinValue(Quote quote, Size size, int count, int index) {
    // init max & min
    _maxValue = 0;
    _minValue = double.infinity;

    for (var i = 0; i < count; i++) {
      int currentIndex = index + i;

      _maxValue = [_maxValue, quote.high[currentIndex].toDouble(), quote.ma5[currentIndex],
        quote.ma10[currentIndex], quote.ma20[currentIndex], quote.ma30[currentIndex]].findMax();

      _minValue = [_minValue, quote.low[currentIndex].toDouble(), quote.ma5[currentIndex], quote.ma10[currentIndex],
        quote.ma20[currentIndex], quote.ma30[currentIndex]].findMin();

      _minValue = _minValue < 0 ? 0 : _minValue;
    }
  }

  void drawLeftText(Canvas canvas, Size size) {
    double midValue = (_maxValue + _minValue) / 2;
    TextStyle style = TextStyle(color: Colors.grey, fontSize: leftFontSize);

    TextSpan span = TextSpan(text: _maxValue.toStringAsFixed(2), style: style);
    TextSpan span2 = TextSpan(text: _minValue.toStringAsFixed(2), style: style);
    TextSpan span3 = TextSpan(text: midValue.toStringAsFixed(2), style: style);

    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    TextPainter tp2 = TextPainter(text: span2, textDirection: TextDirection.ltr);
    TextPainter tp3 = TextPainter(text: span3, textDirection: TextDirection.ltr);

    tp.layout();
    tp.paint(canvas, Offset(2, 2));

    tp2.layout();
    tp2.paint(canvas, Offset(2, size.height - 15));

    tp3.layout();
    tp3.paint(canvas, Offset(2, size.height / 2 - 15));
  }

  void drawTopText(Canvas canvas, Quote quote, Size size) {

    // TODO: Press Show

    double ma5 = quote.ma5.last;
    double ma10 = quote.ma10.last;
    double ma30 = quote.ma30.last;

    TextSpan span1 = TextSpan(
        text: "MA5:${ma5.toStringAsFixed(2)}  ",
        style: TextStyle(color: kValue1Color, fontSize: topFontSize)
    );
    TextSpan span2 = TextSpan(
        text: "MA10:${ma10.toStringAsFixed(2)}  ",
        style: TextStyle(color: kValue2Color, fontSize: topFontSize)
    );
    TextSpan span3 = TextSpan(
        text: "MA30:${ma30.toStringAsFixed(2)}  ",
        style: TextStyle(color: kValue3Color, fontSize: topFontSize)
    );
    TextSpan spans = TextSpan(children: [span1, span2, span3]);
    TextPainter tp = TextPainter(text: spans, textDirection: TextDirection.ltr);

    tp.layout();
    tp.paint(canvas, Offset(2, 2));
  }


}