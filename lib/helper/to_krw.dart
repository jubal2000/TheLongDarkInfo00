import 'package:intl/intl.dart';

String toKrw({required double amount, required double exchangRate}) {
  final krw = amount * exchangRate;
  return NumberFormat(',###').format(krw) + ' KRW';
}
