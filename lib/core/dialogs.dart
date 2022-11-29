import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:the_long_dark_info/service/firebase_service.dart';
import 'package:the_long_dark_info/service/local_service.dart';
import 'package:uuid/uuid.dart';

import '../global_widgets/card_scroll_viewer.dart';
import 'app_data.dart';
import 'common_colors.dart';
import 'utils.dart';
import '../core/style.dart';
import '../service/api_service.dart';

final dialogBgColor = NAVY.shade50;
BuildContext? dialogContext;

Future showAlertDialog(BuildContext context,
    String title,
    String message1,
    String message2,
    String btnStr,
    [bool isErrorMode = false]
    )
{
  return showDialog(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return PointerInterceptor(
        child: AlertDialog(
          title: Text(title, style: dialogTitleTextStyle),
          titlePadding: EdgeInsets.all(20),
          insetPadding: EdgeInsets.all(20),
          contentPadding: EdgeInsets.symmetric(horizontal: 20),
          backgroundColor: dialogBgColor,
          content: SingleChildScrollView(
            child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                alignment: Alignment.center,
                constraints: BoxConstraints(
                    minHeight: 100
                ),
                child: ListBody(
                    children: [
                      Text(message1, style: isErrorMode ? dialogDescTextErrorStyle : dialogDescTextStyle),
                      if (message2.isNotEmpty)...[
                        SizedBox(height: 10),
                        Text(message2, style: dialogDescTextExStyle),
                      ]
                    ]
                )
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(btnStr),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}

Future showAlertYesNoDialog(BuildContext context,
    String title,
    String message1,
    String message2,
    String btnNoStr,
    String btnYesStr)
{
  return showDialog(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return PointerInterceptor(
          child: AlertDialog(
            title: Text(title, style: dialogTitleTextStyle),
            titlePadding: EdgeInsets.all(20),
            insetPadding: EdgeInsets.all(20),
            backgroundColor: dialogBgColor,
            content: SingleChildScrollView(
              child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: ListBody(
                      children: [
                        Text(message1, style: dialogDescTextStyle),
                        if (message2.isNotEmpty)...[
                          SizedBox(height: 10),
                          Text(message2, style: dialogDescTextExStyle),
                        ],
                      ]
                  )
              ),
            ),
            actions: [
              TextButton(
                child: Text(btnNoStr),
                onPressed: () {
                  Navigator.of(context).pop(0);
                },
              ),
              TextButton(
                child: Text(btnYesStr),
                onPressed: () {
                  Navigator.of(context).pop(1);
                },
              ),
            ],
          )
      );
    },
  );
}

Future showAlertYesNoExDialog(BuildContext context,
    String title,
    String message1,
    String message2,
    String btn1Str,
    String btn2Str,
    String btn3Str)
{
  return showDialog(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return PointerInterceptor(
        child: AlertDialog(
          title: Text(title, style: dialogTitleTextStyle),
          titlePadding: EdgeInsets.all(20),
          insetPadding: EdgeInsets.all(20),
          backgroundColor: dialogBgColor,
          content: SingleChildScrollView(
            child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                child: ListBody(
                    children: [
                      Text(message1, style: dialogDescTextStyle),
                      if (message2.isNotEmpty)...[
                        SizedBox(height: 10),
                        Text(message2, style: dialogDescTextExStyle),
                      ],
                    ]
                )
            ),
          ),
          actions: [
            if (btn1Str.isNotEmpty)...[
              TextButton(
                child: Text(btn1Str),
                onPressed: () {
                  Navigator.of(context).pop(0);
                },
              ),
              showVerticalDivider(Size(20, 20)),
            ],
            if (btn2Str.isNotEmpty)
              TextButton(
                child: Text(btn2Str),
                onPressed: () {
                  Navigator.of(context).pop(1);
                },
              ),
            if (btn3Str.isNotEmpty)
              TextButton(
                child: Text(btn3Str),
                onPressed: () {
                  Navigator.of(context).pop(2);
                },
              ),
          ],
        ),
      );
    },
  );
}

showImageCroper(String imageFilePath) async {
  var preset = [
    CropAspectRatioPreset.square,
    CropAspectRatioPreset.ratio3x2,
    CropAspectRatioPreset.original,
    CropAspectRatioPreset.ratio4x3,
    CropAspectRatioPreset.ratio16x9
  ];
  return await startImageCroper(imageFilePath, CropStyle.rectangle, preset, CropAspectRatioPreset.original, false);
}

startImageCroper(String imageFilePath, CropStyle cropStyle, List<CropAspectRatioPreset> preset, CropAspectRatioPreset initPreset, bool lockAspectRatio) async {
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

Future<JSON> showPinUploadDialog(BuildContext context, JSON pinData) async {
  final api       = Get.find<ApiService>();
  final firebase  = Get.find<FirebaseService>();
  final titleController   = TextEditingController();
  final editController    = TextEditingController();
  final imageGalleryKey   = GlobalKey();

  JSON imageData = {};
  JSON jsonData = {};
  var isChanged = false;

  refreshImage() {
    jsonData['imageData'] = imageData.entries.map((e) => e.value['backPic']).toList();
  }

  refreshGallery() {
    var gallery = imageGalleryKey.currentState as CardScrollViewerState;
    gallery.refresh();
    refreshImage();
  }

  picLocalImage() async {
    List<XFile>? pickList = await ImagePicker().pickMultiImage();
    if (pickList.isNotEmpty) {
      for (var i=0; i<pickList.length; i++) {
        var image = pickList[i];
        LOG('--> image : ${image.path}');
        var imageUrl = await showImageCroper(image.path);
        var imageInfo = await ReadFileByte(imageUrl);
        var key = Uuid().v1();
        imageData[key] = {'id': key, 'image': imageInfo};
      }
      refreshGallery();
    }
  }

  initData() {
    jsonData = {};
    jsonData.addAll(pinData);
    if (jsonData['imageData'] != null) {
      imageData = {};
      for (var item in jsonData['imageData']) {
        var key = Uuid().v1();
        imageData[key] = JSON.from(jsonDecode('{"id": "$key", "backPic": "$item"}'));
      }
    }
    titleController.text  = STR(jsonData['title']);
    editController.text   = STR(jsonData['desc']);
  }

  initData();

  return await showDialog(
      context: context,
      builder: (BuildContext dlgContext) {
        return PointerInterceptor(
          child: StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                scrollable: true,
                title: Row(
                  children: [
                    Icon(Icons.place_outlined, size: 24),
                    SizedBox(width: 5),
                    Text('Pin edit'.tr, style: dialogTitleTextStyle)
                  ],
                ),
                // titleTextStyle: type == CommentType.message ? _titleText2 : _titleText,
                insetPadding: EdgeInsets.all(15),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                // backgroundColor: Colors.white,
                backgroundColor: dialogBgColor,
                content: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ImageEditScrollViewer(
                            imageData,
                            key: imageGalleryKey,
                            title: 'Image select'.tr,
                            isEditable: true,
                            itemWidth: 80,
                            itemHeight: 80,
                            onActionCallback: (key, status) {
                              setState(() {
                                switch (status) {
                                  case 1: {
                                    picLocalImage();
                                    break;
                                  }
                                  case 2: {
                                    imageData.remove(key);
                                    refreshGallery();
                                    break;
                                  }
                                }
                              });
                            }
                        ),
                        SizedBox(height: 5),
                        TextFormField(
                          controller: titleController,
                          decoration: inputLabel(context, 'Title'.tr, ''),
                          keyboardType: TextInputType.multiline,
                          maxLines: 1,
                          // style: _editText,
                          onChanged: (value) {
                            setState(() {
                              jsonData['title'] = value;
                              isChanged = true;
                            });
                          },
                        ),
                        SizedBox(height: 5),
                        TextFormField(
                          controller: editController,
                          decoration: inputLabel(context, 'Description'.tr, ''),
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          // style: _editText,
                          onChanged: (value) {
                            setState(() {
                              jsonData['desc'] = value;
                              isChanged = true;
                            });
                          },
                        ),
                      ],
                    )
                ),
                actions: [
                  TextButton(
                    child: Text('Cancel'.tr),
                    onPressed: () {
                      Navigator.pop(dlgContext, {});
                    },
                  ),
                  TextButton(
                    child: Text('OK'.tr),
                    onPressed: () {
                      showAlertYesNoDialog(context, 'Upload'.tr, 'Would you like to send a pin data?'.tr,
                          '', 'Cancel'.tr, 'OK'.tr).then((value) {
                        if (value == 0) return;
                        int upCount = 0;
                        showLoadingDialog(context, 'uploading now...'.tr);
                        Future.delayed(Duration(milliseconds: 200), () async {
                          for (var item in imageData.entries) {
                            var result = await firebase.uploadImageData(item.value as JSON, 'pin_img');
                            if (result != null) {
                              imageData[item.key]['backPic'] = result;
                              upCount++;
                            }
                          }
                          LOG('---> upload upCount : $upCount');
                          jsonData['imageData'] = [];
                          jsonData['pic'] = '';
                          for (var item in imageData.entries) {
                            if (item.value['backPic'] != null) {
                              jsonData['imageData'].add(item.value['backPic']);
                              if (STR(jsonData['pic']).isEmpty) jsonData['pic'] = item.value['backPic'];
                            }
                          }
                          JSON upResult = await api.addPinData(jsonData);
                          if (upResult['error'] == null) {
                            var resultData = FROM_SERVER_DATA(jsonData);
                            upResult = {'status': 'success', 'result': resultData};
                          }
                          Navigator.of(dialogContext!).pop();
                          Future.delayed(Duration(milliseconds: 200), () async {
                            Navigator.pop(dlgContext, upResult);
                          });
                        });
                      });
                    }
                  )
                ],
              );
            }
          ),
        );
      }
  );
}

Future<JSON> showPinEditDialog(BuildContext context, String targetId, JSON pinData) async {
  // final api       = Get.find<ApiService>();
  // final firebase  = Get.find<FirebaseService>();
  // final imageGalleryKey   = GlobalKey();
  final local             = Get.find<LocalService>();
  final titleController   = TextEditingController();
  final editController    = TextEditingController();

  JSON jsonData = {};
  var isChanged = false;

  initData() {
    jsonData = {};
    jsonData.addAll(pinData);
    titleController.text  = STR(jsonData['title']);
    editController.text   = STR(jsonData['desc']);
    LOG('--> showPinEditDialog : $targetId / $pinData');
  }

  initData();

  return await showDialog(
    context: context,
    builder: (BuildContext dlgContext) {
      return PointerInterceptor(
        child: StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              scrollable: true,
              title: Row(
                children: [
                  Icon(Icons.place_outlined, size: 24),
                  SizedBox(width: 5),
                  Text('Pin edit'.tr, style: dialogTitleTextStyle)
                ],
              ),
              // titleTextStyle: type == CommentType.message ? _titleText2 : _titleText,
              insetPadding: EdgeInsets.all(15),
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
              // backgroundColor: Colors.white,
              backgroundColor: dialogBgColor,
              content: Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        showColorSelectorDialog(context, 'COLOR SELECT', COL(jsonData['color'])).then((result) {
                          setState(() {
                            jsonData['color'] = COL2STR(result);
                            LOG('--> showColorSelectorDialog result : ${result.toString()} -> ${jsonData['color']}');
                          });
                        });
                      },
                      child: Container(
                        width: 80,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: COL(jsonData['color']),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                            width: 1.0,
                          ),
                        ),
                        child: Center(
                          child: Text('COLOR SELECT', style: itemDescStyle, textAlign: TextAlign.center),
                        )
                        ,
                      ),
                    ),
                    SizedBox(height: 5),
                    TextFormField(
                      controller: titleController,
                      decoration: inputLabel(context, 'Title'.tr, ''),
                      keyboardType: TextInputType.multiline,
                      maxLines: 1,
                      // style: _editText,
                      onChanged: (value) {
                        setState(() {
                          jsonData['title'] = value;
                          isChanged = true;
                        });
                      },
                    ),
                    SizedBox(height: 5),
                    TextFormField(
                      controller: editController,
                      decoration: inputLabel(context, 'Description'.tr, ''),
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      // style: _editText,
                      onChanged: (value) {
                        setState(() {
                          jsonData['desc'] = value;
                          isChanged = true;
                        });
                      },
                    ),
                  ],
                )
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'.tr),
                  onPressed: () {
                    Navigator.pop(dlgContext, {});
                  },
                ),
                TextButton(
                  child: Text('OK'.tr),
                  onPressed: () {
                    showAlertYesNoDialog(context, 'Upload'.tr, 'Would you like to write a pin data?'.tr,
                        '', 'Cancel'.tr, 'OK'.tr).then((value) {
                      if (value == 0) return;
                      showLoadingDialog(context, 'writing now...'.tr);
                      Future.delayed(Duration(milliseconds: 200), () async {
                        AppData.pinData[targetId]['data'].add(jsonData);
                        await local.writeLocalData('pinData', AppData.pinData);
                        Navigator.of(dialogContext!).pop();
                        Future.delayed(Duration(milliseconds: 200), () async {
                          Navigator.pop(dlgContext, jsonData);
                        });
                        // JSON upResult = await api.addPinData(jsonData);
                        // if (upResult['error'] == null) {
                        //   var resultData = FROM_SERVER_DATA(jsonData);
                        //   upResult = {'status': 'success', 'result': resultData};
                        // }
                        // Navigator.of(dialogContext!).pop();
                        // Future.delayed(Duration(milliseconds: 200), () async {
                        //   Navigator.pop(dlgContext, upResult);
                        // });
                      });
                    });
                  }
                )
              ],
            );
          }
        ),
      );
    }
  );
}

showLoadingDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: false, // lock touched close..
    builder: (BuildContext context) {
      dialogContext = context;
      LOG('--> show loading.. : $message');
      return Dialog(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: Theme.of(context).colorScheme.secondaryContainer,
            ),
            child: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text(message, style: dialogDescTextStyle, maxLines: 5, softWrap: true),
              ],
            ),
          )
      );
    },
  );
}

const List<Color> colorSelectLists = [
  Colors.red,
  Colors.pink,
  Colors.purple,
  Colors.deepPurple,
  Colors.indigo,
  Colors.blue,
  Colors.lightBlue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.lightGreen,
  Colors.lime,
  Colors.yellow,
  Colors.amber,
  Colors.orange,
  Colors.deepOrange,
  Colors.brown,
  Colors.grey,
  Colors.blueGrey,
  Colors.black,
];

showColorSelectorDialog(BuildContext context, String title, Color selectColor) async {
  return await showDialog(
    context: context,
    barrierColor: Colors.black87,
    builder: (BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
              children: [
                ColorPicker(
                  paletteType: PaletteType.hsl,
                  pickerColor: selectColor,
                  colorHistory: colorSelectLists,
                  onColorChanged: (Color value) {
                    selectColor = value;
                  },
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(selectColor);
                  },
                  child: Container(
                    width: 200,
                    height: 40,
                    margin: EdgeInsets.only(top: 10),
                    alignment: Alignment.center,
                    child: Text('Select'.tr, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                ),
              ]
            )
          )
        )
      );
    }
  );
}