import 'package:flutter/material.dart';
import 'package:flutter_application_gema/Screen/verifikasi_pengguna.dart'; // Impor Data Penerimaan Bantuan Admin
import 'package:flutter_application_gema/Screen/verifikasi_monitoring_laporan_admin.dart'; // Impor Verifikasi Monitoring Laporan Admin
import 'package:flutter_application_gema/Screen/statistik_laporan_admin.dart'; // Impor Statistik Laporan Admin
import 'package:flutter_application_gema/Screen/tambah_berita.dart'; // <<< IMPOR HALAMAN TAMBAH BERITA BARU

class BerandaAdminScreen extends StatefulWidget {
  const BerandaAdminScreen({super.key});

  @override
  State<BerandaAdminScreen> createState() => _BerandaAdminScreenState();
}

class _BerandaAdminScreenState extends State<BerandaAdminScreen> {
  int _selectedIndex = 0; // Indeks item yang dipilih di drawer

  // Daftar widget untuk setiap halaman/menu
  // Sesuaikan urutan ini dengan indeks yang Anda gunakan di _buildDrawerItem
  static final List<Widget> _widgetOptions = <Widget>[
    const BerandaAdminScreen(), // 0: Halaman Dashboard Admin
    const AdminUserVerificationScreen(), // 1: Halaman Verifikasi Pengguna Baru (sebelumnya Data Penerima Bantuan Admin, saya asumsikan ini yang Anda maksud)
    const VerifikasiMonitoringLaporanAdminScreen(), // 2: Halaman Verifikasi Monitoring Laporan Admin
    const StatistikLaporanAdminScreen(), // 3: Halaman Statistik Laporan Admin
    const AddNewsScreen(), // <<< 4: Halaman Tambah Berita Baru
    // Tambahkan halaman lain di sini sesuai kebutuhan
  ];

  void _onItemTapped(int index) {
    // Logika untuk Log Out (indeks terakhir)
    if (index == _widgetOptions.length) { // Jika indeks adalah untuk Log Out
      _performLogout(); // Panggil fungsi logout
      return; // Hentikan fungsi agar tidak update _selectedIndex atau navigasi lain
    }
    setState(() {
      _selectedIndex = index; // Memperbarui indeks item yang dipilih
    });
    // Jika bukan di layar besar, tutup drawer setelah item dipilih
    if (MediaQuery.of(context).size.width <= 600) {
      Navigator.pop(context);
    }
  }

  // Fungsi untuk menangani logout
  void _performLogout() async {
    // Anda perlu mengimpor AuthService dan FirebaseAuth di sini
    // import 'package:firebase_auth/firebase_auth.dart';
    // import 'package:flutter_application_gema/service/auth_service.dart';

    // final FirebaseAuth _auth = FirebaseAuth.instance;
    // final AuthService _authService = AuthService();

    // try {
    //   await _authService.signOut(); // Panggil fungsi signOut dari AuthService
    //   Navigator.pushReplacementNamed(context, '/'); // Kembali ke halaman login
    // } catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Gagal logout: ${e.toString()}')),
    //   );
    // }
     // Placeholder untuk demo, Anda harus mengganti dengan logika logout sebenarnya
    Navigator.pushReplacementNamed(context, '/');
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
                  'Nama', // TODO: Ambil nama admin dari Firestore
                  style: TextStyle(fontSize: 12, color: Colors.black),
                ),
                Text(
                  'Akun', // TODO: Ambil role admin dari Firestore
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
                  const Text('00:00', style: TextStyle(color: Colors.black)), // TODO: Ambil waktu sebenarnya
                  const SizedBox(width: 24),
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.black,
                  ), // Ikon kalender
                  const SizedBox(width: 8),
                  const Text('XX/XX/XX', style: TextStyle(color: Colors.black)), // TODO: Ambil tanggal sebenarnya
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
          Icons.people, // Ikon untuk verifikasi pengguna
          'Verifikasi Pengguna', // Mengubah label
          isSidebar: isSidebar,
        ),
        _buildDrawerItem(
          2,
          Icons.verified_user, // Mengubah ikon agar lebih relevan dengan monitoring/verifikasi laporan
          'Verifikasi Monitoring Laporan', // Mengubah label
          isSidebar: isSidebar,
        ),
        _buildDrawerItem(
          3,
          Icons.bar_chart,
          'Statistik Laporan',
          isSidebar: isSidebar,
        ),
        // <<< ITEM MENU BARU UNTUK TAMBAH BERITA
        _buildDrawerItem(
          4,
          Icons.newspaper, // Ikon untuk berita
          'Tambah Berita',
          isSidebar: isSidebar,
        ),
        // >>>

        // Item Log Out - Indeksnya disesuaikan dengan jumlah item di _widgetOptions
        _buildDrawerItem(_widgetOptions.length, Icons.logout, 'Log Out', isSidebar: isSidebar),
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
