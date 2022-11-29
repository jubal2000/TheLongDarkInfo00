import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AppController extends GetxController {
  @override
  void onInit() {
    ever(selectedTabIndex, (value) {
      if (value == 1) {
        //멀티월렛 탭이면
      }
      if (value == 2) {
        //페이로전송 탭이면
      }
      if (value == 3) {
        //거래내역 탭이면
      }
      if (value != 4) {
        //설정탭이 아닐 경우만 (설정탭을 누르고 바로 로그아웃해버리면 로그아웃후 요청이 될수 있음)
      }
    });

    super.onInit();
  }

  var selectedTabIndex = 0.obs;

}
