import 'package:the_long_dark_info/core/utils.dart';

const SCROLL_SPEED = 250;

class AppData {
  static final AppData _singleton = AppData._internal();
  AppData._internal();

  static JSON startData = {};
  static JSON mapData = {};
  static JSON pinData = {};
  static JSON listSelectData = {};

  static bool isRotateLock = false;
}