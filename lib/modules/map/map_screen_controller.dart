import 'dart:convert';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../core/app_data.dart';
import '../../core/dialogs.dart';
import '../../core/utils.dart';
import '../../service/api_service.dart';

class MapScreenController extends GetxController {
  final api = Get.find<ApiService>();
  final offset = 20.0;
  final iconSize = 30.0;
  final GlobalKey<FabCircularMenuState> fabKey = GlobalKey();

  JSON targetInfo = {};
  String targetId = '';

  @override
  void onInit() {
    targetInfo = jsonDecode(Get.parameters['data']!);
    targetId = targetInfo['id'] ?? 'id_none';
    LOG('--> targetInfo [$targetId] : ${targetInfo['title']}');
    super.onInit();
  }

  onImageTap(context, detail, value) {
    final dx = detail.localPosition.dx;
    final dy = detail.localPosition.dy;
    LOG('--> onTapUp : $dx, $dy');
    if (AppData.pinData[targetId] == null) {
      AppData.pinData[targetId] = {
        'id': targetId,
        'data': [],
      };
    }
    var pinData = {
      'dx': dx,
      'dy': dy,
      'title': '',
      'desc': '',
    };
    showPinEditDialog(context, targetId, pinData).then((result) {
      LOG('--> pin result : $result');
    });
    LOG('--> ${AppData.pinData[targetId]['data']}');
  }

  searchPinPoint(double x, double y) {
    for (var item in AppData.pinData[targetId]['data']) {
      if (item.dx - offset <= x && item.dx + offset >= x &&
          item.dx - offset <= x && item.dx + offset >= x) {
        LOG('--> find point [$x, $y] : $item');
        return item;
      }
    }
    return null;
  }
}
