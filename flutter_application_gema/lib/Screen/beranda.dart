import 'package:flutter/material.dart';

// Import halaman-halaman lain yang akan dihubungkan melalui BottomNavigationBar
// Sesuaikan path import ini dengan lokasi file Anda di proyek.
// Contoh:
// import 'package:flutter_application_gema/pages/login_page.dart'; // Jika ingin ada tombol logout ke login
// import 'package:flutter_application_gema/pages/program_saya_screen.dart';
// import 'package:flutter_application_gema/pages/ajukan_bantuan_screen.dart';
// import 'package:flutter_application_gema/pages/bantuan_aplikasi_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GEMA Beranda',
      debugShowCheckedModeBanner: false, // Menghilangkan debug banner
      theme: ThemeData(
        primarySwatch: Colors.grey, // Menggunakan abu-abu sebagai warna utama
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto', // Contoh font, bisa disesuaikan
      ),
      // Anda harus mendefinisikan rute di sini atau di file `main.dart` utama aplikasi Anda
      // Jika ini adalah file terpisah (misal home_screen.dart), maka rute harus ada di main.dart
      home: const Beranda(), // Untuk tujuan demo, ini adalah halaman awal
    );
  }
}

class Beranda extends StatelessWidget {
  const Beranda({super.key});

  // Lokasi statis sesuai gambar
  final String _location = 'Indonesia, Sumatera Barat, Padang';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang putih
      appBar: AppBar(
        title: const Text(
          'Beranda',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading:
            false, // Menghilangkan tombol back default jika ada
      ),
      body: Column(
        children: [
          // Bagian Header Kustom (GEMA, Nama Akun, NIK, Lokasi)
          _buildCustomHeader(),
          // Garis pembatas horizontal tipis
          Container(
            height: 1,
            color: Colors.black,
            margin: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ), // Margin agar tidak sampai pinggir layar
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(
                16.0,
              ), // Padding di sekeliling konten
              child: Column(
                children: [
                  // Daftar Berita (News Cards)
                  _buildNewsCard(),
                  const SizedBox(height: 15),
                  _buildNewsCard(),
                  const SizedBox(height: 15),
                  _buildNewsCard(),
                  const SizedBox(height: 15),
                  // Tambahkan lebih banyak _buildNewsCard jika diperlukan
                ],
              ),
            ),
          ),
          // Garis pembatas horizontal tipis di atas bottom navigation
          Container(height: 1, color: Colors.black),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(
        context,
      ), // Meneruskan context
    );
  }

  // MARK: - Custom Widgets

  Widget _buildCustomHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start, // Align item ke atas
        children: [
          // GEMA
          const Text(
            'GEMA',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              letterSpacing: 2.0,
            ),
          ),
          // Icon, Nama Akun, NIK, Lokasi
          Column(
            crossAxisAlignment: CrossAxisAlignment.end, // Align teks ke kanan
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Icon(Icons.person, size: 30, color: Colors.black),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Teks input rata kiri
                    children: [
                      const Text(
                        'Nama Akun',
                        style: TextStyle(fontSize: 10, color: Colors.black),
                      ),
                      Container(
                        width: 120,
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 0.5),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(fontSize: 12, color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: 2), // Spasi kecil antara input
                      const Text(
                        'NIK', // Placeholder untuk NIK
                        style: TextStyle(fontSize: 10, color: Colors.black),
                      ),
                      Container(
                        width: 120,
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 0.5),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(fontSize: 12, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
              ), // Spasi antara Nama Akun/NIK dan lokasi
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _location,
                    style: const TextStyle(fontSize: 11, color: Colors.black),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard() {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.grey[200], // Warna background abu-abu terang
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Placeholder Gambar
          Container(
            width: 100,
            height: 100,
            color: Colors.black, // Warna hitam untuk placeholder gambar
            child: const Icon(
              Icons.close,
              color: Colors.white,
              size: 50,
            ), // Ikon 'X'
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Placeholder Teks Berita (Garis-garis hitam)
                Container(
                  height: 10,
                  color: Colors.black,
                  width: double.infinity,
                ),
                const SizedBox(height: 5),
                Container(
                  height: 10,
                  color: Colors.black,
                  width: double.infinity,
                ),
                const SizedBox(height: 5),
                Container(
                  height: 10,
                  color: Colors.black,
                  width: 80, // Baris terakhir lebih pendek
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 30, // Tinggi tombol READ NEWS
                  child: ElevatedButton(
                    onPressed: () {
                      print('Read News button pressed');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600], // Warna abu-abu gelap
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'READ NEWS',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Mengubah _buildBottomNavigationBar menjadi metode yang menerima BuildContext
  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomAppBar(
      color: Colors.black, // Background hitam
      child: SizedBox(
        height: 60, // Tinggi BottomAppBar
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              // Ikon Home (Beranda) - Aktif karena sedang di halaman ini
              icon: const Icon(
                Icons.grid_view,
                color: Colors.green,
                size: 30,
              ), // Warna hijau untuk indikator aktif
              onPressed: () {
                print('Home Grid pressed (Already on Home)');
                Navigator.pushReplacementNamed(context, '/beranda');
              },
            ),
            IconButton(
              icon: const Icon(Icons.map, color: Colors.white, size: 30),
              onPressed: () {
                print('Bantuan Saya pressed');
                Navigator.pushReplacementNamed(context, '/programSaya');
              },
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 30),
              onPressed: () {
                print('Send pressed');
                // Navigasi ke halaman Ajukan Bantuan
                Navigator.pushReplacementNamed(context, '/ajukanBantuan');
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.help_outline,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                print('Archive pressed');
                // Navigasi ke halaman Program Saya (Bantuan Aplikasi)
                Navigator.pushReplacementNamed(context, '/aboutAplikasi');
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
                size: 30,
              ), // Mengubah ikon dari logout ke bantuan
              onPressed: () {
                print('Help pressed');
                // Navigasi ke halaman Bantuan Aplikasi
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
    );
  }
}
