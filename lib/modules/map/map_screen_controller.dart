import 'dart:async';
import 'dart:convert';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpers/helpers.dart';
import 'package:the_long_dark_info/core/style.dart';
import 'package:tphoto_view/photo_view.dart';
import 'package:uuid/uuid.dart';

import '../../core/app_data.dart';
import '../../core/common_colors.dart';
import '../../core/dialogs.dart';
import '../../core/utils.dart';
import '../../service/api_service.dart';
import '../../service/local_service.dart';

class MapScreenController extends GetxController {
  final api   = Get.find<ApiService>();
  final local = Get.find<LocalService>();

  final GlobalKey<FabCircularMenuState> fabKey = GlobalKey();
  final PhotoViewController photoViewController = PhotoViewController();
  final offset = 20.0;
  final iconSize = 30.0;

  JSON targetInfo = {};
  String targetId = '';
  var pinSize = 5.0;
  var isDragOn = '';
  var mapScale = 1.0;
  var isLinkEditOn = false;
  JSON linkEditInfo = {};

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

  List<Widget> getPinListWidget(context, onUpdate) {
    List<Widget> result = [];
    if (AppData.pinData[targetId] != null && LIST_NOT_EMPTY(AppData.pinData[targetId]['data'])) {
      for (var item in AppData.pinData[targetId]['data']) {
        var itemId = STR(item['id']);
        var dx = DBL(item['dx']);
        var dy = DBL(item['dy']);
        result.add(
          Positioned(
            left: dx - pinSize * 1.5,
            top:  dy - pinSize * 2.5,
            child: StatefulBuilder(
              builder: (context, setState) {
                Timer? timer;
                return GestureDetector(
                  onTapDown: (_) {
                    LOG('--> onTapDown');
                    timer = Timer.periodic(Duration(seconds: 1), (timer) {
                      LOG('--> onTapDown done');
                      setState(() {
                        timer.cancel();
                        isDragOn = itemId;
                      });
                    });
                  },
                  onTapUp: (_) {
                    if (isDragOn.isEmpty) {
                      showPinEditDialog(context, targetId, item).then((result) {
                        if (result['delete'] != null) {
                          showAlertYesNoDialog(context, 'Delete'.tr, 'Delete this mark?', '', 'Cancel'.tr, 'OK'.tr).then((result2) {
                            if (result2 == 1) {
                              AppData.pinData[targetId]['data'].remove(item);
                              if (onUpdate != null) onUpdate();
                            }
                          });
                        } else {
                          if (onUpdate != null) onUpdate();
                        }
                      });
                    }
                    if (timer != null) {
                      timer!.cancel();
                      timer = null;
                    }
                    setState(() {
                      isDragOn = '';
                    });
                  },
                  onPanCancel: () {
                    setState(() {
                      if (timer != null) {
                        timer!.cancel();
                        timer = null;
                      }
                      isDragOn = '';
                    });
                  },
                  onPanEnd: (_) {
                    LOG('--> onPanEnd');
                    setState(() {
                      if (timer != null) {
                        timer!.cancel();
                        timer = null;
                      }
                      isDragOn = '';
                    });
                  },
                  onPanUpdate: isDragOn.isNotEmpty ? (detail) {
                    item['dx'] = dx + detail.delta.dx * mapScale;
                    item['dy'] = dy + detail.delta.dy * mapScale;
                    LOG('--> onPanUpdate : $dx / $dy - ${detail.delta} * $mapScale -> ${item['dx']} / ${item['dy']}');
                    if (onUpdate != null) onUpdate();
                  } : null,
                  child: showPinMark(context, item, isDragOn.isNotEmpty && isDragOn == itemId),
                );
              }
            )
            // child: LongPressDraggable(
            //   onDragEnd: (detail) {
            //     var offset = detail.offset;
            //     LOG('--> dx org : $dx / $dy - $offset');
            //     item['dx'] = MediaQuery.of(context).size.width + offset.dx;
            //     item['dy'] = MediaQuery.of(context).size.height + offset.dy;
            //     LOG('--> dx pos : ${item['dx']} / ${item['dy']}');
            //     if (onUpdate != null) onUpdate(detail);
            //   },
            //   dragAnchorStrategy: (Draggable<Object> _, BuildContext __, Offset ___) =>
            //     Offset(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
            //   feedback: SizedBox(
            //     width: MediaQuery.of(context).size.width * 2,
            //     height: MediaQuery.of(context).size.height * 2,
            //     child: Stack(
            //       children: [
            //         Center(
            //           child: Container(
            //             width: 2,
            //             height: MediaQuery.of(context).size.height * 2,
            //             color: Colors.red,
            //           ),
            //         ),
            //         Center(
            //           child: Container(
            //             width: MediaQuery.of(context).size.width * 2,
            //             height: 2,
            //             color: Colors.red,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            //   childWhenDragging: showPinMark(item, true),
            //   child: showPinMark(item),
            // )
          )
        );
      }
    }
    return result;
  }

  showPinMark(context, item, [bool isDragOn = false]) {
    var iconIndex = int.parse(STR(item['icon']));
    return Container(
      width:  pinSize * 4,
      height: pinSize * 3,
      // color: Colors.black12,
      child: Stack(
        children: [
          if (STR(item['icon']).isNotEmpty)...[
            if (!AppData.isPinShow)...[
              BottomCenterAlign(
                child: Padding(
                  padding: EdgeInsets.only(bottom: pinSize * 0.5),
                  child: Icon(Icons.circle, size: pinSize * 0.5, color: isDragOn ? Colors.red : COL(item['color'])),
                ),
              )
            ],
            if (AppData.isPinShow)...[
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(STR(item['title']), style: pinTitleStyle, textAlign: TextAlign.center),
                    // Container(
                    //   padding: EdgeInsets.all(1),
                    //   decoration: BoxDecoration(
                    //     color: Colors.white54,
                    //     borderRadius: BorderRadius.all(Radius.circular(1.5)),
                    //   ),
                    //   child: Text(STR(item['title']), style: pinTitleStyle),
                    Stack(
                      children: [
                        Icon(Icons.circle, size: pinSize+1, color: Colors.black),
                        Positioned(
                          left: 0.5,
                          top: 0.5,
                          child: Icon(GameIcons[iconIndex], size: pinSize, color: COL(item['color'])),
                        )
                      ]
                    )
                  ]
                )
              )
            ]
          ],
          if (STR(item.icon).isEmpty)...[
            BottomCenterAlign(
              child: Icon(Icons.circle, size: pinSize * 0.2, color: isDragOn ? Colors.red : COL(item['color'])),
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
                child: Icon(Icons.place, size: pinSize - 1, color: isDragOn ? Colors.red : COL(item['color'])),
              ),
            ]
          ],
        ]
      )
    );
  }

  clearPinMark(context) async {
    var result = await showAlertYesNoDialog(context, 'Clear'.tr, 'Clear this map pin marks?'.tr, '', 'Cancel'.tr, 'OK'.tr);
    if (result == 1) {
      AppData.pinData[targetId]['data'] = [];
      await local.writeLocalData('pinData', AppData.pinData);
      return true;
    }
    return false;
  }

  List<Widget> getLinkListWidget() {
    List<Widget> result = [];
    for (var item in AppData.linkData.entries) {
      LOG('--> getLinkListWidget item : $targetId / ${item.value['targetId']}');
      if (item.value['targetId'] == targetId) {
        result.add(
          Positioned(
            top: DBL(item.value['sy']),
            left: DBL(item.value['sx']),
            child: Container(
              width: DBL(item.value['ex']) - DBL(item.value['sx']),
              height: DBL(item.value['ey']) - DBL(item.value['sy']),
              color: Colors.black45,
            ),
          )
        );
      }
    }
    LOG('--> getLinkListWidget result : ${result.length}');
    return result;
  }

  getLinkEditInfo(detail) {
    var x = detail.localPosition.dx;
    var y = detail.localPosition.dy;
    for (var item in AppData.linkData.entries) {
      LOG('--> linkData item [$targetId] : ${item.value['targetId']} - $x, $y / ${item.value['sx']},${item.value['sy']} x ${item.value['ex']},${item.value['ey']}');
      if (item.value['targetId'] == targetId &&
          item.value['sx'] <= x && item.value['ex'] >= x &&
          item.value['sy'] <= y && item.value['ey'] >= y) {
        var linkId = item.value['linkId'];
        LOG('--> getLinkEditInfo found [$x, $y] : ${item.value['id']} => $linkId');
        return AppData.mapData[linkId] ?? AppData.mapLinkData[linkId];
      }
    }
    return null;
  }

  addLinkEditInfo(context, detail, onUpdate) {
    showLinkSelectDialog(context, targetId, isAll: true).then((result) {
      LOG('--> result : $result');
      if (result != null) {
        linkEditInfo['ex'] = detail.localPosition.dx;
        linkEditInfo['ey'] = detail.localPosition.dy;
        linkEditInfo['targetId'] = targetId;
        linkEditInfo['linkId']   = result['id'];
        api.addLinkData(linkEditInfo).then((addResult) {
          if (addResult != null) {
            AppData.linkData[addResult['id']] = addResult;
            onUpdate();
          }
        });
      }
    });
  }
}
