import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore untuk data dashboard
// import 'package:flutter_application_gema/Screen/dashboard_admin.dart'; // TIDAK PERLU lagi mengimpor Dashboard Admin
import 'package:flutter_application_gema/Screen/verifikasi_pengguna.dart'; // Impor AdminUserVerificationScreen
import 'package:flutter_application_gema/Screen/verifikasi_monitoring_laporan_admin.dart'; // Impor VerifikasiMonitoringLaporanAdminScreen
import 'package:flutter_application_gema/Screen/profile_admin.dart'; // IMPOR HALAMAN PROFIL ADMIN
import 'package:flutter_application_gema/Screen/tambah_berita.dart'; // Impor AddNewsScreen (untuk tombol aksi cepat di dashboard)


class BerandaAdminScreen extends StatefulWidget {
  const BerandaAdminScreen({super.key});

  @override
  State<BerandaAdminScreen> createState() => _BerandaAdminScreenState();
}

class _BerandaAdminScreenState extends State<BerandaAdminScreen> {
  int _selectedIndex = 0; // Indeks item yang dipilih di BottomNavigationBar

  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Instance Firestore untuk data dashboard

  // States untuk menyimpan jumlah data dashboard
  int _totalUsers = 0;
  int _unverifiedUsers = 0;
  int _totalPrograms = 0;
  int _pendingPrograms = 0;
  bool _isLoadingDashboardData = true; // State untuk indikator loading dashboard

  @override
  void initState() {
    super.initState();
    _fetchDashboardData(); // Memanggil fungsi untuk mengambil data dashboard saat inisialisasi
  }

  // Fungsi untuk mengambil data ringkasan dari Firestore untuk dashboard
  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoadingDashboardData = true; // Set loading true saat memulai pengambilan data
    });

    try {
      final usersSnapshot = await _firestore.collection('users').count().get();
      final unverifiedUsersSnapshot = await _firestore.collection('users').where('verified', isEqualTo: false).count().get();
      final programsSnapshot = await _firestore.collection('programBantuan').count().get();
      final pendingProgramsSnapshot = await _firestore.collection('programBantuan').where('status', isEqualTo: 'Diajukan').count().get();

      setState(() {
        _totalUsers = usersSnapshot.count ?? 0;
        _unverifiedUsers = unverifiedUsersSnapshot.count ?? 0;
        _totalPrograms = programsSnapshot.count ?? 0;
        _pendingPrograms = pendingProgramsSnapshot.count ?? 0;
        _isLoadingDashboardData = false; // Set loading false setelah data diambil
      });
    } catch (e) {
      print('Error fetching dashboard data: $e');
      setState(() {
        _isLoadingDashboardData = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data dashboard: ${e.toString()}')),
        );
      });
    }
  }


  // Daftar widget untuk setiap halaman/menu di BottomNavigationBar
  // Indeks 0 akan menampilkan konten dashboard yang ada di BerandaAdminScreen ini.
  // Item lainnya akan dialihkan ke widget terpisah.
  static final List<Widget> _widgetOptions = <Widget>[
    // Index 0 akan menampilkan konten dashboard yang dibangun di method _buildDashboardContent
    // Jadi, untuk _selectedIndex = 0, kita tidak perlu widget terpisah di sini.
    // _widgetOptions.elementAt(0) tidak akan dipanggil jika _selectedIndex == 0.
    
    const AdminUserVerificationScreen(), // Index 1 di BottomNav, tapi di _widgetOptions ini adalah index 0
    const VerifikasiMonitoringLaporanAdminScreen(), // Index 2 di BottomNav, tapi di _widgetOptions ini adalah index 1
    const ProfileAdminScreen(), // Index 3 di BottomNav, tapi di _widgetOptions ini adalah index 2
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Memperbarui indeks item yang dipilih
    });
  }

  // Fungsi untuk menangani logout (logika ini sekarang ada di ProfileAdminScreen)
  void _performLogout() async {
     // Logika logout sepenuhnya ditangani di ProfileAdminScreen
     Navigator.pushReplacementNamed(context, '/'); // Placeholder
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Row( // AppBar kini lebih sederhana
          children: [
            Icon(Icons.location_on, color: Colors.black), // Contoh ikon lokasi
            SizedBox(width: 8),
            Text(
              'Indonesia, Sumatera Barat, Padang', // Lokasi statis
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ],
        ),
        automaticallyImplyLeading: true, // Kembali ke default untuk hamburger icon jika drawer tidak null
      ),
      // Menampilkan konten body berdasarkan _selectedIndex
      body: _selectedIndex == 0
          ? _buildDashboardContent() // Tampilkan konten dashboard jika indeks 0
          : _widgetOptions.elementAt(_selectedIndex - 1), // Tampilkan widget lain jika indeks > 0
      
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Verifikasi Pengguna',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Verifikasi Program',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex, // Indeks item yang saat ini aktif
        selectedItemColor: Colors.green[800], // Warna ikon/teks item aktif
        unselectedItemColor: Colors.grey, // Warna ikon/teks item tidak aktif
        onTap: _onItemTapped, // Panggil fungsi saat item ditekan
        type: BottomNavigationBarType.fixed, // Memastikan semua item terlihat
      ),
    );
  }

  // MARK: - Konten Dashboard (Dipindahkan dari DashboardAdminScreen)

  Widget _buildDashboardContent() {
    return _isLoadingDashboardData
        ? const Center(child: CircularProgressIndicator()) // Tampilkan loading jika data masih dimuat
        : RefreshIndicator( // Menambahkan fitur pull-to-refresh
            onRefresh: _fetchDashboardData, // Panggil fungsi fetch data saat refresh
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(), // Pastikan bisa digulir meski konten sedikit
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dashboard Nasional',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Section: Ringkasan Pengguna
                  _buildSectionTitle('Ringkasan Pengguna'),
                  const SizedBox(height: 15),
                  _buildStatCard('Total Pengguna', _totalUsers.toString(), Icons.group, Colors.blueAccent),
                  const SizedBox(height: 10),
                  _buildStatCard('Pengguna Menunggu Verifikasi', _unverifiedUsers.toString(), Icons.person_add_disabled, Colors.orange),
                  const SizedBox(height: 30),

                  // Section: Ringkasan Program Bantuan
                  _buildSectionTitle('Ringkasan Program Bantuan'),
                  const SizedBox(height: 15),
                  _buildStatCard('Total Program Diajukan', _totalPrograms.toString(), Icons.assignment, Colors.purple),
                  const SizedBox(height: 10),
                  _buildStatCard('Program Menunggu Verifikasi', _pendingPrograms.toString(), Icons.pending_actions, Colors.redAccent),
                  const SizedBox(height: 30),

                  // Section: Aksi Cepat (Tombol-tombol navigasi)
                  _buildSectionTitle('Aksi Cepat'),
                  const SizedBox(height: 15),
                  _buildActionButton(
                    context,
                    'Verifikasi Pengguna Baru',
                    Icons.how_to_reg,
                    Colors.green,
                    1, // Navigasi ke index 1 (Verifikasi Pengguna) di BottomNav
                  ),
                  const SizedBox(height: 10),
                  _buildActionButton(
                    context,
                    'Verifikasi Laporan Bantuan',
                    Icons.check_circle_outline,
                    Colors.deepOrange,
                    2, // Navigasi ke index 2 (Verifikasi Program) di BottomNav
                  ),
                  const SizedBox(height: 10),
                  _buildActionButton(
                    context,
                    'Tambah Berita Baru',
                    Icons.add_box,
                    Colors.blueGrey,
                    // Untuk halaman Tambah Berita, kita akan navigasi menggunakan Navigator.push
                    // karena halaman ini tidak ada di BottomNavigationBar utama.
                    '/add_news_screen', // Pastikan rute ini terdaftar di main.dart
                  ),
                ],
              ),
            ),
          );
  }

  // Widget pembangun judul bagian
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  // Widget pembangun kartu statistik
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget pembangun tombol aksi cepat
  // Kini menerima int index untuk BottomNavigationBar atau String routeName untuk Navigator.pushNamed
  Widget _buildActionButton(BuildContext context, String title, IconData icon, Color color, dynamic target) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          if (target is int) {
            // Jika target adalah integer, itu adalah indeks BottomNavigationBar
            _onItemTapped(target); // Panggil _onItemTapped untuk mengubah tab
          } else if (target is String) {
            // Jika target adalah String, itu adalah rute Navigator.pushNamed
            Navigator.pushNamed(context, target);
          }
        },
        icon: Icon(icon, color: Colors.white),
        label: Text(
          title,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 3,
        ),
      ),
    );
  }
}
