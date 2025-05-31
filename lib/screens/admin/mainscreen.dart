import 'package:flutter/material.dart';

import 'report_management_screen.dart';
import 'reported_accounts_screen.dart';
import 'user_accounts_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    ReportManagementScreen(),
    ReportedAccountsScreen(),
    UserAccountsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Quản lý tố cáo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: 'Bị tố cáo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Người dùng',
          ),
        ],
      ),
    );
  }
}
