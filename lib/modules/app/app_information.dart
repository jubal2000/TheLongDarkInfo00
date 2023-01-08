import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_long_dark_info/core/style.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_data.dart';
import '../../core/common_sizes.dart';
import '../../core/utils.dart';

class AppInformation extends StatelessWidget {
  const AppInformation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App information'.tr),
        titleTextStyle: itemTitleStyle,
        titleSpacing: 0,
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, layout) {
            return Container(
              padding: EdgeInsets.all(20),
              width: layout.maxWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/ui/app_logo_01.png',
                    width: MediaQuery.of(context).size.width * 0.8,
                    color: Colors.black54,
                  ),
                  SizedBox(height: 20),
                  Icon(Icons.more_horiz, color: Colors.grey),
                  SizedBox(height: 20),
                  Text('Version $APP_VERSION', style: itemTitleStyle),
                  SizedBox(height: 5),
                  Text('App created by JH.Factory', style: itemSubTitleStyle),
                  SizedBox(height: 20),
                  if (AppData.startData['org_url'] != null)...[
                    Icon(Icons.more_horiz, color: Colors.grey),
                    SizedBox(height: 20),
                    InkWell(
                        onTap: () async {
                          await _launchUrl(Uri.parse(STR(AppData.startData['org_url']['game'])));
                        },
                        child: Column(
                          children: [
                            Text('\'The Long Dark\' is\ncopyrighted by hinterlandgames.com', style: itemSubTitleStyle, textAlign: TextAlign.center),
                            Text(STR(AppData.startData['org_url']['game']), style: itemDescLinkStyle, textAlign: TextAlign.center),
                          ],
                        )
                    ),
                    SizedBox(height: 20),
                    InkWell(
                      onTap: () async {
                        await _launchUrl(Uri.parse(STR(AppData.startData['org_url']['map'])));
                      },
                      child: Column(
                        children: [
                          Text('Mapped by stmSantana', style: itemSubTitleStyle),
                          Text(STR(AppData.startData['org_url']['map']), style: itemDescLinkStyle, textAlign: TextAlign.center),
                        ],
                      )
                    ),
                    SizedBox(height: 20),
                    InkWell(
                        onTap: () async {
                          await _launchUrl(Uri.parse(STR(AppData.startData['org_url']['memento'])));
                        },
                        child: Column(
                          children: [
                            Text('Memento info from dcinside.com', style: itemSubTitleStyle),
                            Text(STR(AppData.startData['org_url']['memento']), style: itemDescLinkStyle, textAlign: TextAlign.center),
                          ],
                        )
                    ),
                  ],
                ],
              )
            );
          }
        )
      ),
    );
  }

  Future<void> _launchUrl(url) async {
    if (!await launchUrl(url)) {
      throw '--> Could not launch $url';
    }
  }
}