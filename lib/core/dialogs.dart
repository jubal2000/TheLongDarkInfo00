import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:the_long_dark_info/service/firebase_service.dart';
import 'package:the_long_dark_info/service/local_service.dart';
import 'package:uuid/uuid.dart';

import '../global_widgets/card_scroll_viewer.dart';
import '../global_widgets/main_list_item.dart';
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
                          JSON? upResult = await api.addPinData(jsonData);
                          if (upResult != null) {
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
  final imageGalleryKey   = GlobalKey();

  const iconSize = 50.0;

  JSON iconList = {};
  JSON jsonData = {};
  var isChanged = false;
  var isNew = true;
  var selectIcon = '';
  var isSelectIcon = false;
  var selectColor = Colors.white;

  initData() {
    jsonData = {};
    jsonData.addAll(pinData);
    isNew = STR(jsonData['id']).isEmpty;
    selectColor = STR(jsonData['color']).isNotEmpty ? COL(jsonData['color']) : Colors.white;
    if (isNew) {
      jsonData['id'] = Uuid().v1().toString();
    }
    for (var i=0; i<GameIcons.length; i++) {
      iconList['$i'] = {
        'id': '$i',
        'icon': i,
      };
    }
    titleController.text  = STR(jsonData['title']);
    editController.text   = STR(jsonData['desc']);
    selectIcon = jsonData['icon'] ?? '0';
    jsonData['icon'] = selectIcon;
    LOG('--> showPinEditDialog [${isNew ? 'NEW' : '?EDIT'}] : ${jsonData['id']} / $selectColor / $targetId / $pinData');
  }

  initData();

  return await showDialog(
    context: context,
    builder: (BuildContext dlgContext) {
      return PointerInterceptor(
        child: StatefulBuilder(
          builder: (context, setState) {
            // LOG('--> icon : ${selectIcon.isNotEmpty ? STR(iconList[selectIcon]['backPic']) : 'none'}');
            return AlertDialog(
              scrollable: true,
              title: Text(isNew ? 'Mark add'.tr : 'Mark edit'.tr, style: dialogTitleTextStyle),
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
                    SizedBox(height: 10),
                    if (!isSelectIcon)...[
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isSelectIcon = true;
                          });
                        },
                        child: Icon(GameIcons[int.parse(STR(iconList[selectIcon]['icon']))], size: iconSize, color: selectColor)
                          // showImage(STR(iconList[selectIcon]['backPic']), Size(iconSize, iconSize), selectColor),
                      ),
                    ],
                    if (isSelectIcon)...[
                      Container(
                        color: Colors.blueGrey,
                        child: CardScrollViewer(
                          iconList,
                          key: imageGalleryKey,
                          title: '',
                          isEditable: false,
                          itemWidth: iconSize,
                          itemHeight: iconSize,
                          imageMax: 1,
                          onActionCallback: (key, status) {
                            // LOG('--> icon select : $key / $status');
                            if (status == 1) {
                              setState(() {
                                isSelectIcon = false;
                                selectIcon = key;
                                jsonData['icon'] = key;
                                // jsonData['image'] = iconList[selectIcon]['backPic'];
                              });
                            }
                          }
                        )
                      ),
                    ],
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        showColorSelectorDialog(context, 'COLOR SELECT', selectColor).then((result) {
                          if (result == null) return;
                          setState(() {
                            jsonData['color'] = COL2STR(result);
                            selectColor = result;
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
                        ),
                        child: Center(
                          child: Text('COLOR SELECT', style: itemDescStyle, textAlign: TextAlign.center),
                        )
                        ,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: titleController,
                      decoration: inputLabel(context, 'Title'.tr, ''),
                      keyboardType: TextInputType.multiline,
                      maxLines: 1,
                      maxLength: 24,
                      // style: _editText,
                      onChanged: (value) {
                        setState(() {
                          jsonData['title'] = value;
                          isChanged = true;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: editController,
                      decoration: inputLabel(context, 'Description'.tr, ''),
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      minLines: 4,
                      maxLength: 200,
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
                if (!isNew)...[
                  TextButton(
                    child: Text('Delete'.tr, style: TextStyle(color: Colors.deepPurpleAccent)),
                    onPressed: () {
                      Navigator.pop(dlgContext, {'delete' : 'ok'});
                    },
                  ),
                  showVerticalDivider(Size(40, 20)),
                ],
                TextButton(
                  child: Text('Cancel'.tr),
                  onPressed: () {
                    Navigator.pop(dlgContext, {});
                  },
                ),
                TextButton(
                  child: Text('OK'.tr),
                  onPressed: () {
                    showLoadingDialog(context, 'writing now...'.tr);
                    Future.delayed(Duration(milliseconds: 200), () async {
                      LOG('--> add pin [$targetId] : $jsonData');
                      if (isNew) {
                        AppData.pinData[targetId]['data'].add(jsonData);
                      } else {
                        for (var i=0; i<AppData.pinData[targetId]['data'].length; i++) {
                          var item = AppData.pinData[targetId]['data'][i];
                          if (STR(item['id']) == STR(jsonData['id'])) {
                            AppData.pinData[targetId]['data'][i] = jsonData;
                            break;
                          }
                        }
                      }
                      await local.writeLocalData('pinData', AppData.pinData);
                      Navigator.of(dialogContext!).pop();
                      Future.delayed(Duration(milliseconds: 200), () async {
                        Navigator.pop(dlgContext, jsonData);
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
  Colors.white,
  Colors.purple,
  Colors.purpleAccent,
  Colors.deepPurple,
  Colors.deepPurpleAccent,
  Colors.indigo,
  Colors.indigoAccent,
  Colors.blue,
  Colors.blueAccent,
  Colors.lightBlue,
  Colors.lightBlueAccent,
  Colors.cyan,
  Colors.cyanAccent,
  Colors.teal,
  Colors.tealAccent,
  Colors.green,
  Colors.greenAccent,
  Colors.lightGreen,
  Colors.lightGreenAccent,
  Colors.lime,
  Colors.limeAccent,
  Colors.yellow,
  Colors.yellowAccent,
  Colors.amber,
  Colors.amberAccent,
  Colors.orange,
  Colors.orangeAccent,
  Colors.deepOrangeAccent,
  Colors.deepOrange,
  Colors.red,
  Colors.redAccent,
  Colors.pink,
  Colors.pinkAccent,
  Colors.brown,
  Colors.grey,
  Colors.blueGrey,
  Colors.black,
];

int _portraitCrossAxisCount = 5;
int _landscapeCrossAxisCount = 6;
double _borderRadius = 8;
double _blurRadius = 5;
double _iconSize = 24;

Widget pickerLayoutBuilder(BuildContext context, List<Color> colors, PickerItem child) {
  Orientation orientation = MediaQuery.of(context).orientation;

  return SizedBox(
    width: 400,
    height: orientation == Orientation.portrait ? 460 : 340,
    child: GridView.count(
      crossAxisCount: orientation == Orientation.portrait ? _portraitCrossAxisCount : _landscapeCrossAxisCount,
      crossAxisSpacing: 0,
      mainAxisSpacing: 0,
      children: [for (Color color in colors) child(color)],
    ),
  );
}

Widget pickerItemBuilder(Color color, bool isCurrentColor, void Function() changeColor) {
  return Container(
    margin: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(_borderRadius)),
      color: color,
      border: Border.all(
        color: Colors.black26
      ),
      boxShadow: [BoxShadow(color: color.withOpacity(0.8), offset: const Offset(1, 2), blurRadius: _blurRadius)],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: changeColor,
        borderRadius: BorderRadius.circular(_borderRadius),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: isCurrentColor ? 1 : 0,
          child: Icon(
            Icons.done,
            size: _iconSize,
            color: useWhiteForeground(color) ? Colors.white : Colors.black,
          ),
        ),
      ),
    ),
  );
}

showColorSelectorDialog(BuildContext context, String title, Color selectColor) async {
  return await showDialog(
    context: context,
    barrierColor: Colors.black38,
    builder: (BuildContext context) {
      return PointerInterceptor(
          child: StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Pick a color!'),
              content: SingleChildScrollView(
                child: BlockPicker(
                  pickerColor: selectColor,
                  onColorChanged: (color) {
                    Navigator.of(context).pop(color);
                  },
                  availableColors: colorSelectLists,
                  layoutBuilder: pickerLayoutBuilder,
                  itemBuilder: pickerItemBuilder,
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  child: Text('Exit'.tr),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          }
        ),
      );
    }
  );
}

Future showLinkSelectDialog(BuildContext context, String targetId, {bool isInside = false, bool isAll = false})
{
  var api = Get.find<ApiService>();
  return showDialog(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return PointerInterceptor(
        child: AlertDialog(
          title: Text('Link select'.tr, style: dialogTitleTextStyle),
          contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 0),
          insetPadding: EdgeInsets.symmetric(horizontal: 10),
          backgroundColor: dialogBgColor,
          content: SingleChildScrollView(
            child: FutureBuilder(
              future: isAll ? api.getMapLinkDataAll() : isInside ? api.getMapInsideData() : api.getMapLinkData(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: ListBody(
                      children: isInside ? getInsideList(targetId, (itemInfo) {
                        Navigator.of(context).pop(itemInfo);
                      }) : getLinkList(targetId, (itemInfo) {
                        Navigator.of(context).pop(itemInfo);
                      }),
                    )
                  );
                } else {
                  return Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator()
                    )
                  );
                }
              }
            )
          ),
          actions: [
            TextButton(
              child: Text('Close'.tr),
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

List<Widget> getLinkList(String targetId, Function(JSON) onSelect) {
  List<Widget> result = [];
  List<String> checkList = [];
  LOG('--> getLinkList : $targetId');

  if (AppData.mapData[targetId] != null) {
    if (LIST_NOT_EMPTY(AppData.mapData[targetId]['linkData'])) {
      for (var link in AppData.mapData[targetId]['linkData']) {
        var item = AppData.mapData[link];
        if (item != null && !checkList.contains(item['id'])) {
          LOG('--> add 0 : ${item['title']}');
          checkList.add(item['id']);
          result.add(
            mainListItem(item, () {
              onSelect(item);
            })
          );
        }
      }
    }
  }

  if (AppData.mapLinkData[targetId] != null) {
    for (var link in AppData.mapLinkData[targetId]['linkData']) {
      var item = AppData.mapData[link];
      if (item != null) {
        if (!checkList.contains(item['id'])) {
          LOG('--> add 1 : ${item['title']}');
          checkList.add(item['id']);
          result.add(
              mainListItem(item, () {
                onSelect(item);
              })
          );
        }
      }
    }
  }

  if (AppData.mapInsideData[targetId] != null) {
    for (var link in AppData.mapInsideData[targetId]['linkData']) {
      var item = AppData.mapData[link];
      if (item != null) {
        if (!checkList.contains(item['id'])) {
          LOG('--> add 2 : ${item['title']}');
          checkList.add(item['id']);
          result.add(
              mainListItem(item, () {
                onSelect(item);
              })
          );
        }
      }
    }
  }

  for (var item in AppData.mapLinkData.entries) {
    if (LIST_NOT_EMPTY(item.value['linkData'])) {
      for (var link in item.value['linkData']) {
        if (link == targetId && !checkList.contains(item.key)) {
          var newItem = getMapLinkTitle(item.value, STR(AppData.mapData[targetId]['title']));
          LOG('--> add 3 : ${newItem['title']} / ${newItem['titleEx']}');
          newItem['type'] = 1;
          checkList.add(item.key);
          result.add(
            mainListItem(newItem, () {
              onSelect(newItem);
            })
          );
        }
      }
    }
  }
  return result;
}

getMapLinkTitle(JSON item, String orgTitle) {
  var titleArr    = STR(item['subTitle']).split(' - ');
  var titleKrArr  = STR(item['subTitle_kr']).split(' - ');
  LOG('--> getMapLinkTitle : $orgTitle / ${titleArr[0]} - ${titleArr[1]}');
  item['titleEx'   ] = '${STR(item['title'])} - ${titleArr[0] != orgTitle ? titleArr[0] : titleArr[1]}';
  item['titleEx_kr'] = '${STR(item['title_kr'])} - ${titleArr[0] != orgTitle ? titleKrArr[0] : titleKrArr[1]}';
  LOG('--> item : $item');
  return item;
}

List<Widget> getInsideList(String targetId, Function(JSON) onSelect) {
  List<Widget> result = [];
  List<String> checkList = [];

  if (AppData.mapData[targetId] != null && AppData.mapData[targetId]['insideData'] != null) {
    for (var link in AppData.mapData[targetId]['insideData']) {
      var item = AppData.mapInsideData[link];
      if (item != null) {
        if (!checkList.contains(item['id'])) {
          checkList.add(item['id']);
          result.add(
              mainListItem(item, () {
                onSelect(item);
              })
          );
        }
      }
    }
  }
  return result;
}

Future showButtonDialog(BuildContext context,
    String title,
    String message1,
    String message2,
    List<Widget> actionList)
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
          actions: actionList,
        ),
      );
    },
  );
}
