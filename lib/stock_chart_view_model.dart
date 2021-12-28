
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stock_chart/calc_manager.dart';
import 'package:flutter_stock_chart/quote.dart';

class StockChartViewModel extends ChangeNotifier {

  late final String data;

  Quote? _quote;
  Quote? get quote => _quote;

  int _maxCount = 0;
  int get maxCount => _maxCount;

  static const platform = const MethodChannel('com.wielun.chart/quote');
  
  StockChartViewModel({required this.data }) {
    platform.setMethodCallHandler(_receiveFromHost);
    testReceiveFromHost();
  }

  void testReceiveFromHost() {
    _quote = testQuote;
    _maxCount = _quote!.open.length;
    CalcManager.instance.calc(_quote!);
    notifyListeners();
  }

  Future<void> _receiveFromHost(MethodCall call) async {

    try {

      if (call.method == "fromHostToChart") {
        final String jsonString = call.arguments;
        final Map<String, dynamic> jsonMap = await jsonDecode(jsonString);

        _quote = Quote.fromJson(jsonMap);

        if (_quote == null)
          return;
        CalcManager.instance.calc(_quote!);
        _maxCount = _quote!.open.length;

        notifyListeners();
      }
    } on PlatformException catch (error) {
      print("Error$error");
      print(error);
    }
  }
}