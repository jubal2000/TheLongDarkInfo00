import 'dart:convert';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpers/helpers.dart';
import 'package:tphoto_view/photo_view.dart';
import 'package:uuid/uuid.dart';

import '../../core/app_data.dart';
import '../../core/common_colors.dart';
import '../../core/dialogs.dart';
import '../../core/utils.dart';
import '../../service/api_service.dart';

class MapScreenController extends GetxController {
  final api = Get.find<ApiService>();
  final GlobalKey<FabCircularMenuState> fabKey = GlobalKey();
  final PhotoViewController photoViewController = PhotoViewController();
  final offset = 20.0;
  final pinSize = 10.0;
  final iconSize = 30.0;

  JSON targetInfo = {};
  String targetId = '';

  @override
  void onInit() {
    targetInfo = jsonDecode(Get.parameters['data']!);
    targetId = targetInfo['id'] ?? 'id_none';
    LOG('--> targetInfo [$targetId] : ${targetInfo['title']}');
    super.onInit();
  }

  onImageTap(context, detail) async {
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
    var result = await showPinEditDialog(context, targetId, pinData);
    LOG('--> result : $result');
  }

  List<Widget> getPinListWidget() {
    List<Widget> result = [];
    if (AppData.pinData[targetId] != null && LIST_NOT_EMPTY(AppData.pinData[targetId]['data'])) {
      for (var item in AppData.pinData[targetId]['data']) {
        result.add(
          Positioned(
            left: DBL(item['dx']) - pinSize * 0.5,
            top: DBL(item['dy']) - pinSize,
            child: SizedBox(
              width: pinSize,
              height: pinSize,
              child: Stack(
                children: [
                  BottomCenterAlign(
                    child: Icon(Icons.circle, size: pinSize * 0.2, color: COL(item['color'])),
                  ),
                  if (AppData.isPinShow)...[
                    Icon(Icons.place, size: pinSize, color: Colors.black87),
                    Positioned(
                      left: 2,
                      top: 1.6,
                      child: Icon(Icons.place, size: pinSize - 4, color: Colors.black87),
                    ),
                    Positioned(
                      left: 0.5,
                      top: 0.45,
                      child: Icon(Icons.place, size: pinSize - 1, color: COL(item['color'])),
                    ),
                  ]
                ]
              )
            )
          )
        );
      }
    }
    return result;
  }

  searchPinPoint(double x, double y) {
    for (var item in AppData.pinData[targetId]['data']) {
      if (item.dx - offset <= x && item.dx + offset >= x &&
          item.dy - offset <= y && item.dy + offset >= y) {
        LOG('--> find point [$x, $y] : $item');
        return item;
      }
    }
    return null;
  }
}
