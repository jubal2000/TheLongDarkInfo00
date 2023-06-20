import 'dart:convert';
import 'dart:io';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:the_long_dark_info/service/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_data.dart';
import '../../core/common_colors.dart';
import '../../core/common_sizes.dart';
import '../../core/style.dart';
import '../../core/utils.dart';
import '../../global_widgets/gesture_zoom_box.dart';
import '../../global_widgets/main_list_item.dart';
import '../../routes.dart';
import '../app/app_controller.dart';
import '../map/map_screen_controller.dart';
import 'home_controller.dart';

class Home extends GetView<HomeController> {
  Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  WillPopScope(
      onWillPop: () async => await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('App Exit'.tr),
              content: Text('Are you sure you want to quit the app?'.tr),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Text('Cancel'.tr),
                ),
                TextButton(
                  onPressed: () {
                    if (Platform.isAndroid) {
                      SystemNavigator.pop();
                    } else if (Platform.isIOS) {
                      exit(0);
                    }
                  },
                  child: Text('OK'.tr),
                )
              ]
          );
        }
      ),
      child: SafeArea(
        top: false,
        child: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              appBar: AppBar(
                title: Row(
                  children: [
                    showImage('assets/icons/app_icon_01.png', Size(24,24)),
                    SizedBox(width: 5),
                    Text(
                      'app_title'.tr,
                      style: tapMenuTitleTextStyle,
                    )
                  ],
                ),
                toolbarHeight: top_height,
                automaticallyImplyLeading: false,
                actions: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        controller.isMapMode = true;
                      });
                    },
                    child: Icon(Icons.map_outlined, size: 24, color: controller.isMapMode ? NAVY : Colors.black.withOpacity( 0.35)),
                  ),
                  SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      setState(() {
                        controller.isMapMode = false;
                      });
                    },
                    child: Icon(Icons.view_list_sharp, size: 24, color: !controller.isMapMode ? NAVY : Colors.black.withOpacity( 0.35)),
                  ),
                  SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      controller.showAppInformation();
                    },
                    child: Icon(Icons.info_outline, size: 24),
                  ),
                  SizedBox(width: 20),
                ],
              ),
              body: Container(
                // color: NAVY.shade200,
                decoration: BoxDecoration(
                  color: Colors.blueGrey,
                  image: DecorationImage(
                    image: AssetImage("assets/back/background_01.jpg"),
                    fit: BoxFit.fill,
                    opacity: 0.5,
                  ),
                ),
                child: FutureBuilder(
                  future: controller.getMapData(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data['error'] == null) {
                        if (controller.isMapMode) {
                          return Center(
                            child: GestureZoomBox(
                              maxScale: 10.0,
                              duration: Duration(milliseconds: 100),
                              onScaleChanged: (scale) {
                                // LOG('--> scale : $scale');
                                setState(() {
                                  controller.mapScale = scale;
                                });
                              },
                              child: SizedBox.expand(
                                child: controller.showMapList(),
                              )
                            )
                          );
                        } else {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: ListView(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              children: List<Widget>.of(AppData.mapData.entries.map((item) =>
                                mainListItem(item.value, () {
                                  LOG('--> itemInfo : ${item.value}');
                                  controller.onMapSelected(item.value);
                                })
                              )).toList(),
                            )
                          );
                        }
                      } else {
                        return Container(
                          child: Center(
                            child: Text('no map data'),
                          ),
                        );
                      }
                    } else {
                      return Container(
                        width: Get.size.width,
                        height: Get.size.height - 50,
                        child: Center(
                          child: CircularProgressIndicator()
                        ),
                      );
                    }
                  }
                ),
              )
            );
          }
        )
      )
    );
  }
}