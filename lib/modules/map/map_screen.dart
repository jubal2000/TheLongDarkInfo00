import 'package:cached_network_image/cached_network_image.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:gesture_zoom_box/gesture_zoom_box.dart';
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
import '../../core/style.dart';
import '../../core/utils.dart';
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
              maxScale: 5.0,
              duration: Duration(milliseconds: 100),
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
                    ...controller.getPinListWidget(),
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
            floatingActionButton: FabCircularMenu(
              alignment: Alignment(1,1.02),
              fabOpenIcon: Icon(Icons.menu, size: controller.iconSize, color: Theme.of(context).colorScheme.inversePrimary),
              fabCloseIcon: Icon(Icons.close, size: controller.iconSize, color: Theme.of(context).colorScheme.inversePrimary),
              fabMargin: EdgeInsets.all(15),
              fabSize: 55,
              fabColor: Theme.of(context).primaryColor,
              ringColor: Theme.of(context).primaryColor.withOpacity(0.25),
              ringDiameter: 300,
              ringWidth: 80,
              children: <Widget>[
                mainMenu(Icons.share, 'LINK', () {
                }, Theme.of(context).colorScheme.secondaryContainer),
                mainMenu(AppData.isRotateLock ? Icons.screen_lock_rotation : Icons.screen_rotation, AppData.isRotateLock ? 'LOCK' : 'UNLOCK', () {
                  setState(() {
                    AppData.isRotateLock = !AppData.isRotateLock;
                    // controller.photoViewController.reset();
                  });
                }, Theme.of(context).colorScheme.secondaryContainer),
                mainMenu(AppData.isShowPlace ? Icons.place_outlined : Icons.clear, AppData.isShowPlace ? 'PIN SHOW' : 'PIN HIDE', () {
                  setState(() {
                    AppData.isShowPlace = !AppData.isShowPlace;
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
            width: controller.iconSize * 2,
            height: controller.iconSize * 2,
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
