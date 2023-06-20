import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_long_dark_info/core/utils.dart';

import '../../core/app_data.dart';
import '../../global_widgets/flutter_staggered_grid_view/src/widgets/staggered_grid.dart';
import '../../global_widgets/flutter_staggered_grid_view/src/widgets/staggered_grid_tile.dart';
import '../../routes.dart';
import '../../service/api_service.dart';
import '../app/app_information.dart';

class HomeController extends GetxController {
  @override
  void onInit() {
    super.onInit();
  }
  final api = Get.find<ApiService>();
  var isMapMode = true;
  var mapScale = 1.0;

  Future<dynamic> getMapData() async {
    return await api.getMapDataAll();
  }

  showAppInformation() {
    Get.to(() => AppInformation());
  }

  showMapList() {
    return Container(
        padding: EdgeInsets.fromLTRB(10, mapScale * 10, 10, 10),
        child: StaggeredGrid.count(
          crossAxisCount: 9,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          axisDirection: AxisDirection.down,
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
              child: IceTile(index: 5, title: '잿빛골짜기', mapInfo: AppData.mapData['ash_canyon'], onSelect: onMapSelected),
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
          ],
        )
    );
  }

  onMapSelected(item) {
    LOG('--> item : $item');
    Get.toNamed(Routes.MAP_SCREEN, parameters: PARAMETER_JSON('data', item));
  }
}