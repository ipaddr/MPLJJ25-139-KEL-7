import 'package:flutter/material.dart';
import 'package:flutter_application_gema/Screen/dashboard_admin.dart'; // Impor Dashboard Admin
import 'package:flutter_application_gema/Screen/data_penerimaan_bantuan_admin.dart'; // Impor Data Penerimaan Bantuan Admin
import 'package:flutter_application_gema/Screen/verifikasi_monitoring_laporan_admin.dart'; // Impor Verifikasi Monitoring Laporan Admin
import 'package:flutter_application_gema/Screen/statistik_laporan_admin.dart'; // Impor Statistik Laporan Admin

class BerandaAdminScreen extends StatefulWidget {
  const BerandaAdminScreen({super.key});

  @override
  State<BerandaAdminScreen> createState() => _BerandaAdminScreenState();
}

class _BerandaAdminScreenState extends State<BerandaAdminScreen> {
  int _selectedIndex = 0; // Indeks item yang dipilih di drawer

  // Daftar widget untuk setiap halaman/menu
  static final List<Widget> _widgetOptions = <Widget>[
    const DashboardAdminScreen(), // Halaman Dashboard Admin
    const DataPenerimaanBantuanAdminScreen(), // Halaman Data Penerima Bantuan Admin
    const VerifikasiMonitoringLaporanAdminScreen(), // Halaman Verifikasi Monitoring Laporan Admin
    const StatistikLaporanAdminScreen(), // Halaman Statistik Laporan Admin
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Memperbarui indeks item yang dipilih
    });
    // Jika bukan di layar besar, tutup drawer setelah item dipilih
    if (MediaQuery.of(context).size.width <= 600) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // Latar belakang AppBar putih
        elevation: 1, // Sedikit bayangan di bawah AppBar
        title: Row(
          children: [
            // Bendera Indonesia
            Image.asset(
              'assets/indonesia_flag.png', // Ganti dengan path gambar bendera Anda
              width: 30,
              height: 20,
              errorBuilder: (context, error, stackTrace) {
                return Image.network(
                  'https://placehold.co/30x20/000000/FFFFFF?text=ID', // Placeholder jika gambar tidak ditemukan
                  width: 30,
                  height: 20,
                );
              },
            ),
            const SizedBox(width: 8),
            const Text(
              'Indonesia, Sumatera Barat, Padang', // Lokasi
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            const Spacer(), // Memberikan spasi
            const Icon(Icons.person, color: Colors.green), // Ikon pengguna
            const SizedBox(width: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Nama',
                  style: TextStyle(fontSize: 12, color: Colors.black),
                ),
                Text(
                  'Akun',
                  style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                ),
              ],
            ),
            const Icon(
              Icons.arrow_drop_down,
              color: Colors.black,
            ), // Ikon drop-down
          ],
        ),
      ),
      drawer:
          MediaQuery.of(context).size.width <= 600
              ? Drawer(
                child: _buildDrawerContent(context), // Konten drawer
              )
              : null, // Jika layar besar, jangan tampilkan drawer
      body: Row(
        children: [
          // Bagian sidebar (hanya terlihat di layar besar)
          if (MediaQuery.of(context).size.width > 600)
            SizedBox(
              width: 250, // Lebar sidebar
              child: _buildDrawerContent(
                context,
                isSidebar: true,
              ), // Konten sidebar
            ),
          // Bagian konten utama
          Expanded(
            child: _widgetOptions.elementAt(
              _selectedIndex,
            ), // Menampilkan widget sesuai pilihan
          ),
        ],
      ),
    );
  }

  // Fungsi pembangun konten drawer/sidebar
  Widget _buildDrawerContent(BuildContext context, {bool isSidebar = false}) {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          decoration: const BoxDecoration(
            color: Colors.white, // Latar belakang header drawer/sidebar putih
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Logo GEMA
                  Image.asset(
                    'assets/gema_logo.png', // Ganti dengan path gambar logo Anda
                    width: 50,
                    height: 50,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.network(
                        'https://placehold.co/50x50/CCCCCC/FFFFFF?text=GEMA', // Placeholder jika gambar tidak ditemukan
                        width: 50,
                        height: 50,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'GEMA',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: Colors.black,
                  ), // Ikon jam
                  const SizedBox(width: 8),
                  const Text('00:00', style: TextStyle(color: Colors.black)),
                  const SizedBox(width: 24),
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.black,
                  ), // Ikon kalender
                  const SizedBox(width: 8),
                  const Text('XX/XX/XX', style: TextStyle(color: Colors.black)),
                ],
              ),
            ],
          ),
        ),
        // Item menu drawer/sidebar
        _buildDrawerItem(
          0,
          Icons.dashboard,
          'Dashboard Nasional',
          isSidebar: isSidebar,
        ),
        _buildDrawerItem(
          1,
          Icons.people,
          'Data Penerima Bantuan',
          isSidebar: isSidebar,
        ),
        _buildDrawerItem(
          2,
          Icons.verified_user,
          'Verifikasi Monitoring Lapangan',
          isSidebar: isSidebar,
        ),
        _buildDrawerItem(
          3,
          Icons.bar_chart,
          'Statistik Laporan',
          isSidebar: isSidebar,
        ),
        _buildDrawerItem(4, Icons.logout, 'Log Out', isSidebar: isSidebar),
      ],
    );
  }

  // Fungsi pembangun item drawer/sidebar
  Widget _buildDrawerItem(
    int index,
    IconData icon,
    String title, {
    bool isSidebar = false,
  }) {
    return Container(
      color:
          _selectedIndex == index
              ? Colors.green.withOpacity(0.1)
              : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(title, style: const TextStyle(color: Colors.black)),
        onTap: () {
          _onItemTapped(index);
        },
      ),
    );
  }
}
