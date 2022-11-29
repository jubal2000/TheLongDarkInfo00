import 'package:cached_network_image/cached_network_image.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:helpers/helpers/widgets/align.dart';
import 'package:the_long_dark_info/service/api_service.dart';
import 'package:the_long_dark_info/service/firebase_service.dart';
import 'package:tphoto_view/photo_view.dart';
import 'package:uuid/uuid.dart';

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
        return Scaffold(
          appBar: AppBar(
            title: Text(STR(controller.targetInfo['title_kr'])),
            titleSpacing: 0,
            toolbarHeight: top_height,
          ),
          body: Container(
            child: Stack(
              children: [
                PhotoView(
                  imageProvider: NetworkImage(STR(controller.targetInfo['map_full'])),
                  enableRotation: !AppData.isRotateLock,
                  backgroundDecoration: BoxDecoration(
                    color: Colors.white
                  ),
                  onTapUp: controller.onImageTap,
                ),
                // BottomLeftAlign(
                //   child: FloatingActionButton(
                //     onPressed: () {
                //
                //     },
                //     child: Icon(controller.isRotateLock ? Icons.lock : Icons.lock_open),
                //   ),
                // )
                // ImageZoomOnMove(
                //   width: MediaQuery.of(context).size.width,
                //   height: MediaQuery.of(context).size.height,
                //   image: Image.network(STR(controller.targetInfo['map_full'])),
                //   onTap: () {
                //
                //   },
                // )
              ],
            )
          ),
          floatingActionButton: FabCircularMenu(
            key: controller.fabKey,
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
              mainMenu(Icons.share, '공유', () {
              }, Theme.of(context).colorScheme.secondaryContainer),
              mainMenu(AppData.isRotateLock ? Icons.lock : Icons.lock_open, '회전', () {
                setState(() {
                  AppData.isRotateLock = !AppData.isRotateLock;
                });
              }, Theme.of(context).colorScheme.secondaryContainer),
              Container(
                width: controller.iconSize * 2,
                height: controller.iconSize * 2,
              ),
              // Container(),
              // mainMenu(Icons.notifications_active, 'TEST', () async {
              //   await webViewController!.evaluateJavascript(source: 'window.flutter_inappwebview.callHandler("getUserData","test ok");');
              // }, Theme.of(context).colorScheme.secondaryContainer),
            ]
          ),
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
                  SizedBox(width: 5),
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
