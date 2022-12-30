import 'package:cached_network_image/cached_network_image.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
// import 'package:gesture_zoom_box/gesture_zoom_box.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:helpers/helpers/widgets/align.dart';
import 'package:the_long_dark_info/service/api_service.dart';
import 'package:the_long_dark_info/service/firebase_service.dart';
import 'package:tphoto_view/photo_view.dart';
import 'package:uuid/uuid.dart';
import 'package:zoom_pinch_overlay/zoom_pinch_overlay.dart';

import '../../core/app_data.dart';
import '../../core/common_sizes.dart';
import '../../core/dialogs.dart';
import '../../core/style.dart';
import '../../core/utils.dart';
import '../../global_widgets/gesture_zoom_box.dart';
import '../../routes.dart';
import 'map_screen_controller.dart';

class MapScreen extends GetView<MapScreenController> {
  MapScreen({Key? key}) : super(key: key);
  final api = Get.find<ApiService>();
  final GlobalKey<GestureZoomBoxState> zoomKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: api.getMapDataAll(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            LOG('--> controller.targetId : ${controller.targetId} / ${AppData.mementoData[controller.targetId]}');
            return StatefulBuilder(
              builder: (context, setState) {
                return WillPopScope(
                    onWillPop: () async {
                  if (controller.targetList.length < 2) {
                    Get.back();
                  } else {
                    setState(() {
                      controller.removeTargetInfoLast();
                    });
                  }
                  return false;
                },
                child: SafeArea(
                  top: false,
                  child: Scaffold(
                    appBar: AppBar(
                      title: Text(STR(controller.targetInfo['title_kr'])),
                      titleSpacing: 0,
                      toolbarHeight: top_height,
                      automaticallyImplyLeading: false,
                      leading: GestureDetector(
                        onTap: () {
                          if (controller.targetList.length < 2) {
                            Get.back();
                          } else {
                            setState(() {
                              controller.removeTargetInfoLast();
                            });
                          }
                        },
                        child: Icon(Icons.arrow_back, size: 24),
                      ),
                      actions: [
                        InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: Icon(Icons.home, size: 24),
                        ),
                        SizedBox(width: 10),
                        if (AppData.isDevMode)...[
                          // Row(
                          //     mainAxisAlignment: MainAxisAlignment.start,
                          //     children: [
                          //       Switch(
                          //           value: AppData.isLinkEditMode,
                          //           onChanged: (status) {
                          //             setState(() {
                          //               AppData.isLinkEditMode = status;
                          //               AppData.isMemEditMode = false;
                          //               controller.clearLinkEditInfo();
                          //             });
                          //           }
                          //       ),
                          //       Text(AppData.isLinkEditMode ? 'Link ON' : 'Link OFF', style: itemDescStyle),
                          //       SizedBox(width: 15),
                          //     ]
                          // ),
                          // SizedBox(width: 10),
                          if (AppData.isMemEditMode)...[
                            InkWell(
                              onTap: () {
                                controller.showMementoDialog(context, 0, () {
                                  setState(() {});
                                });
                              },
                              child: Icon(Icons.radar, size: 24),
                            ),
                          ],
                          SizedBox(width: 10),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Switch(
                                    value: AppData.isMemEditMode,
                                    onChanged: (status) {
                                      setState(() {
                                        AppData.isMemEditMode = status;
                                        AppData.isLinkEditMode = false;
                                      });
                                    }
                                ),
                                Text(AppData.isMemEditMode ? 'Mem ON' : 'Mem OFF', style: itemDescStyle),
                                SizedBox(width: 15),
                              ]
                          ),
                          ]
                        ],
                      ),
                      body: Container(
                          decoration: BoxDecoration(
                            color: Colors.blueGrey,
                            image: DecorationImage(
                              image: AssetImage("assets/back/background_01.jpg"),
                              fit: BoxFit.fill,
                              opacity: 0.5,
                            ),
                          ),
                        child: Stack(
                          children: [
                            GestureZoomBox(
                              key: controller.zoomKey,
                              maxScale: 10.0,
                              duration: Duration(milliseconds: 300),
                              onScaleChanged: (scale) {
                                // LOG('--> scale : $scale');
                                setState(() {
                                  controller.mapScale = scale;
                                });
                              },
                              child: Container(
                                height: double.infinity,
                                color: Colors.transparent,
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(bottom: 60),
                                child: Stack(
                                  children: [
                                    GestureDetector(
                                      onTapUp: (detail) {
                                        LOG('--> onTapUp : $detail');
                                        if (AppData.isLinkEditMode) {
                                          if (controller.linkEditStep == 0) {
                                            controller.linkEditInfo['sx'] = detail.localPosition.dx;
                                            controller.linkEditInfo['sy'] = detail.localPosition.dy;
                                            controller.linkEditStep++;
                                          } else if (controller.linkEditStep == 1) {
                                            setState(() {
                                              controller.linkEditInfo['ex'] = detail.localPosition.dx;
                                              controller.linkEditInfo['ey'] = detail.localPosition.dy;
                                              controller.linkEditStep++;
                                              controller.showLinkEditInfo(context, () {
                                                setState((){});
                                              });
                                            });
                                          }
                                        }
                                        if (AppData.isMemEditMode) {
                                          setState(() {
                                            controller.onMementoPositionSet(context, detail, () {
                                              setState(() {});
                                            });
                                          });
                                        }
                                    },
                                    onLongPressStart: (detail) {
                                      LOG('--> onLongPressStart : $detail');
                                      controller.onImageTap(context, detail).then((result) {
                                        setState(() {});
                                      });
                                    },
                                    child: showImageFit(STR(controller.targetInfo['map_full'])),
                                  ),
                                  ...controller.getPinListWidget(context, () {
                                    setState(() {});
                                  }),
                                  ...controller.getLinkListWidget(() {
                                    setState(() {
                                      if (controller.zoomKey.currentState != null) {
                                        LOG('--> resetScaleValue');
                                        var state = controller.zoomKey.currentState as GestureZoomBoxState;
                                        state.resetScaleValue();
                                      }
                                    });
                                  }),
                                  if (AppData.isMementoShow && AppData.mementoData[controller.targetId] != null)
                                    ...controller.showMementoMark(context, () {
                                      setState(() {});
                                    }),
                                  if (AppData.isDevMode)...[
                                    if (controller.linkEditStep == 2)
                                      controller.showLinkListMark(controller.linkEditInfo, null, true),
                                  ]
                                ],
                              ),
                            ),
                              // children: [
                          // PhotoView(
                          //   controller: controller.photoViewController,
                          //   imageProvider: NetworkImage(STR(controller.targetInfo['map_full'])),
                          //   enableRotation: !AppData.isRotateLock,
                          //   backgroundDecoration: BoxDecoration(
                          //     color: Colors.white
                          //   ),
                          //   onTapUp: (context, detail, value) {
                          //     controller.onImageTap(context, detail, value).then((result) {
                          //       setState(() {
                          //       });
                          //     });
                          //   },
                          //   onScaleEnd: (context, detail, value) {
                          //     setState(() {
                          //
                          //     });
                          //   },
                          // ),
                        // ]
                          ),
                          if (AppData.isLinkEditMode && controller.linkEditStep == 2)...[
                            BottomCenterAlign(
                              child: Container(
                                padding: EdgeInsets.fromLTRB(20, 0, 100, 20),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: RoundedButton(
                                        backgroundColor: Colors.indigo,
                                        onPressed: () {
                                          controller.uploadLinkData(context, () {
                                            setState((){
                                              controller.clearLinkEditInfo();
                                            });
                                          });
                                        },
                                        label: 'Upload'.tr,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    SizedBox(
                                      width: 65,
                                      child: RoundedButton(
                                        backgroundColor: Colors.teal,
                                        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                                        onPressed: () {
                                          setState((){
                                            controller.clearLinkEditInfo();
                                          });
                                        },
                                        label: 'Clear'.tr,
                                      )
                                    )
                                  ]
                                )
                              )
                            )
                          ],
                            if (AppData.isMemEditMode)...[
                              BottomCenterAlign(
                                  child: Container(
                                      padding: EdgeInsets.fromLTRB(20, 0, 100, 20),
                                      child: Row(
                                          children: [
                                            Expanded(
                                              child: RoundedButton(
                                                backgroundColor: Colors.indigo,
                                                onPressed: () {
                                                  controller.uploadMementoData(context);
                                                },
                                                label: 'Upload'.tr,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            SizedBox(
                                                width: 65,
                                                child: RoundedButton(
                                                  backgroundColor: Colors.teal,
                                                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                                                  onPressed: () {
                                                    setState((){
                                                      controller.clearMementoInfo();
                                                    });
                                                  },
                                                  label: 'Clear'.tr,
                                                )
                                            )
                                          ]
                                      )
                                  )
                              )
                            ],
                        ]
                      )
                    ),
                    floatingActionButton: controller.isPinNotEmpty() ? FabCircularMenu(
                      fabOpenIcon: Icon(Icons.menu, size: controller.iconSize, color: Theme.of(context).colorScheme.inversePrimary),
                      fabCloseIcon: Icon(Icons.close, size: controller.iconSize, color: Theme.of(context).colorScheme.inversePrimary),
                      fabMargin: EdgeInsets.all(15),
                      fabSize: 55,
                      fabColor: Theme.of(context).primaryColor,
                      ringColor: Theme.of(context).primaryColor.withOpacity(0.2),
                      ringDiameter: 280,
                      ringWidth: 60,
                      children: <Widget>[
                        mainMenu(Icons.share, 'LINK'.tr, () {
                          showLinkSelectDialog(context, controller.targetId).then((itemInfo) {
                            LOG('--> itemInfo : $itemInfo');
                            if (itemInfo != null) {
                              setState(() {
                                controller.targetInfo = itemInfo;
                                controller.targetId = itemInfo['id'] ?? 'id_none';
                              });
                              // Get.toNamed(Routes.MAP_SCREEN, parameters: PARAMETER_JSON('data', itemInfo));
                            }
                          });
                        }, Theme.of(context).colorScheme.secondaryContainer),
                        mainMenu(Icons.cleaning_services_outlined, 'CLEAR'.tr, () {
                          controller.clearPinMark(context).then((result) {
                            setState(() {});
                          });
                        }, Theme.of(context).colorScheme.secondaryContainer),
                        mainMenu(AppData.isPinShow ? Icons.visibility_outlined : Icons.visibility_off_outlined, AppData.isPinShow ? 'SHOW'.tr : 'HIDE'.tr, () {
                          setState(() {
                            AppData.isPinShow = !AppData.isPinShow;
                            // controller.photoViewController.reset();
                          });
                        }, Theme.of(context).colorScheme.secondaryContainer),
                      ]
                    ) : FloatingActionButton(
                        onPressed: () {
                          showLinkSelectDialog(context, controller.targetId).then((itemInfo) {
                            LOG('--> itemInfo : $itemInfo');
                            if (itemInfo != null) {
                              setState(() {
                                controller.targetInfo = itemInfo;
                                controller.targetId = itemInfo['id'] ?? 'id_none';
                              });
                              // Get.toNamed(Routes.MAP_SCREEN, parameters: PARAMETER_JSON('data', itemInfo));
                            }
                          });
                        },
                        child: Icon(Icons.share),
                    ),
                  )
                )
              );
            }
          );
        } else {
          return showLoadingCircleSquare(50);
        }
      }
    );
  }

  Widget mainMenu(icon, title, onTap, [backColor = Colors.transparent]) {
    return GestureDetector(
        child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: backColor,
              borderRadius: BorderRadius.all(Radius.circular(60)),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white),
                  SizedBox(height: 2),
                  Text(title, style: menuItemTitleStyle)
                ]
            )
        ),
        onTap: () {
          onTap();
        }
    );
  }
}
