import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:the_long_dark_info/service/firebase_service.dart';
import 'package:the_long_dark_info/service/local_service.dart';
import 'package:uuid/uuid.dart';

import '../global_widgets/card_scroll_viewer.dart';
import '../global_widgets/image_scroll_viewer.dart';
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

Future showSimpleAlertYesNoDialog(
  BuildContext context,
  String desc,
  {
    TextStyle? style,
  })
{
  return showAlertYesNoDialog(
    context,
    '',
    desc,
    '',
    '취소',
    '확인',
    messageStyle1: style ?? dialogTitleTextStyle,
  );
}

Future showAlertYesNoDialog(
    BuildContext context,
    String title,
    String message1,
    String message2,
    String btnNoStr,
    String btnYesStr,
  {
    TextStyle? messageStyle1,
  })
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
                        Text(message1, style: messageStyle1 ?? dialogDescTextStyle),
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

Future<JSON> showPinEditDialog(BuildContext context, String targetId, JSON pinData) async {
  final local             = Get.find<LocalService>();
  final titleController   = TextEditingController();
  final editController    = TextEditingController();
  final imageGalleryKey   = GlobalKey();

  const iconSize = 50.0;

  JSON iconList = {};
  JSON jsonData = {};
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
    // for (var i=0; i<131; i++) {
    //   iconList['$i'] = {
    //     'id': '$i',
    //     'backPic': 'assets/icons/game/${i+1}.png',
    //   };
    // }
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
                        // child: Icon(GameIcons[int.parse(STR(iconList[selectIcon]['icon']))], size: iconSize, color: selectColor)
                        child: Stack(
                          children: [
                            Positioned(
                              left: 2,
                              top: 2,
                              child: Icon(GameIcons[int.parse(STR(iconList[selectIcon]['icon']))], size: iconSize, color: Colors.black87),
                            ),
                            Icon(GameIcons[int.parse(STR(iconList[selectIcon]['icon']))], size: iconSize, color: selectColor),
                          ],
                        )
                        // child: iconList[selectIcon]['icon'] != null ?
                        //   Icon(GameIcons[int.parse(STR(iconList[selectIcon]['icon']))], size: iconSize, color: selectColor) :
                        //   showImage(STR(iconList[selectIcon]['backPic']), Size(iconSize, iconSize), selectColor),
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
                          imageColor: Colors.white,
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
                        showColorSelectorDialog(context, 'COLOR SELECT'.tr, selectColor).then((result) {
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
                          child: Text('COLOR SELECT'.tr, style: itemDescStyle, textAlign: TextAlign.center),
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
                    showLoadingDialog(context, 'Saving...'.tr);
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

Future<JSON?> showMementoEditDialog(BuildContext context, String targetId, List<JSON> data, int index, {bool isNew = true}) async {
  final startController   = TextEditingController();
  final endController     = TextEditingController();
  final rewardController  = TextEditingController();
  final api = Get.find<ApiService>();

  initData() {
    startController.text  = STR(data[index]['start']['desc']);
    endController.text    = STR(data[index]['end'  ]['desc']);
    rewardController.text = STR(data[index]['reward']);
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
                  title: Text(isNew ? 'Memento add'.tr : 'Memento edit'.tr, style: dialogTitleTextStyle),
                  insetPadding: EdgeInsets.all(15),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  backgroundColor: dialogBgColor,
                  content: StatefulBuilder(
                    builder: (context, setState) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          index = 0;
                                          initData();
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
                                          border: Border.all(width: 2.0, color: index == 0 ? Theme.of(context).primaryColor : Colors.black45),
                                          color: index == 0 ? Theme.of(context).primaryColor.withOpacity(0.3) : Colors.black12,
                                        ),
                                        child: Center(
                                          child: Text('1', style: index == 0 ? itemTitleStyle : itemDescStyle),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          index = 1;
                                          initData();
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
                                          border: Border.all(width: 2.0, color: index == 1 ? Theme.of(context).primaryColor : Colors.black45),
                                          color: index == 1 ? Theme.of(context).primaryColor.withOpacity(0.3) : Colors.black12,
                                        ),
                                        child: Center(
                                          child: Text('2', style: index == 1 ? itemTitleStyle : itemDescStyle),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ),
                            SizedBox(height: 10),
                            Text('Note'.tr, style: dialogDescTextStyle),
                            Row(
                              children: [
                                Expanded(
                                  child:TextFormField(
                                    controller: startController,
                                    decoration: inputLabel(context, 'Description'.tr, ''),
                                    keyboardType: TextInputType.text,
                                    maxLines: 1,
                                    onChanged: (value) {
                                      setState(() {
                                        data[index]['start']['desc'] = value;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(width: 10),
                                InkWell(
                                  onTap: () {
                                    if (data[index]['start']['image'].isNotEmpty) {
                                      var imageList = List<String>.from(data[index]['start']['image']).map((
                                          item) => 'assets/memento/$item.png').toList();
                                      showImageSlideDialog(context, imageList, 0);
                                    }
                                    // ShowImagePicker(context, Uuid().v1().toString()).then((result) {
                                    //   if (result != null) {
                                    //     setState(() {
                                    //       LOG('--> start result : $result');
                                    //       data[index]['start']['imageLocal'] = result;
                                    //     });
                                    //   }
                                    // });
                                  },
                                  child: data[index]['start']['image'].isNotEmpty ? showImage('assets/memento/${data[index]['start']['image'].first}.png', Size(40,40)) : showImage(NO_IMAGE, Size(40,40)),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text('Object'.tr, style: dialogDescTextStyle),
                            Row(
                              children: [
                                Expanded(
                                  child:TextFormField(
                                    controller: endController,
                                    decoration: inputLabel(context, 'Description'.tr, ''),
                                    keyboardType: TextInputType.text,
                                    maxLines: 1,
                                    onChanged: (value) {
                                      setState(() {
                                        data[index]['end']['desc'] = value;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(width: 10),
                                InkWell(
                                  onTap: () {
                                    if (data[index]['end']['image'].isNotEmpty) {
                                      var imageList = List<String>.from(data[index]['end']['image']).map((
                                          item) => 'assets/memento/$item.png').toList();
                                      showImageSlideDialog(context, imageList, 0);
                                    }
                                  },
                                  child: data[index]['end']['image'].isNotEmpty ? showImage('assets/memento/${data[index]['end']['image'].first}.png', Size(40,40)) : showImage(NO_IMAGE, Size(40,40)),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text('Reward'.tr, style: dialogDescTextStyle),
                            TextFormField(
                              controller: rewardController,
                              decoration: inputLabel(context, 'Description'.tr, ''),
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              minLines: 4,
                              maxLength: 200,
                              onChanged: (value) {
                                setState(() {
                                  data[index]['reward'] = value;
                                });
                              },
                            ),
                            SizedBox(height: 10),
                            TextCheckBox(context, 'Including interloper'.tr, BOL(data[index]['interloper']), onChanged: (value) {
                              setState(() {
                                data[index]['interloper'] = value ? '1' : '';
                              });
                            })
                          ],
                        )
                      );
                    }
                  ),
                  actions: [
                    TextButton(
                      child: Text('Delete'.tr, style: TextStyle(color: Colors.deepPurpleAccent)),
                      onPressed: () {
                        Navigator.pop(dlgContext, {'delete' : 'ok'});
                      },
                    ),
                    showVerticalDivider(Size(40, 20)),
                    TextButton(
                      child: Text('Cancel'.tr),
                      onPressed: () {
                        Navigator.pop(dlgContext);
                      },
                    ),
                    TextButton(
                        child: Text('OK'.tr),
                        onPressed: () {
                          Navigator.pop(dlgContext, {'result' : data});
                          // showLoadingDialog(context, 'Uploading now...'.tr);
                          // Future.delayed(Duration(milliseconds: 200), () async {
                          //   LOG('--> add memento [$targetId] : ${data[index]}');
                          //   var addData = {
                          //     'id': targetId,
                          //     'status': 1,
                          //     'data': data,
                          //     'createTime': CURRENT_SERVER_TIME()
                          //   };
                          //   api.addMementoData(addData).then((result) {
                          //     if (result != null) {
                          //       AppData.mementoData[targetId] = result;
                          //     }
                          //     Navigator.of(dialogContext!).pop();
                          //     Future.delayed(Duration(milliseconds: 200), () async {
                          //       Navigator.pop(dlgContext, data[index]);
                          //     });
                          //   });
                          // });
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

Future showImageSlideDialog(BuildContext context, List<String> imageData, int startIndex) async {
  // TextStyle _menuText   = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blueAccent);
  LOG('--> showImageSlideDialog : $imageData / $startIndex');

  return await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return PointerInterceptor(
          child: AlertDialog(
              title: SizedBox(height: 10),
              scrollable: true,
              insetPadding: EdgeInsets.all(15),
              contentPadding: EdgeInsets.zero,
              content: Container(
                width: MediaQuery.of(context).size.width,
                child: ImageScrollViewer(
                  imageData,
                  startIndex: startIndex,
                  rowHeight: MediaQuery.of(context).size.width - 30,
                  imageFit: BoxFit.contain,
                  showArrow: true,
                  showPage: true,
                  autoScroll: false,
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Close'.tr)
                )
              ]
          ),
        );
      }
  ) ?? '';
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
          title: Text('Select connection map'.tr, style: dialogTitleTextStyle),
          contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 0),
          insetPadding: EdgeInsets.symmetric(horizontal: 10),
          backgroundColor: dialogBgColor,
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: ListBody(
                children: isInside ? getInsideList(targetId, (itemInfo) {
                  Navigator.of(context).pop(itemInfo);
                }) : getLinkList(targetId, (itemInfo) {
                  Navigator.of(context).pop(itemInfo);
                }),
              )
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
      if (item != null && !checkList.contains(item['id'])) {
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

  if (AppData.mapInsideData[targetId] != null) {
    if (LIST_NOT_EMPTY(AppData.mapInsideData[targetId]['linkData'])) {
      for (var link in AppData.mapInsideData[targetId]['linkData']) {
        var item = AppData.mapData[link];
        if (item != null && !checkList.contains(item['id'])) {
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

  for (var item in AppData.mapInsideData.entries) {
    if (LIST_NOT_EMPTY(item.value['linkData'])) {
      for (var link in item.value['linkData']) {
        if (link == targetId && !checkList.contains(item.key)) {
          LOG('--> add 3 : ${item.value['title']}');
          checkList.add(item.key);
          result.add(
              mainListItem(item.value, () {
                onSelect(item.value);
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
          var newItem = getMapLinkTitle(item.value, AppData.mapData[targetId] != null ? STR(AppData.mapData[targetId]['title']) : STR(AppData.mapInsideData[targetId]['title']));
          LOG('--> add 4 : ${newItem['title']} / ${newItem['titleEx']}');
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
