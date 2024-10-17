import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/app_data.dart';

//배너광고
class AdMobService {

  //앱 개발시 테스트광고 ID로 입력
  static String? get bannerAdUnitId {

    if (Platform.isAndroid) {
      return !IS_DEV_MODE ?
      'ca-app-pub-5103278828219477~9783249651' :
      'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return !IS_DEV_MODE ?
      'ca-app-pub-5103278828219477~8038051004' :
      'ca-app-pub-3940256099942544/2934735716';
    }
    return null;
  }

  //전면 광고
  static String? get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
    }
    return null;
  }

  static final BannerAdListener bannerAdListener = BannerAdListener(
    onAdLoaded: (ad) => debugPrint('Ad loaded'),
    onAdFailedToLoad: (ad, error) {
      ad.dispose();
      debugPrint('Ad fail to load: $error');
    },
    onAdOpened: (ad) => debugPrint('Ad opened'),
    onAdClosed: (ad) => debugPrint('Ad closed'),
  );
}