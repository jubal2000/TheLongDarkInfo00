import 'package:flutter/material.dart';
import 'package:the_long_dark_info/core/utils.dart';

const SCROLL_SPEED = 250;

class AppData {
  static final AppData _singleton = AppData._internal();
  AppData._internal();

  static JSON startData = {};
  static JSON mapData = {};
  static JSON mapLinkData = {};
  static JSON mapInsideData = {};
  static JSON pinData = {};
  static JSON linkData = {};
  static JSON listSelectData = {};

  static bool isPinShow = true;
  static bool isEditMode = true;
}

const GameIcons = [
  Icons.place,
  Icons.account_circle,
  Icons.access_time,
  Icons.access_alarm,
  Icons.ac_unit,
  Icons.accessibility,
  Icons.account_balance,
  Icons.add_circle,
  Icons.add,
  Icons.back_hand,
  Icons.battery_charging_full,
  Icons.cabin,
  Icons.camera_alt,
  Icons.delete_forever,
  Icons.dangerous,
  Icons.dangerous_outlined,
  Icons.edit,
  Icons.eco_rounded,
  Icons.favorite,
  Icons.factory,
  Icons.feedback,
  Icons.festival,
  Icons.garage,
  Icons.gite,
  Icons.gpp_good_rounded,
  Icons.grade,
  Icons.handyman,
  Icons.health_and_safety,
  Icons.info,
  Icons.key_outlined,
  Icons.king_bed,
  Icons.label,
  Icons.landscape,
  Icons.lens_rounded,
  Icons.map,
  Icons.new_releases,
  Icons.near_me_rounded,
  Icons.offline_bolt,
  Icons.park,
  Icons.question_mark,
  Icons.radar,
  Icons.ramen_dining,
  Icons.recycling,
  Icons.verified_sharp,
  Icons.warehouse_rounded,
  Icons.water_damage,
  Icons.water_drop,
  Icons.wb_cloudy,
  Icons.wb_incandescent,
  Icons.wb_sunny,
  Icons.yard,
  Icons.directions_car,
  Icons.directions_run,
  Icons.directions_walk,
  Icons.hotel,
  Icons.home_repair_service,
  Icons.liquor,
  Icons.local_airport,
  Icons.add_location,
  Icons.store,
  Icons.forest,
  Icons.hardware,
  Icons.fastfood_rounded,
  Icons.dining_rounded,
  Icons.door_back_door,
];