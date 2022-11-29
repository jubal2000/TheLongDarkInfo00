import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:the_long_dark_info/service/local_service.dart';
import '../../core/utils.dart';
import '../../service/api_service.dart';

class IntroController extends GetxController {
  final api   = Get.find<ApiService>();
  final local = Get.find<LocalService>();

  var isShowDialog = false;
  var isCanStart = false;

  @override
  void onInit() async {
    super.onInit();
  }

  Future<bool> checkAppUpdate(BuildContext context, JSON serverVersionData) async {
    if (isShowDialog) return false;
    isShowDialog = true;
    LOG('--> checkAppUpdate : $serverVersionData');

    // check version from server..
    final version = await StorageManager.readData('appVersion');
    final versionData = serverVersionData['appVersion'];
    if (versionData != null) {
      final versionInfo = Platform.isAndroid ? versionData['android'] : versionData['ios'];
      final isForceUpdate = versionInfo['update'].toLowerCase() == 'y';
      // final version = ''; // for Dev..
      LOG('--> version : $isForceUpdate / $version / ${versionInfo['version']}');
      if (isForceUpdate || version == null || checkVersionString(version.toString(), STR(versionInfo['version']))) {
        var dlgResult = await showAppUpdateDialog(context,
          STR(versionInfo['message']),
          'version: ${STR(versionInfo['version'])}',
          isForceUpdate: isForceUpdate,
        );
        LOG('--> showAppUpdateDialog result : $dlgResult');
        switch (dlgResult) {
          case 1: // move market..
            StoreRedirect.redirect(
                androidAppId: "com.jhfactory.tld_info_00",
                iOSAppId: "1597866658"
            );
            return !isForceUpdate;
          case 2: // never show again..
            StorageManager.saveData('appVersion', STR(versionInfo['version']));
            break;
        }
      }
    }
    return true;
  }

  checkVersionString(String source, String target) {
    try {
    var source2 = int.parse(source.replaceAll('.', '0'));
    var target2 = int.parse(target.replaceAll('.', '0'));
    LOG('--> checkVersionString : $source2 / $target2 - $source / $target');
    return source2 < target2;
    } catch (e) {
      LOG('--> error : $e');
    }
    return false;
  }

  Future<int> showAppUpdateDialog(BuildContext context, String desc, String? msg, {bool isForceUpdate = false }) async {
    // print('--> showAppUpdateDialog : $desc / $msg');
    msg ??= '';
    msg = msg.replaceAll('\\n' , '\n');
    msg = msg.replaceAll('<br>', '\n');
    return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
      return AlertDialog(
        title: Container(
          width: double.infinity,
          alignment: Alignment.center,
          child: Text('App update'.tr),
        ),
        insetPadding: EdgeInsets.all(40),
        contentPadding: EdgeInsets.all(20),
        content: Container(
          width: MediaQuery.of(context).size.width,
          constraints: BoxConstraints(
            maxWidth: 800,
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              Image(image: AssetImage('assets/icons/app_icon_00.png'), height: 80, fit: BoxFit.fitHeight, color: Colors.black54),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: Text(
                  desc,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.1),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 10),
              if (msg!.isNotEmpty)...[
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Text(
                    msg,
                    style: TextStyle(fontSize: 16, color: Colors.deepPurple, height: 1.5),
                  ),
                ),
              ]
            ]
          )
        ),
        actions: <Widget>[
          if (!isForceUpdate)
            TextButton(
              child: Text('다시보지않기', style: TextStyle(color: Colors.blueAccent)),
              onPressed: () {
                Navigator.of(context).pop(2);
              },
            ),
          TextButton(
            // child: Text(isForceUpdate ? '마켓으로 이동' : '확인'),
            child: Text('마켓으로 이동'),
            onPressed: () {
              isShowDialog = false;
              Navigator.of(context).pop(1);
//              Navigator.of(context).pop(isForceUpdate ? 1 : 0);
            },
          ),
        ],
      );
    });
  }
}
