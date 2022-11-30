import 'package:get/get.dart';
import 'package:the_long_dark_info/core/utils.dart';

import '../../core/app_data.dart';
import '../../service/api_service.dart';

class HomeController extends GetxController {
  @override
  void onInit() {
    super.onInit();
  }
  final api = Get.find<ApiService>();
  var isMapMode = true;
  var mapScale = 1.0;

  Future<dynamic> getMapData() async {
    return await api.getMapData();
  }
}