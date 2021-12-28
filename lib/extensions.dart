import 'dart:math';

extension ListExtension on List<double> {

  double findMin() => this.reduce(min);

  double findMax() => this.reduce(max);

}