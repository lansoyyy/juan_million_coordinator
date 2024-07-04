import 'package:flutter/material.dart';
import 'package:juan_million/screens/admin_tabs/community_tab.dart';
import 'package:juan_million/screens/admin_tabs/wallet_tab.dart';
import 'package:juan_million/utlis/colors.dart';

import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  var _currentIndex = 0;

  List tabs = [
    const WalletTab(),
    const CommunityTab(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: tabs[_currentIndex],
      bottomNavigationBar: SalomonBottomBar(
        backgroundColor: blue,
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          /// Home
          SalomonBottomBarItem(
            icon: Icon(
              Icons.wallet,
              color: _currentIndex == 0 ? Colors.white : Colors.black,
            ),
            title: const Text(
              "Cash Wallet",
              style: TextStyle(fontFamily: 'Bold'),
            ),
            selectedColor: Colors.white,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.groups_2_outlined),
            title: const Text(
              "Community Wallet",
              style: TextStyle(fontFamily: 'Bold'),
            ),
            selectedColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
