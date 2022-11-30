import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/common_colors.dart';
import '../core/common_sizes.dart';
import '../core/style.dart';
import '../core/utils.dart';
import '../routes.dart';

Widget mainListItem(JSON itemInfo, [Function()? onSelect]) {
  return GestureDetector(
      onTap: () {
        if (onSelect != null) onSelect();
      },
      child: Container(
        height: item_height,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        margin: EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (STR(itemInfo['icon']).isNotEmpty)...[
              showImage('assets/icons/game/${STR(itemInfo['icon'])}.png', Size(40, 40), NAVY),
              SizedBox(width: 10),
            ],
            Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(STR(itemInfo['title_kr']), style: itemTitleStyle, maxLines: 2),
                          SizedBox(height: 3),
                          Text(STR(itemInfo['title']).toString().toUpperCase(), style: itemTitleInfoStyle, maxLines: 2),
                        ]
                    ),
                    Icon(Icons.arrow_forward_ios, size: 24, color: Colors.black12),
                  ],
                )
            )
          ],
        ),
      )
  );
}