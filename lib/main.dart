import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:the_long_dark_info/modules/home/home_controller.dart';
import 'package:the_long_dark_info/modules/map/map_screen.dart';
import 'package:the_long_dark_info/modules/map/map_screen_controller.dart';
import 'package:the_long_dark_info/service/api_service.dart';
import 'package:the_long_dark_info/service/firebase_service.dart';
import 'package:flash/flash.dart';
import 'package:the_long_dark_info/service/local_service.dart';

import './routes.dart';
import 'core/themes.dart';
import 'core/utils.dart';
import 'core/words.dart';
import 'modules/home/home.dart';
import 'modules/intro/intro.dart';
import 'modules/intro/intro_controller.dart';

void main() async {
  await GetStorage.init();
  await Get.putAsync(() => FirebaseService().init());
  await Get.putAsync(() => ApiService().init());
  await Get.putAsync(() => LocalService().init());

  WidgetsFlutterBinding.ensureInitialized();

  //세로모드로 고정
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final appData = GetStorage();

  @override
  Widget build(BuildContext context) {
    LOG('--> Get.locale : ${Get.locale.toString()}');
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: Words(), // 번역들
      locale: Get.deviceLocale,
      fallbackLocale: Locale('en', 'US'), // 잘못된 지역이 선택된 경우 복구될 지역을 지정
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      theme: lightTheme,
      builder: (context, _) {
        var child = _!;
        final navigatorKey = GlobalKey<NavigatorState>();
        // final navigatorKey = child.key as GlobalKey<NavigatorState>;
        child = Toast(
          navigatorKey: navigatorKey,
          alignment: Alignment(0, 0.8),
          child: child,
        );
        return child;
      },
      initialRoute: Routes.INTRO,
      getPages: [
        GetPage(
          name: Routes.INTRO,
          page: () => Intro(),
          binding: BindingsBuilder(
            () => {Get.put(IntroController())},
          ),
        ),
        GetPage(
          name: Routes.HOME,
          page: () => Home(),
          binding: BindingsBuilder(
                () => {Get.put(HomeController())},
          ),
        ),
        GetPage(
          name: Routes.MAP_SCREEN,
          page: () => MapScreen(),
          arguments: JSON,
          binding: BindingsBuilder(
                () => {Get.put(MapScreenController())},
          ),
        ),
      ],
    );
  }
}
