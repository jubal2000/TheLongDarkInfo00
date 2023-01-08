import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:the_long_dark_info/service/api_service.dart';
import 'package:the_long_dark_info/service/firebase_service.dart';

import '../../core/app_data.dart';
import '../../core/common_sizes.dart';
import '../../core/utils.dart';
import '../../routes.dart';
import 'intro_controller.dart';

class Intro extends GetView<IntroController> {
  Intro({Key? key}) : super(key: key);
  final api = Get.find<ApiService>();
  final firebase = Get.find<FirebaseService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: common_s_gap),
            child: FutureBuilder(
            future: api.getAppStartInfo(),
            builder: (context, snapshot) {
              LOG('--> snapshot : ${snapshot.hasData} / ${controller.isCanStart}');
              if (snapshot.hasData) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    if (!controller.isCanStart) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Future.delayed(const Duration(milliseconds: 500), () async {
                          var result = await controller.checkAppUpdate(context, AppData.startData);
                          LOG('--> checkAppUpdate result : $result');
                          if (result) {
                            setState(() {
                              controller.isCanStart = true;
                            });
                          }
                        });
                      });
                    }
                    return Stack(
                      children: [
                        Align(
                            alignment: Alignment(0, -0.25),
                            child: Image.asset(
                              'assets/ui/app_logo_01.png',
                              width: MediaQuery.of(context).size.width * 0.8,
                              color: Colors.black54,
                            )
                        ),
                        Align(
                          alignment: Alignment(0, 0.65),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            // crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: button_l_height,
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Visibility(
                                  visible: controller.isCanStart,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Get.toNamed(Routes.HOME);
                                    },
                                    child: Text(
                                      'START'.tr,
                                    )
                                  ),
                                )
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment(0, 0.95),
                          child: Text('Version $APP_VERSION\nApp created by JH.Factory', textAlign: TextAlign.center),
                        )
                      ],
                    );
                  }
                );
              } else {
                return CircularProgressIndicator();
              }
            }
          )
        ),
      ),
    );
  }
}
