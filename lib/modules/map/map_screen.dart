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

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return SafeArea(
          top: false,
          child: Scaffold(
            appBar: AppBar(
              title: Text(STR(controller.targetInfo['title_kr'])),
              titleSpacing: 0,
              toolbarHeight: top_height,
            ),
            body: GestureZoomBox(
              maxScale: 10.0,
              duration: Duration(milliseconds: 100),
              onScaleChanged: (scale) {
                // LOG('--> scale : $scale');
                controller.mapScale = scale;
              },
              child: Center(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTapUp: (detail) {
                        LOG('--> detail : ${detail.localPosition}');
                        controller.onImageTap(context, detail).then((result) {
                          setState(() {
                          });
                        });
                      },
                      child: showImageFit(STR(controller.targetInfo['map_full'])),
                    ),
                    ...controller.getPinListWidget(context, (detail) {
                      setState(() {
                      });
                    }),
                  ],
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
            )
            ),
            floatingActionButton: FabCircularMenu(
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
                if (AppData.mapData[controller.targetId] != null && LIST_NOT_EMPTY(AppData.mapData[controller.targetId]['insideData']))
                  mainMenu(Icons.star_border, 'OBJECT'.tr, () {
                    showLinkSelectDialog(context, controller.targetId, isInside: true).then((itemInfo) {
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
                    setState(() {
                    });
                  });
                }, Theme.of(context).colorScheme.secondaryContainer),
                mainMenu(AppData.isPinShow ? Icons.visibility_outlined : Icons.visibility_off_outlined, AppData.isPinShow ? 'SHOW'.tr : 'HIDE'.tr, () {
                  setState(() {
                    AppData.isPinShow = !AppData.isPinShow;
                    // controller.photoViewController.reset();
                  });
                }, Theme.of(context).colorScheme.secondaryContainer),
              ]
            ),
          )
        );
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
