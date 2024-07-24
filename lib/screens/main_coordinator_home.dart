import 'package:flutter/material.dart';
import 'package:juan_million/screens/auth/login_screen.dart';
import 'package:juan_million/screens/coordinator_home.dart';
import 'package:juan_million/screens/landing_screen.dart';
import 'package:juan_million/screens/pages/coordinator_wallet.dart';

import '../utlis/colors.dart';
import '../widgets/text_widget.dart';
import 'pages/customer/myqr_page.dart';

class MainCoordinatorHomeScreen extends StatefulWidget {
  const MainCoordinatorHomeScreen({super.key});

  @override
  State<MainCoordinatorHomeScreen> createState() =>
      _MainCoordinatorHomeScreenState();
}

class _MainCoordinatorHomeScreenState extends State<MainCoordinatorHomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const CoordinatorHomeScreen(),
    const CoordinatorWallet(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: blue,
        title: TextWidget(
          text: 'Home',
          fontSize: 18,
          color: Colors.white,
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const MyQRPage()));
            },
            icon: const Icon(
              Icons.qr_code,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: const Text(
                          'Logout Confirmation',
                          style: TextStyle(
                              fontFamily: 'QBold', fontWeight: FontWeight.bold),
                        ),
                        content: const Text(
                          'Are you sure you want to Logout?',
                          style: TextStyle(fontFamily: 'QRegular'),
                        ),
                        actions: <Widget>[
                          MaterialButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text(
                              'Close',
                              style: TextStyle(
                                  fontFamily: 'QRegular',
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          MaterialButton(
                            onPressed: () async {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const LoginScreen()));
                            },
                            child: const Text(
                              'Continue',
                              style: TextStyle(
                                  fontFamily: 'QRegular',
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ));
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: blue,
        unselectedItemColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet),
            label: 'Wallet',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: secondary,
        onTap: _onItemTapped,
      ),
    );
  }
}
