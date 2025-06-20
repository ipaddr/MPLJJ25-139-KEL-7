// lib/Screen/admin_main_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_gema/service/auth_service.dart';
import 'package:flutter_application_gema/Screen/data_penerimaan_bantuan_admin.dart';
// UBAH IMPORT INI KEMBALI KE NAMA FILE LAMA
import 'package:flutter_application_gema/Screen/verifikasi_monitoring_laporan_admin.dart'; // <<< KEMBALIKAN KE NAMA FILE INI
import 'package:flutter_application_gema/Screen/dashboard_admin.dart';


class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const DashboardAdminScreen(),
    const DataPenerimaanBantuanAdminScreen(),
    // UBAH NAMA KELAS DI SINI KEMBALI KE NAMA LAMA
    const VerifikasiMonitoringLaporanAdminScreen(), // <<< KEMBALIKAN KE NAMA KELAS INI
    const Text('Halaman Pengaturan Admin', style: TextStyle(fontSize: 30)),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GEMA ID Admin',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green[700],
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () async {
              await _authService.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt),
            label: 'Penerima',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in),
            label: 'Verifikasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.grey[600],
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
      ),
    );
  }
}