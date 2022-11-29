import 'dart:convert';
import 'dart:io';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:the_long_dark_info/service/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_data.dart';
import '../../core/common_colors.dart';
import '../../core/common_sizes.dart';
import '../../core/style.dart';
import '../../core/utils.dart';
import '../../routes.dart';
import '../app/app_controller.dart';

class Home extends GetView<AppController> {
  Home({Key? key}) : super(key: key);
  final api = Get.find<ApiService>();

  @override
  Widget build(BuildContext context) {
    return  WillPopScope(
      onWillPop: () async => await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text('앱 종료'),
              content: const Text('앱을 종료 하시겠습니까?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text('확인'),
                )
              ]
          );
        }
      ),
      child: SafeArea(
        top: false,
        child: Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                showImage('assets/icons/app_icon_00.png', Size(24,24), Colors.black54),
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
            ],
          ),
          body: Container(
            color: Colors.blueGrey.withOpacity(0.2),
            padding: EdgeInsets.symmetric(horizontal: side_gap_width, vertical: 2),
            child: FutureBuilder(
              future: api.getMapData(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data['error'] == null) {
                    return ListView(
                      children: List<Widget>.of(AppData.mapData.entries.map((item) =>
                        GestureDetector(
                          onTap: () {
                            LOG('--> item : ${item.key}');
                            Get.toNamed(Routes.MAP_SCREEN, parameters: PARAMETER_JSON('data', item.value));
                          },
                          child: Container(
                            height: item_height,
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            margin: EdgeInsets.symmetric(vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(STR(item.value['title_kr']), style: itemTitleStyle, maxLines: 2),
                                    SizedBox(height: 3),
                                    Text(STR(item.value['title']).toString().toUpperCase(), style: itemTitleInfoStyle, maxLines: 2),
                                  ]
                                ),
                                Icon(Icons.arrow_forward_ios, size: 24, color: Colors.black12),
                              ],
                            ),
                          )
                        )
                      )).toList(),
                    );
                  } else {
                    return Container(
                      child: Center(
                        child: Text('no map data'),
                      ),
                    );
                  }
                } else {
                  return CircularProgressIndicator();
                }
              }
            ),
          )
        )
      )
    );
  }

  Widget _buildAppIcon(Widget icon, String label, bool isNotReady, {Function? onSelected}) => Column(
      children: [
        GestureDetector(
          onTap: () {
              if (onSelected != null) onSelected();
          },
          child: Padding(
            padding: const EdgeInsets.all(common_xxs_gap),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(common_radius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(1, 2), // changes position of shadow
                    )
                  ]),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(common_radius),
                  child: icon),
              ),
            )
          ),
          Text(
            label,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ],
      );
}

// Widget _buildAppIcon(Widget icon, String label, bool isNotReady) => Column(
//   children: [
//     Badge(
//       // animationType: BadgeAnimationType.fade,
//       animationDuration: Duration.zero,
//       showBadge: isNotReady,
//       badgeColor: NAVY,
//       shape: BadgeShape.square,
//       borderRadius: BorderRadius.circular(20),
//       badgeContent: Text(
//         '준비중',
//         style: TextStyle(fontSize: 10, color: Colors.white),
//       ),
//       position: BadgePosition(top: 0, end: -5),
//       child: Padding(
//         padding: const EdgeInsets.all(common_xxs_gap),
//         child: Container(
//           width: 60,
//           height: 60,
//           decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(common_radius),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.5),
//                   spreadRadius: 2,
//                   blurRadius: 5,
//                   offset: Offset(1, 2), // changes position of shadow
//                 )
//               ]),
//           child: ClipRRect(
//               borderRadius: BorderRadius.circular(common_radius),
//               child: icon),
//         ),
//       ),
//     ),
//     Text(
//       label,
//       style: TextStyle(color: Colors.grey[700]),
//     ),
//   ],
// );
// }
