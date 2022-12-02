import 'dart:convert';

import 'package:get/get.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_long_dark_info/service/firebase_service.dart';

import '../core/app_data.dart';
import '../core/utils.dart';

class ApiService extends GetxService {
  Future<ApiService> init() async {
    initService();
    return this;
  }

  var firebase = Get.find<FirebaseService>();

  void initService() {

  }

  Future<dynamic> getAppStartInfo() async {
    try {
      var collectionRef = firebase.firestore!.collection('info_start');
      var querySnapshot = await collectionRef.doc('info0000').get();
      if (querySnapshot.data() != null) {
        AppData.startData = FROM_SERVER_DATA(querySnapshot.data());
        LOG('--> getStartInfo result : ${AppData.startData}');
        return AppData.startData;
      } else {
        return {'error' : 'no data'};
      }
    } catch (e) {
      LOG('--> getStartInfo Error : $e');
      return {'error' : e.toString()};
    }
  }

  Future<dynamic> getMapDataAll() async {
    var result1 = await getMapData();
    var result2 = await getMapLinkData();
    var result3 = await getMapInsideData();
    return result1;
  }

  Future<dynamic> getMapData() async {
    if (JSON_NOT_EMPTY(AppData.mapData)) return AppData.mapData;
    try {
      var collectionRef = firebase.firestore!.collection('info_map');
      var querySnapshot = await collectionRef.
          get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          AppData.mapData[doc.data()['id']] = FROM_SERVER_DATA(doc.data());
          // LOG('--> resultData [${outName[i]}]: ${doc.data()}');
        }
        LOG('--> getMapData result : ${AppData.mapData}');
        return AppData.mapData;
      } else {
        return {'error' : 'no data'};
      }
    } catch (e) {
      LOG('--> getMapData Error : $e');
      return {'error' : e.toString()};
    }
  }

  Future<dynamic> getMapLinkDataAll() async {
    var result1 = await getMapLinkData();
    var result2 = await getMapInsideData();
    return result2;
  }

  Future<dynamic> getMapLinkData() async {
    if (JSON_NOT_EMPTY(AppData.mapLinkData)) return AppData.mapLinkData;
    try {
      var collectionRef = firebase.firestore!.collection('info_cave');
      var querySnapshot = await collectionRef.
      get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          AppData.mapLinkData[doc.data()['id']] = FROM_SERVER_DATA(doc.data());
          // LOG('--> resultData [${outName[i]}]: ${doc.data()}');
        }
        LOG('--> getMapLinkData result : ${AppData.mapLinkData}');
        return AppData.mapLinkData;
      } else {
        return {'error' : 'no data'};
      }
    } catch (e) {
      LOG('--> getMapLinkData Error : $e');
      return {'error' : e.toString()};
    }
  }

  Future<dynamic> getMapInsideData() async {
    if (JSON_NOT_EMPTY(AppData.mapInsideData)) return AppData.mapInsideData;
    try {
      var collectionRef = firebase.firestore!.collection('info_inside');
      var querySnapshot = await collectionRef.
      get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          AppData.mapInsideData[doc.data()['id']] = FROM_SERVER_DATA(doc.data());
          // LOG('--> resultData [${outName[i]}]: ${doc.data()}');
        }
        LOG('--> getMapInsideData result : ${AppData.mapInsideData}');
        return AppData.mapInsideData;
      } else {
        return {'error' : 'no data'};
      }
    } catch (e) {
      LOG('--> getMapInsideData Error : $e');
      return {'error' : e.toString()};
    }
  }

  // pin data..
  final PinCollection = 'data_pin';

  Future<JSON?> addPinData(JSON addItem) async {
    try {
      var dataRef = firebase.firestore!.collection(PinCollection);
      var key = STR(addItem['id']).toString();
      if (key.isEmpty) {
        key = dataRef.doc().id;
        addItem['id'] = key;
        addItem['status'] = 1;
        addItem['createTime'] = CURRENT_SERVER_TIME();
      }
      addItem['updateTime'] = CURRENT_SERVER_TIME();
      await dataRef.doc(key).set(Map<String, dynamic>.from(addItem));
      var result = FROM_SERVER_DATA(addItem);
      return result;
    } catch (e) {
      LOG('--> addPinData : $e');
    }
    return null;
  }

  // pin data..
  final LinkCollection = 'data_link';

  Future<dynamic> getLinkData() async {
    if (JSON_NOT_EMPTY(AppData.linkData)) return AppData.linkData;
    try {
      var collectionRef = firebase.firestore!.collection(LinkCollection);
      var querySnapshot = await collectionRef
          .where('status', isEqualTo: 1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          AppData.linkData[doc.data()['id']] = FROM_SERVER_DATA(doc.data());
          // LOG('--> resultData [${outName[i]}]: ${doc.data()}');
        }
        LOG('--> getLinkData result : ${AppData.linkData}');
        return AppData.linkData;
      } else {
        LOG('--> getLinkData : no data');
        return {'error' : 'no data'};
      }
    } catch (e) {
      LOG('--> getLinkData Error : $e');
      return {'error' : e.toString()};
    }
  }

  Future<JSON?> addLinkData(JSON addItem) async {
    try {
      var dataRef = firebase.firestore!.collection(LinkCollection);
      var key = STR(addItem['id']).toString();
      if (key.isEmpty) {
        key = dataRef.doc().id;
        addItem['id'] = key;
        addItem['status'] = 1;
        addItem['createTime'] = CURRENT_SERVER_TIME();
      }
      addItem['updateTime'] = CURRENT_SERVER_TIME();
      await dataRef.doc(key).set(Map<String, dynamic>.from(addItem));
      var result = FROM_SERVER_DATA(addItem);
      return result;
    } catch (e) {
      LOG('--> addLinkData : $e');
    }
    return null;
  }

}

