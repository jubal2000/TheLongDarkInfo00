import 'dart:convert';
import 'dart:io';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
import '../../service/admob_service.dart';
import '../app/app_controller.dart';
import '../map/map_screen_controller.dart';
import 'home_controller.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State createState() => _HomeState();
}

class _HomeState extends State<Home> {
  BannerAd? _bannerAd; //추가
  final controller = HomeController();

  //배너 광고 생성

  void _createBannerAd() {
    _bannerAd = BannerAd(
      size: AdSize.fullBanner, //배너 사이즈
      adUnitId: AdMobService.bannerAdUnitId!, //광고ID 등록
      listener: AdMobService.bannerAdListener, //리스너 등록
      request: const AdRequest(),
    )..load();
  }

  @override
  void initState() {
    super.initState();
    _createBannerAd(); //추가
  }

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
        child: Scaffold(
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
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: Colors.blueGrey,
              image: DecorationImage(
                image: AssetImage("assets/back/background_01.jpg"),
                fit: BoxFit.fill,
                opacity: 0.5,
              ),
            ),
            child: Column(
              children: [
                Expanded(child:
                ListView(
                  children: [
                    FutureBuilder(
                      future: controller.getMapData(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data['error'] == null) {
                            if (controller.isMapMode) {
                              return GestureZoomBox(
                                  maxScale: 10.0,
                                  duration: Duration(milliseconds: 100),
                                  onScaleChanged: (scale) {
                                    // LOG('--> scale : $scale');
                                    setState(() {
                                      controller.mapScale = scale;
                                    });
                                  },
                                  child: Container(
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
                                          crossAxisCellCount: 3,
                                          mainAxisCellCount: 2,
                                          child: IceTile(index: 1, color: Colors.transparent),
                                        ),
                                        StaggeredGridTile.count(
                                          crossAxisCellCount: 2,
                                          mainAxisCellCount: 2,
                                          child: IceTile(index: 3, title: '블랙록', mapInfo: AppData.mapData['blackrock'], onSelect: onMapSelected),
                                        ),
                                        StaggeredGridTile.count(
                                          crossAxisCellCount: 2,
                                          mainAxisCellCount: 2,
                                          child: IceTile(index: 5, title: 'Ash Canyon', mapInfo: AppData.mapData['ash_canyon'], onSelect: onMapSelected),
                                        ),
                                        StaggeredGridTile.count(
                                          crossAxisCellCount: 2,
                                          mainAxisCellCount: 2,
                                          child: IceTile(index: 8, title: '마운틴 타운', mapInfo: AppData.mapData['mountain_town'], onSelect: onMapSelected),
                                        ),
                                        StaggeredGridTile.count(
                                          crossAxisCellCount: 4,
                                          mainAxisCellCount: 2,
                                          child: IceTile(index: 1, color: Colors.transparent),
                                        ),
                                        StaggeredGridTile.count(
                                          crossAxisCellCount: 1,
                                          mainAxisCellCount: 2,
                                          child: IceTile(index: 6, title: '간수의 길목', mapInfo: AppData.mapData['keepers_pass'], onSelect: onMapSelected),
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
                                          crossAxisCellCount: 2,
                                          mainAxisCellCount: 2,
                                          child: IceTile(index: 9, title: '신비로운 호수', mapInfo: AppData.mapData['mystery_lake'], onSelect: onMapSelected),
                                        ),
                                        StaggeredGridTile.count(
                                          crossAxisCellCount: 2,
                                          mainAxisCellCount: 1,
                                          child: IceTile(index: 15, title: '굽이치는 강', mapInfo: AppData.mapData['winding_river'], onSelect: onMapSelected),
                                        ),
                                        StaggeredGridTile.count(
                                          crossAxisCellCount: 2,
                                          mainAxisCellCount: 2,
                                          child: IceTile(index: 10, title: '행복한 계곡', mapInfo: AppData.mapData['pleasant_valley'], onSelect: onMapSelected),
                                        ),
                                        StaggeredGridTile.count(
                                          crossAxisCellCount: 1,
                                          mainAxisCellCount: 2,
                                          child: IceTile(index: 1, color: Colors.transparent),
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
                                        StaggeredGridTile.count(
                                          crossAxisCellCount: 2,
                                          mainAxisCellCount: 1,
                                          child: IceTile(index: 24, title: '파 레인지 분기점', mapInfo: AppData.mapData['far_range_branch'], onSelect: onMapSelected),
                                        ),
                                        StaggeredGridTile.count(
                                          crossAxisCellCount: 7,
                                          mainAxisCellCount: 1,
                                          child: IceTile(index: 1, color: Colors.transparent),
                                        ),
                                        StaggeredGridTile.count(
                                          crossAxisCellCount: 2,
                                          mainAxisCellCount: 2,
                                          child: IceTile(index: 25, title: '여행자의 교차로', mapInfo: AppData.mapData['transfer_pass'], onSelect: onMapSelected),
                                        ),
                                        StaggeredGridTile.count(
                                          crossAxisCellCount: 2,
                                          mainAxisCellCount: 2,
                                          child: IceTile(index: 26, title: '이별 교차로', mapInfo: AppData.mapData['sundered_pass'], onSelect: onMapSelected),
                                        ),
                                        StaggeredGridTile.count(
                                          crossAxisCellCount: 5,
                                          mainAxisCellCount: 2,
                                          child: IceTile(index: 1, color: Colors.transparent),
                                        ),
                                        StaggeredGridTile.count(
                                          crossAxisCellCount: 2,
                                          mainAxisCellCount: 2,
                                          child: IceTile(index: 27, title: '버려진 활주로', mapInfo: AppData.mapData['forsaken_airfield'], onSelect: onMapSelected),
                                        ),
                                        StaggeredGridTile.count(
                                          crossAxisCellCount: 2,
                                          mainAxisCellCount: 2,
                                          child: IceTile(index: 28, title: '오염 지역', mapInfo: AppData.mapData['zone_of_contamination'], onSelect: onMapSelected),
                                        ),
                                      ],
                                    )
                                  )
                              );
                            } else {
                              return Container(
                                padding: EdgeInsets.all(10),
                                child: StaggeredGrid.count(
                                  crossAxisCount: AppData.isPad ? 3 : 1,
                                  crossAxisSpacing: 4,
                                  mainAxisSpacing: 4,
                                  children: List<Widget>.of(AppData.mapData.entries.map((item) =>
                                    mainListItem(item.value, () {
                                      LOG('--> itemInfo : ${item.value}');
                                      onMapSelected(item.value);
                                    })
                                  )).toList(),
                                )
                              );
                              // return Container(
                              //   padding: EdgeInsets.symmetric(horizontal: 10),
                              //   child: ListView(
                              //     padding: EdgeInsets.symmetric(vertical: 10),
                              //     children: List<Widget>.of(AppData.mapData.entries.map((item) =>
                              //       mainListItem(item.value, () {
                              //         LOG('--> itemInfo : ${item.value}');
                              //         onMapSelected(item.value);
                              //       })
                              //     )).toList(),
                              //   )
                              // );
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
                            width:  Get.size.width,
                            height: Get.size.height - 50,
                            child: Center(
                              child: CircularProgressIndicator()
                            ),
                          );
                        }
                      }
                    ),
                  ]
                )),
                //화면의 하단에 배너 노출
                if (_bannerAd != null)
                  Container(
                    height: 90,
                    color: Colors.black,
                    child: AdWidget(
                      ad: _bannerAd!,
                    ),
                  )
              ]
            )
          )
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
