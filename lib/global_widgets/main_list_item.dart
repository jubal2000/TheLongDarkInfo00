import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/common_colors.dart';
import '../core/common_sizes.dart';
import '../core/style.dart';
import '../core/utils.dart';
import '../routes.dart';

Widget mainListItem(JSON itemInfo, [Function()? onSelect]) {
  if (STR(itemInfo['icon']).isEmpty) {
    itemInfo['icon'] = '107';
  }
  return GestureDetector(
      onTap: () {
        if (onSelect != null) onSelect();
      },
      child: Container(
        height: item_height,
        padding: EdgeInsets.fromLTRB(15, 3, 8, 3),
        margin: EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: INT(itemInfo['type']) == 1 ? Colors.white60 : Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // if (STR(itemInfo['icon']).isNotEmpty)...[
            //   showImage('assets/icons/game/${STR(itemInfo['icon'])}.png', Size(40, 40), NAVY.shade300),
            //   SizedBox(width: 10),
            // ],
            if (INT(itemInfo['type']) == 0)...[
              showImage('assets/ui/main/${itemInfo['id']}.png', Size(40,40)),
              SizedBox(width: 15),
            ],
            Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(STR(itemInfo['titleEx_kr'] ?? itemInfo['title_kr']), style: itemTitleStyle, maxLines: 2),
                          SizedBox(height: 3),
                          Text(STR(itemInfo['titleEx'] ?? itemInfo['title']).toUpperCase(), style: itemTitleInfoStyle, maxLines: 2),
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