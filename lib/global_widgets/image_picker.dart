import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:the_long_dark_info/service/api_service.dart';

import '../core/dialogs.dart';
import '../core/utils.dart';

// ignore: non_constant_identifier_names
ShowImagePicker(BuildContext context, String key) async {
  final api = Get.find<ApiService>();
  XFile? pickImage = await ImagePicker().pickImage(source: ImageSource.gallery);
  LOG('---> showImagePicker : $pickImage');
  if (pickImage != null) {
    var imageUrl  = await showImageCroper(pickImage.path);
    LOG('---> imageUrl : $imageUrl');
    return imageUrl;
    // if (imageUrl != null) {
      // showLoadingDialog(context, 'uploading now...'.tr);
      // var imageData = await ReadFileByte(imageUrl);
      // JSON imageInfo = {'id': key, 'image': imageData};
      // var upResult = await api.uploadImageData(imageInfo, 'memento_img');
      // Navigator.of(dialogContext!).pop();
      // return upResult;
    // }
    // showLoadingDialog(context, 'Now Uploading...');
    // Future.delayed(Duration(milliseconds: 200), () {
    //   var imageByte = pickList.first;
    //   imageByte.readAsBytes().then((value) async {
    //     var imageData = await resizeImage(value, 512) as Uint8List;
    //     JSON imageInfo = {'id': widget.userInfo['id'], 'image': imageData};
    //     var upResult = await uploadImageData(imageInfo, 'user_img');
    //     if (upResult != null) {
    //       widget.userInfo['pic'] = upResult;
    //       var setResult = await setUserInfoItem(widget.userInfo, 'pic');
    //       Navigator.of(dialogContext!).pop();
    //       if (setResult) {
    //         showAlertDialog(context, '프로필', '이미지 업데이트가 완료됬습니다.', '', '확인');
    //         setState(() {
    //           AppData.userInfo['pic'] = widget.userInfo['pic'];
    //         });
    //       }
    //     } else {
    //       Navigator.of(dialogContext!).pop();
    //     }
    //   });
    // });
  }
  return null;
}

// ignore: non_constant_identifier_names
ShowUserPicCroper(String imageFilePath) async {
  var preset = [
    CropAspectRatioPreset.square,
  ];
  return await StartImageCroper(imageFilePath, CropStyle.circle, preset, CropAspectRatioPreset.square, false);
}

// ignore: non_constant_identifier_names
ShowBannerImageCroper(String imageFilePath) async {
  var preset = [
    CropAspectRatioPreset.ratio16x9
  ];
  return await StartImageCroper(imageFilePath, CropStyle.rectangle, preset, CropAspectRatioPreset.ratio16x9, false);
}

// ignore: non_constant_identifier_names
StartImageCroper(String imageFilePath, CropStyle cropStyle, List<CropAspectRatioPreset> preset, CropAspectRatioPreset initPreset, bool lockAspectRatio) async {
  CroppedFile? croppedFile = await ImageCropper().cropImage(
    cropStyle: cropStyle,
    sourcePath: imageFilePath,
    aspectRatioPresets: preset,
    maxWidth: 1024,
    uiSettings: [
      AndroidUiSettings(
          toolbarTitle: 'Image size edit'.tr,
          toolbarColor: Colors.purple,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: initPreset,
          lockAspectRatio: lockAspectRatio),
      IOSUiSettings(
        title: 'Image size edit'.tr,
      ),
    ],
  );
  return croppedFile?.path;
}