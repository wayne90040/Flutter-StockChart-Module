


import 'dart:math';

import 'package:flutter_stock_chart/quote.dart';


class CalcManager {

  CalcManager._privateConstructor();
  static final CalcManager instance = CalcManager._privateConstructor();

  void calc(Quote quote) {
    calcMA(quote);
    calcVolumeMA(quote);
    calcMACD(quote);
    calcKDJ(quote);
    calcBOLL(quote);
  }

  static void calcMA(Quote quote, [bool isLast = false]) {
    print("calcMA");
    double ma5 = 0.0;
    double ma10 = 0.0;
    double ma20 = 0.0;
    double ma30 = 0.0;

    int i = 0;
    if (isLast && quote.open.length > 1) {
      i = quote.open.length - 1;
      int index = quote.open.length - 2;
      ma5 = quote.ma5[index] * 5;
      ma10 = quote.ma10[index] * 10;
      ma20 = quote.ma20[index] * 20;
      ma30 = quote.ma30[index] * 30;
    }

    for (; i < quote.open.length; i++) {
      final close = quote.close[i];
      ma5 += close;
      ma10 += close;
      ma20 += close;
      ma30 += close;

      if (i == 4) {
        quote.ma5.add(ma5 / 5);
      } else if (i >= 5) {
        ma5 -= quote.close[i - 5];
        quote.ma5.add(ma5 / 5);
      }  else {
        quote.ma5.add(0);
      }

      if (i == 9) {
        quote.ma10.add(ma10 / 10);
      } else if (i >= 10) {
        ma10 -= quote.close[i - 10];
        quote.ma10.add(ma10 / 10);
      }  else {
        quote.ma10.add(0);
      }

      if (i == 19) {
        quote.ma20.add(ma20 / 20);
      } else if (i >= 20) {
        ma20 -= quote.close[i - 20];
        quote.ma20.add(ma20 / 20);
      }  else {
        quote.ma20.add(0);
      }

      if (i == 29) {
        quote.ma30.add(ma30 / 30);
      } else if (i >= 30) {
        ma30 -= quote.close[i - 30];
        quote.ma30.add(ma30 / 30);
      }  else {
        quote.ma30.add(0);
      }
    }
  }

  static void calcVolumeMA(Quote quote, [bool isLast = false]) {
    print("calcVolumeMA");
    double ma5Vol = 0.0;
    double ma10VOl = 0.0;
    int i = 0;
    if (isLast && quote.open.length > 1) {
      i = quote.open.length - 1;
      ma5Vol = quote.ma5Vol[quote.open.length - 2] * 5;
      ma10VOl = quote.ma10Vol[quote.open.length - 2] * 10;
    }

    for (; i < quote.open.length; i++) {
      // Map entry = dataList[i];

      ma5Vol += quote.volume[i];
      ma10VOl += quote.volume[i];

      if (i == 4) {
        quote.ma5Vol.add(ma5Vol / 5);
      } else if (i > 4) {
        ma5Vol -= quote.volume[i - 5];
        quote.ma5Vol.add(ma5Vol / 5);
      } else {
        quote.ma5Vol.add(0);
      }

      if (i == 9) {
        quote.ma10Vol.add(ma10VOl / 10);
      } else if (i > 9) {
        ma10VOl -= quote.volume[i - 10];
        quote.ma10Vol.add(ma10VOl / 10);
      } else {
        quote.ma10Vol.add(0);
      }
    }
  }

  static void calcMACD(Quote quote, [bool isLast = false]) {
    print("calcMACD");
    double ema12 = 0, ema26 = 0, dif = 0, dea = 0, macd = 0;

    int i = 0;

    if (isLast && quote.open.length > 1) {
      i = quote.open.length - 1;
      // var dataMap = dataList[dataList.length - 2];
      int index = quote.open.length - 2;

      dif = quote.dif[index];
      dea = quote.dea[index];
      macd = quote.macd[index];
      ema12 = quote.ema12[index];
      ema26 = quote.ema26[index];
    }

    for (; i < quote.open.length; i++) {
      // Map entity = dataList[i];

      final double closePrice = quote.close[i].toDouble();

      //  EMA（12） = 前一日EMA（12） X 11/13 + 今日收盘价 X 2/13
      ema12 = i == 0 ? closePrice : ema12 * 11 / 13 + closePrice * 2 / 13;
      // EMA（26） = 前一日EMA（26） X 25/27 + 今日收盘价 X 2/27
      ema26 = i == 0 ? closePrice : ema26 * 25 / 27 + closePrice * 2 / 27;

      // DIF = EMA（12） - EMA（26）
      dif = ema12 - ema26;
      // 今日DEA = （前一日DEA X 8/10 + 今日DIF X 2/10）
      dea = dea * 8 / 10 + dif * 2 / 10;
      // 用（DIF-DEA）*2 即为MACD柱状图。
      macd = (dif - dea) * 2;
      quote.dif.add(dif);
      quote.dea.add(dea);
      quote.macd.add(macd);
      quote.ema12.add(ema12);
      quote.ema26.add(ema26);
    }
  }

  static void calcKDJ(Quote quote, [bool isLast = false]) {
    print("calcKDJ");
    double k = 0.0;
    double d = 0.0;

    int i = 0;

    if (isLast && quote.open.length > 1) {
      i = quote.open.length - 1;
      k = quote.k[quote.open.length - 2];
      d = quote.d[quote.open.length - 2];
    }

    for (; i < quote.open.length; i ++) {
      // Map entity = dataList[i];
      double closePrice = quote.close[i].toDouble();

      int startIndex = i - 13;
      if (startIndex < 0) {
        startIndex = 0;
      }
      double max14 = -double.maxFinite;
      double min14 = double.maxFinite;

      for (int index = startIndex; index <= i; index++) {
        max14 = max(max14, quote.high[index].toDouble());
        min14 = min(min14, quote.low[index].toDouble());
      }

      double rsv = 100 * (closePrice - min14) / (max14 - min14);
      if (rsv.isNaN) {
        rsv = 0.0;
      }
      if (i == 0) {
        k = 50;
        d = 50;
      } else {
        k = (rsv + 2 * k) / 3;
        d = (k + 2 * d) / 3;
      }
      if (i < 13) {
        quote.k.add(0.0);
        quote.d.add(0.0);
        quote.j.add(0.0);
      } else if (i == 13 || i == 14) {
        quote.k.add(k);
        quote.d.add(0.0);
        quote.j.add(0.0);
      } else {
        quote.k.add(k);
        quote.d.add(d);
        quote.j.add(3 * k - 2 * d);
      }
    }
  }

  static void calcBOLL(Quote quote, [bool isLast = false]) {
    print("calcBOLL");
    int i = 0;

    if (isLast && quote.open.length > 1) {
      i = quote.open.length - 1;
    }

    for (; i < quote.open.length; i ++) {
      if (i < 19) {
        quote.mb.add(0.0);
        quote.up.add(0.0);
        quote.dn.add(0.0);
      } else {
        int n = 20;
        double md = 0.0;

        for (int j = i - n + 1; j <= i; j++) {
          double c = quote.close[j].toDouble();
          double m = quote.ma20[i];
          double value = c - m;
          md += value * value;
        }
        md = md / (n - 1);
        md = sqrt(md);
        quote.mb.add(quote.ma20[i]);
        quote.up.add(quote.mb[i] + 2 * md);
        quote.dn.add(quote.mb[i] - 2 * md);
      }
    }
  }
}