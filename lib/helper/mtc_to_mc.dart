import 'package:intl/intl.dart';

String mtcToMc({required double amount, bool onlyString = false}) {
  final mc = amount * 1000;
  return NumberFormat(',###').format(mc) + (onlyString ? '' : ' MC');
}
