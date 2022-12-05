import 'dart:convert';
import 'dart:io';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        controller.isMapMode = true;
                      });
                    },
                    child: Icon(Icons.map_outlined, size: 24, color: controller.isMapMode ? NAVY : Colors.black.withOpacity( 0.35)),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        controller.isMapMode = false;
                      });
                    },
                    child: Icon(Icons.view_list_sharp, size: 24, color: !controller.isMapMode ? NAVY : Colors.black.withOpacity( 0.35)),
                  ),
                  SizedBox(width: 20),
                ],
              ),
              body: Container(
                color: NAVY.shade100,
                // decoration: BoxDecoration(
                //   image: DecorationImage(
                //     image: AssetImage("assets/back/background_01.png"),
                //     repeat: ImageRepeat.repeat,
                //     scale: 2,
                //   ),
                // ),
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
                              child: Container(
                                height: MediaQuery.of(context).size.height,
                              padding: EdgeInsets.fromLTRB(10, controller.mapScale * 10, 10, 10),
                              child: StaggeredGrid.count(
                                crossAxisCount: 9,
                                crossAxisSpacing: 4,
                                mainAxisSpacing: 4,
                                children: [
                                  StaggeredGridTile.count(
                                    crossAxisCellCount: 2,
                                    mainAxisCellCount: 2,
                                    child: IceTile(index: 0, title: '고요한강 협곡', mapInfo: AppData.mapData['hushed_river_valley'], onSelect: onMapSelected),
                                  ),
                                  StaggeredGridTile.count(
                                    crossAxisCellCount: 1,
                                    mainAxisCellCount: 1,
                                    child: IceTile(index: 1, color: Colors.transparent),
                                  ),
                                  StaggeredGridTile.count(
                                    crossAxisCellCount: 1,
                                    mainAxisCellCount: 1,
                                    child: IceTile(index: 2, color: Colors.transparent),
                                  ),
                                  StaggeredGridTile.count(
                                    crossAxisCellCount: 2,
                                    mainAxisCellCount: 2,
                                    child: IceTile(index: 3, title: '블랙록', mapInfo: AppData.mapData['blackrock'], onSelect: onMapSelected),
                                  ),
                                  StaggeredGridTile.count(
                                    crossAxisCellCount: 1,
                                    mainAxisCellCount: 1,
                                    child: IceTile(index: 4, color: Colors.transparent),
                                  ),
                                  StaggeredGridTile.count(
                                    crossAxisCellCount: 2,
                                    mainAxisCellCount: 2,
                                    child: IceTile(index: 5, title: '잿빛협곡', mapInfo: AppData.mapData['ash_canyon'], onSelect: onMapSelected),
                                  ),
                                  StaggeredGridTile.count(
                                    crossAxisCellCount: 2,
                                    mainAxisCellCount: 1,
                                    child: IceTile(index: 6, title: '간수의 길목', mapInfo: AppData.mapData['keepers_pass'], onSelect: onMapSelected),
                                  ),
                                  StaggeredGridTile.count(
                                    crossAxisCellCount: 1,
                                    mainAxisCellCount: 1,
                                    child: IceTile(index: 7, color: Colors.transparent),
                                  ),
                                  StaggeredGridTile.count(
                                    crossAxisCellCount: 2,
                                    mainAxisCellCount: 2,
                                    child: IceTile(index: 8, title: '마운틴 타운', mapInfo: AppData.mapData['mountain_town'], onSelect: onMapSelected),
                                  ),
                                  StaggeredGridTile.count(
                                    crossAxisCellCount: 2,
                                    mainAxisCellCount: 2,
                                    child: IceTile(index: 9, title: '신비로운 호수', mapInfo: AppData.mapData['mystery_lake'], onSelect: onMapSelected),
                                  ),
                                  StaggeredGridTile.count(
                                    crossAxisCellCount: 3,
                                    mainAxisCellCount: 2,
                                    child: IceTile(index: 10, title: '행복한 계곡', mapInfo: AppData.mapData['pleasant_valley'], onSelect: onMapSelected),
                                  ),
                                  StaggeredGridTile.count(
                                    crossAxisCellCount: 2,
                                    mainAxisCellCount: 2,
                                    child: IceTile(index: 11, title: '팀버울프산', mapInfo: AppData.mapData['timberwolf_mountain'], onSelect: onMapSelected),
                                  ),
                                  StaggeredGridTile.count(
                                    crossAxisCellCount: 2,
                                    mainAxisCellCount: 2,
                                    child: IceTile(index: 12, title: '쓸쓸한 들판', mapInfo: AppData.mapData['forlorn_muskeg'], onSelect: onMapSelected),
                                  ),
                                  StaggeredGridTile.count(
                                    crossAxisCellCount: 1,
                                    mainAxisCellCount: 1,
                                    child: IceTile(index: 13, color: Colors.transparent),
                                  ),
                                  StaggeredGridTile.count(
                                    crossAxisCellCount: 1,
                                    mainAxisCellCount: 1,
                                    child: IceTile(index: 14, color: Colors.transparent),
                                  ),
                                  StaggeredGridTile.count(
                                    crossAxisCellCount: 1,
                                    mainAxisCellCount: 2,
                                    child: IceTile(index: 15, title: '굽이치는 강', mapInfo: AppData.mapData['winding_river'], onSelect: onMapSelected),
                                  ),
                                  StaggeredGridTile.count(
                                    crossAxisCellCount: 2,
                                    mainAxisCellCount: 2,
                                    child: IceTile(index: 16, color: Colors.transparent),
                                  ),
                                  StaggeredGridTile.count(
                                    crossAxisCellCount: 2,
                                    mainAxisCellCount: 2,
                                    child: IceTile(index: 17, color: Colors.transparent),
                                  ),
                                  StaggeredGridTile.count(
                                    crossAxisCellCount: 2,
                                    mainAxisCellCount: 1,
                                    child: IceTile(index: 18, title: '산골짜기', mapInfo: AppData.mapData['ravine'], onSelect: onMapSelected),
                                  ),
                                  StaggeredGridTile.count(
                                    crossAxisCellCount: 2,
                                    mainAxisCellCount: 2,
                                    child: IceTile(index: 19, title: '망가진 철도', mapInfo: AppData.mapData['broken_railroad'], onSelect: onMapSelected),
                                  ),
                                  StaggeredGridTile.count(
                                    crossAxisCellCount: 2,
                                    mainAxisCellCount: 2,
                                    child: IceTile(index: 20, title: '블랙인랫', mapInfo: AppData.mapData['bleak_inlet'], onSelect: onMapSelected),
                                  ),
                                  StaggeredGridTile.count(
                                    crossAxisCellCount: 2,
                                    mainAxisCellCount: 2,
                                    child: IceTile(index: 21, title: '해안 고속도로', mapInfo: AppData.mapData['coastal_highway'], onSelect: onMapSelected),
                                  ),
                                  StaggeredGridTile.count(
                                    crossAxisCellCount: 1,
                                    mainAxisCellCount: 2,
                                    child: IceTile(index: 22, title: '무너저가는 고속도로', mapInfo: AppData.mapData['crumbling_highway'], onSelect: onMapSelected),
                                  ),
                                  StaggeredGridTile.count(
                                    crossAxisCellCount: 2,
                                    mainAxisCellCount: 2,
                                    child: IceTile(index: 23, title: '황량한 해안', mapInfo: AppData.mapData['desolation_point'], onSelect: onMapSelected),
                                  ),
                                ],
                              )
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
                                    onMapSelected(item.value);
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
                        return CircularProgressIndicator();
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

  onMapSelected(item) {
    LOG('--> item : $item');
    Get.toNamed(Routes.MAP_SCREEN, parameters: PARAMETER_JSON('data', item));
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
