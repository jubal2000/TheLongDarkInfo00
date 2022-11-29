import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../home/home.dart';
import 'app_controller.dart';

class App extends GetView<AppController> {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = <Widget>[
      Home(),
    ];
    return Obx(() => Scaffold(
          body: IndexedStack(
            key: ValueKey(controller.selectedTabIndex.value),
            index: controller.selectedTabIndex.value,
            children: _screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            onTap: (index) {
              controller.selectedTabIndex.value = index;
            },
            currentIndex: controller.selectedTabIndex.value,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                // icon: Padding(
                //   padding: const EdgeInsets.only(bottom: common_xxxxs_gap),
                //   child: SvgPicture.asset(
                //     "assets/img/icon/home.svg",
                //     width: 40,
                //   ),
                // ),
                // activeIcon: Padding(
                //   padding: const EdgeInsets.only(bottom: common_xxxxs_gap),
                //   child: SvgPicture.asset(
                //     "assets/img/icon/home-active.svg",
                //     width: 40,
                //   ),
                // ),
                label: '홈',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet),
                // icon: Padding(
                //   padding: const EdgeInsets.only(bottom: common_xxxxs_gap),
                //   child: SvgPicture.asset(
                //     "assets/img/icon/wallet.svg",
                //     width: 40,
                //   ),
                // ),
                // activeIcon: Padding(
                //   padding: const EdgeInsets.only(bottom: common_xxxxs_gap),
                //   child: SvgPicture.asset(
                //     "assets/img/icon/wallet-active.svg",
                //     width: 40,
                //   ),
                // ),
                label: '멀티월렛',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.loop),
                // icon: Padding(
                //   padding: const EdgeInsets.only(bottom: common_xxxxs_gap),
                //   child: SvgPicture.asset(
                //     "assets/img/icon/exchange.svg",
                //     width: 40,
                //   ),
                // ),
                // activeIcon: Padding(
                //   padding: const EdgeInsets.only(bottom: common_xxxxs_gap),
                //   child: SvgPicture.asset(
                //     "assets/img/icon/exchange-active.svg",
                //     width: 40,
                //   ),
                // ),
                label: '페이로전송',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list),
                // icon: Padding(
                //   padding: const EdgeInsets.only(bottom: common_xxxxs_gap),
                //   child: SvgPicture.asset(
                //     "assets/img/icon/list.svg",
                //     width: 40,
                //   ),
                // ),
                // activeIcon: Padding(
                //   padding: const EdgeInsets.only(bottom: common_xxxxs_gap),
                //   child: SvgPicture.asset(
                //     "assets/img/icon/list-active.svg",
                //     width: 40,
                //   ),
                // ),
                label: '거래내역',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                // icon: Padding(
                //   padding: const EdgeInsets.only(bottom: common_xxxxs_gap),
                //   child: SvgPicture.asset(
                //     "assets/img/icon/setting.svg",
                //     width: 40,
                //   ),
                // ),
                // activeIcon: Padding(
                //   padding: const EdgeInsets.only(bottom: common_xxxxs_gap),
                //   child: SvgPicture.asset(
                //     "assets/img/icon/setting-active.svg",
                //     width: 40,
                //   ),
                // ),
                label: '설정',
              ),
            ],
          ),
        ));
  }
}
