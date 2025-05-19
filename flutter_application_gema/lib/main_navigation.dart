import 'package:flutter/material.dart';
import 'login_user.dart';
import 'beranda_page.dart';
import 'program_saya_page.dart';
import 'ajukan_program_page.dart';
import 'bantuan_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    // TANPA const
    BerandaPage(),
    ProgramSayaPage(),
    AjukanProgramPage(),
    BantuanPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Program Saya',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.send), label: 'Ajukan'),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: 'Bantuan'),
        ],
      ),
    );
  }
}
