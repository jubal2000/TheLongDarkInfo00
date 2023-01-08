import 'dart:async';
import 'dart:convert';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpers/helpers.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:the_long_dark_info/core/style.dart';
import 'package:the_long_dark_info/global_widgets/card_scroll_viewer.dart';
import 'package:the_long_dark_info/global_widgets/image_list_viewer.dart';
import 'package:tphoto_view/photo_view.dart';
import 'package:uuid/uuid.dart';
import 'dart:math' as math;


import '../../core/app_data.dart';
import '../../core/common_colors.dart';
import '../../core/dialogs.dart';
import '../../core/utils.dart';
import '../../global_widgets/arrow_painter.dart';
import '../../global_widgets/gesture_zoom_box.dart';
import '../../global_widgets/image_scroll_viewer.dart';
import '../../service/api_service.dart';
import '../../service/local_service.dart';

class MapScreenController extends GetxController {
  final api   = Get.find<ApiService>();
  final local = Get.find<LocalService>();

  final GlobalKey<FabCircularMenuState> fabKey = GlobalKey();
  final GlobalKey<GestureZoomBoxState> zoomKey = GlobalKey();
  final PhotoViewController photoViewController = PhotoViewController();
  final offset = 20.0;
  final iconSize = 30.0;

  List<JSON> targetList = [];
  JSON targetInfo = {};
  String targetId = '';
  var targetIndex = 0;

  var pinSize = 5.0;
  var isDragOn = '';
  var mapScale = 1.0;
  var linkEditStep = 0;
  JSON linkEditInfo = {};

  var  mementoIndex = 0;
  final mementoMax = 2;

  var memTypeN = ['start', 'end'];

  @override
  void onInit() {
    targetId = '';
    targetIndex = 0;
    targetList.clear();
    addTargetInfo(jsonDecode(Get.parameters['data']!));
    super.onInit();
  }

  addTargetInfo(JSON info) {
    targetInfo = info;
    targetId = targetInfo['id'] ?? 'id_none';
    targetList.add(targetInfo);
    targetIndex++;
    LOG('--> addTargetInfo [$targetIndex] : $targetId / ${STR(targetInfo['title'])} / ${targetList.length}');
  }

  removeTargetInfoLast() {
    if (targetList.isEmpty) return;
    targetList.removeLast();
    targetInfo = targetList.last;
    targetId = targetInfo['id'] ?? 'id_none';
    targetIndex--;
    LOG('--> removeTargetInfoLast [$targetIndex] : $targetId / ${STR(targetInfo['title'])} / ${targetList.length}');
  }

  onImageTap(context, detail) async {
    final dx = detail.localPosition.dx;
    final dy = detail.localPosition.dy;
    LOG('--> onImageTap : $dx, $dy');
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

  clearMementoInfo() {
    mementoIndex = 0;
    if (AppData.mementoData[targetId] == null) {
      var addData = {
        'id': targetId,
        'status': 1,
        'data': [],
        'createTime': CURRENT_SERVER_TIME()
      };
      AppData.mementoData[targetId] = FROM_SERVER_DATA(addData);
    }
    // clear data..
    AppData.mementoData[targetId]['data'] = List.generate(2, (index) => {
      'start': {
        'x': -1,
        'y': -1,
        'desc': '',
        'image': [],
      },
      'end': {
        'x': -1,
        'y': -1,
        'desc': '',
        'image': [],
      },
      'reward': '',
      'interloper': '',
    });
  }

  onMementoPositionSet(context, detail, onChanged) {
    LOG('--> onMementoPositionSet [$targetId] : $mementoIndex');
    if (mementoIndex >= mementoMax) mementoIndex = 0;
    if (!AppData.mementoData.containsKey(targetId)) {
      clearMementoInfo();
    }
    var item = AppData.mementoData[targetId]['data'][mementoIndex];
    if (DBL(item['start']['x']) <= 0 && DBL(item['start']['y']) <= 0) {
      item['start']['x'] = detail.localPosition.dx;
      item['start']['y'] = detail.localPosition.dy;
    } else {
      item['end']['x'] = detail.localPosition.dx;
      item['end']['y'] = detail.localPosition.dy;
      mementoIndex++;
    }
    LOG('--> $item');
  }

  showMementoDialog(context, index, onUpdate) {
    var editData = List<JSON>.from(AppData.mementoData[targetId]['data']);
    showMementoEditDialog(context, targetId, editData, index).then((result) {
      if (result != null) {
        if (result.containsKey('delete')) {
          showAlertYesNoDialog(context, 'Delete'.tr, 'Delete now?', '', 'Cancel'.tr, 'OK'.tr).then((dResult) {
            if (dResult == 1) {
              clearMementoInfo();
              onUpdate();
            }
          });
        } else {
          AppData.mementoData[targetId]['data'] = result['result'];
          onUpdate();
        }
      }
    });
  }

  uploadMementoData(context) {
    LOG('--> uploadMementoData ready [$targetId] : ${AppData.mementoData[targetId]['data']}');
    showLoadingDialog(context, 'Uploading now...'.tr);
    Future.delayed(Duration(milliseconds: 200), () {
      // AppData.mementoData[targetId]['data'].forEach((item) {
      //   typeN.map((type) async {
      //     LOG('--> $type : ${item[type]['imageLocal']}');
      //   if (item[type]['imageLocal'] != null) {
      //       var imageData = await ReadFileByte(item[type]['imageLocal']);
      //       JSON imageInfo = {'id': Uuid().v1().toString(), 'image': imageData};
      //       var path = await api.uploadImageData(imageInfo, 'memento_img');
      //       item[type]['image'] = path;
      //       item[type].delete('imageLocal');
      //     }
      //   });
      // });
      // LOG('--> uploadMementoData start [$targetId] : ${AppData.mementoData[targetId]}');
      api.addMementoData(AppData.mementoData[targetId]).then((upResult) {
        if (upResult != null) {
          AppData.mementoData[targetId] = upResult;
        }
        Navigator.of(dialogContext!).pop();
      });
    });
  }

  showMementoMark(context, onUpdate) {
    return List.generate(2, (index) {
      var item = AppData.mementoData[targetId]['data'][index];
      LOG('--> showMementoMark [$index] : $item');
      var sx = DBL(item['start']['x']);
      var sy = DBL(item['start']['y']);
      var dx = DBL(item['end']['x']);
      var dy = DBL(item['end']['y']);
      return Stack(
        children: [
          if (AppData.isMementoShow)...[
            if (sx > 0 && sy > 0 && dx > 0 && dy > 0)...[
              IgnorePointer(
                  child: CustomPaint(
                    size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
                    painter: ArrowPainter([ArrowPainterItem(sx, sy, dx, dy, Colors.red)]),
                  )
              ),
            ],
            if (sx > 0 && sy > 0)...[
              showMementoPin(context, 'start', index, onUpdate),
              if (dx > 0 && dy > 0)...[
                showMementoPin(context, 'end', index, onUpdate),
              ]
            ],
          ],
        ]
      );
    });
  }

  showMementoPin(context, type, index, onUpdate) {
    var item = AppData.mementoData[targetId]['data'][index];
    var sx = DBL(item[type]['x']);
    var sy = DBL(item[type]['y']);
    return Positioned(
      top: sy - 11,
      left: sx - 6,
      child: GestureDetector(
        onTap: () {
          if (!AppData.isMemEditMode) {
            showMementoInfo(context, type, item[type], STR(item['reward']));
          }
        },
        onPanStart: (detail) {
          if (AppData.isMemEditMode) {
            isDragOn = '{$targetId}_$index';
          }
        },
        onPanUpdate: (detail) {
          if (isDragOn.isEmpty) return;
          item[type]['x'] += detail.delta.dx;
          item[type]['y'] += detail.delta.dy;
          onUpdate();
        },
        onPanEnd: (detail) {
          isDragOn = '';
        },
        child: Stack(
          children: [
            // Positioned(
            //   left: -1,
            //   top: -0.85,
            //   child: Icon(type == 'start' ?  Icons.place : Icons.place, size: 14, color: Colors.black),
            // ),
            // Positioned(
            //   left: 1,
            //   top: 0.85,
            //   child: Icon(Icons.circle, size: 8, color: Colors.black),
            // ),
            Icon(type == 'start' ?  Icons.place_rounded : Icons.place_rounded, size: 12, color: Colors.black),
            Icon(type == 'start' ?  Icons.place_outlined : Icons.place_outlined, size: 12, color: index == 0 ? Colors.yellow : Colors.orange),
          ],
        ),
      ),
    );
  }

  showMementoInfo(context, type, data, reward) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        var imageData = List.from(data['image']).map((item) => 'assets/memento/$item.png').toList();
        return Container(
          height: 240,
          width: double.infinity,
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('MEMENTO'.tr, style: itemTitleStyle),
              SizedBox(height: 20),
              if (imageData.isNotEmpty)...[
                ImageListViewer(
                  imageData,
                  itemHeight: 40,
                  itemWidth: 40,
                  onActionCallback: (index, status) {
                    if (index >= 0) {
                      showImageSlideDialog(context, imageData, index);
                    }
                  }
                ),
                SizedBox(height: 10),
              ],
              if (type == 'start')...[
                Row(
                  children: [
                    Icon(Icons.sticky_note_2_outlined, size: 24),
                    SizedBox(width: 5),
                    Text('Note'.tr, style: itemSubTitleStyle),
                  ],
                )
              ],
              if (type != 'start')...[
                Row(
                  children: [
                    Icon(Icons.feedback_outlined, size: 24),
                    SizedBox(width: 5),
                    Text('Object'.tr, style: itemSubTitleStyle),
                  ],
                ),
              ],
              SizedBox(height: 10),
              Text(DESC(data['desc']), style: itemDescStyle),
              if (reward.isNotEmpty)...[
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.card_giftcard, size: 24),
                    SizedBox(width: 5),
                    Text('Reward'.tr, style: itemSubTitleStyle),
                  ],
                ),
                SizedBox(height: 10),
                Text(reward, style: itemDescStyle),
              ]
            ],
          ),
        );
      },
    );
  }

  uploadPinData(context) {

  }

  List<Widget> getPinListWidget(context, onUpdate) {
    List<Widget> result = [];
    if (isPinNotEmpty()) {
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
          if (STR(item['icon']).isEmpty)...[
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

  List<Widget> getLinkListWidget(Function()? onSelected) {
    List<Widget> result = [];
    for (var item in AppData.linkData.entries) {
      // LOG('--> getLinkListWidget item : $targetId / ${item.value['targetId']}');
      if (item.value['targetId'] == targetId) {
        result.add(showLinkListMark(item.value, onSelected, false, AppData.isLinkEditMode));
      }
    }
    // LOG('--> getLinkListWidget result : ${result.length}');
    return result;
  }

  isPinNotEmpty() {
    return AppData.pinData[targetId] != null && LIST_NOT_EMPTY(AppData.pinData[targetId]['data']);
  }

  // showLinkListMark(item, Function()? onSelected, [bool isAddMode = false, bool isLinkEditMode = false]) {
  //   return Positioned(
  //     top: DBL(item['sy']),
  //     left: DBL(item['sx']),
  //     child: Container(
  //       width: DBL(item['ex']) - DBL(item['sx']),
  //       height: DBL(item['ey']) - DBL(item['sy']),
  //       color: isAddMode ? Colors.green.withOpacity(0.75) : isLinkEditMode ? Colors.black45 : Colors.black12,
  //       child: Center(
  //         child: isLinkEditMode ? Text(STR(item['linkTitle_kr']), style: pinEditTitleStyle) : Container(),
  //       )
  //     ),
  //   );
  // }

  showLinkListMark(item, Function()? onSelected, [bool isAddMode = false, bool isLinkEditMode = false]) {
    return Positioned(
      top: DBL(item['sy']),
      left: DBL(item['sx']),
      child: PointerInterceptor(
        child: GestureDetector(
          onTap: () {
            if (AppData.isLinkEditMode || AppData.isMemEditMode) return;
            var linkId = item['linkId'];
            LOG('--> link touched : $linkId');
            var targetInfo = AppData.mapData[linkId] ?? AppData.mapLinkData[linkId] ?? AppData.mapInsideData[linkId];
            if (targetInfo != null) {
              addTargetInfo(targetInfo);
              if (onSelected != null) onSelected();
            }
          },
          child: Container(
            width: DBL(item['ex']) - DBL(item['sx']),
            height: DBL(item['ey']) - DBL(item['sy']),
            color: isAddMode ? Colors.green.withOpacity(0.75) : isLinkEditMode ? Colors.black45 : Colors.black12,
            child: Center(
              child: Column(
                children: [
                  isAddMode || isLinkEditMode ? Text(STR(item['linkTitle_kr']), style: pinEditTitleStyle) : Container(),
                  isLinkEditMode ? Text(STR(item['id']).toString().substring(0, 3), style: pinEditTitleStyle) : Container(),
                ]
              )
            )
          ),
        ),
      )
    );
  }

  showLinkListMarkEx(item, [bool isAddMode = false, bool isLinkEditMode = false, Function(JSON)? onChanged]) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Stack(
          children: [
            Positioned(
              top: DBL(item['sy']),
              left: DBL(item['sx']),
              child: Container(
                width: DBL(item['ex']) - DBL(item['sx']),
                height: DBL(item['ey']) - DBL(item['sy']),
                color: isLinkEditMode ? Colors.green.withOpacity(0.75) : Colors.black45,
              ),
            ),
            Positioned(
              top: DBL(item['sy']) - 5,
              left: DBL(item['sx']) - 5,
              child: Stack(
                children: [
                  GestureDetector(
                    onPanUpdate: (detail) {
                      setState(() {
                        item['sx'] = detail.localPosition.dx;
                        item['sy'] = detail.localPosition.dy;
                      });
                    },
                    child: Container(
                      width: DBL(item['ex']) - DBL(item['sx']) + 10,
                      height: DBL(item['ey']) - DBL(item['sy']) + 10,
                      color: isAddMode ? Colors.green.withOpacity(0.75) : isLinkEditMode ? Colors.black45 : Colors.black12,
                    ),
                  ),
                  Positioned(
                      left: 0,
                      top: 0,
                      child: GestureDetector(
                        child: Icon(Icons.circle, size: 10, color: Colors.redAccent),
                      )
                  ),
                  Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        child: Icon(Icons.circle, size: 10, color: Colors.blueAccent),
                      )
                  )
                ]
              )
            ),
          ]
        );
      }
    );
  }

  getLinkEditInfo(detail) {
    var x = detail.localPosition.dx;
    var y = detail.localPosition.dy;
    LOG('--> getLinkEditInfo : ${AppData.linkData.length}');
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

  uploadLinkData(context, onUpdate) {
    api.addLinkData(linkEditInfo).then((addResult) {
      if (addResult != null) {
        AppData.linkData[addResult['id']] = addResult;
        onUpdate();
      }
    });
  }

  showLinkEditInfo(context, onUpdate) {
    showLinkSelectDialog(context, targetId, isAll: true).then((result) {
      LOG('--> showLinkEditInfo result : $result');
      if (result != null) {
        linkEditInfo['targetId']      = targetId;
        linkEditInfo['linkId']        = result['id'];
        linkEditInfo['linkTitle']     = result['subTitle'] ?? result['title'];
        linkEditInfo['linkTitle_kr']  = result['subTitle_kr'] ?? result['title_kr'];
        onUpdate();
      }
    });
  }

  clearLinkEditInfo() {
    linkEditStep = 0;
    linkEditInfo = {};
  }
}
