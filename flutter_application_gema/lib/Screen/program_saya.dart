import 'package:flutter/material.dart';

// Import halaman-halaman lain yang akan dihubungkan melalui BottomNavigationBar
// Sesuaikan path import ini dengan lokasi file Anda di proyek.
// Contoh:
// import 'package:flutter_application_gema/pages/home_screen.dart';
// import 'package:flutter_application_gema/pages/ajukan_bantuan_screen.dart';
// import 'package:flutter_application_gema/pages/bantuan_aplikasi_screen.dart';
// import 'package:flutter_application_gema/pages/login_page.dart'; // Untuk logout

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GEMA Bantuan Saya',
      debugShowCheckedModeBanner: false, // Menghilangkan debug banner
      theme: ThemeData(
        primarySwatch: Colors.grey, // Tema warna utama
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto', // Contoh font
      ),
      // Anda harus mendefinisikan rute di sini atau di file `main.dart` utama aplikasi Anda
      // Jika ini adalah file terpisah (misal bantuan_saya_screen.dart), maka rute harus ada di main.dart
      home:
          const BantuanSayaScreen(), // Untuk tujuan demo, ini adalah halaman awal
    );
  }
}

class BantuanSayaScreen extends StatelessWidget {
  const BantuanSayaScreen({super.key});

  final String _location = 'Indonesia, Sumatera Barat, Padang'; // Lokasi statis

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang putih
      appBar: AppBar(
        title: const Text(
          'Bantuan saya',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading:
            false, // Menghilangkan tombol back default jika ada
      ),
      body: Column(
        children: [
          // Bagian Header Kustom (GEMA, Nama Akun, NIK, Lokasi) - sama dengan layar Beranda
          _buildCustomHeader(),
          // Garis pembatas horizontal tipis
          Container(
            height: 1,
            color: Colors.black,
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(
                16.0,
              ), // Padding di sekeliling konten
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Rata kiri untuk judul
                children: [
                  const Text(
                    'PROGRAM SAYA',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Kotak untuk "Nama Usaha", "Status", "Deskripsi Usaha"
                  _buildProgramSayaBox(),
                  const SizedBox(height: 25), // Spasi antara dua bagian utama

                  const Text(
                    'PROGRAM YANG TERSEDIA :',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Kotak untuk "PROGRAM YANG TERSEDIA"
                  _buildProgramTersediaBox(),
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

  // MARK: - Custom Widgets (Sama dengan kode Beranda)

  Widget _buildCustomHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'GEMA',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              letterSpacing: 2.0,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Icon(Icons.person, size: 30, color: Colors.black),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(height: 2),
                      const Text(
                        'NIK',
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
              const SizedBox(height: 5),
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

  Widget _buildProgramSayaBox() {
    return Container(
      width: double.infinity, // Lebar penuh
      padding: const EdgeInsets.all(20.0), // Padding di dalam kotak
      decoration: BoxDecoration(
        color: Colors.grey[300], // Warna abu-abu yang lebih terang
        borderRadius: BorderRadius.circular(10), // Sudut membulat
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri
        children: [
          Text(
            'Nama Usaha :',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          SizedBox(height: 10),
          Text('Status :', style: TextStyle(fontSize: 16, color: Colors.black)),
          SizedBox(height: 10),
          Text(
            'Deskripsi Usaha:',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramTersediaBox() {
    return Container(
      width: double.infinity, // Lebar penuh
      height: 200, // Tinggi fixed untuk kotak ini (bisa disesuaikan)
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.grey[300], // Warna abu-abu yang lebih terang
        borderRadius: BorderRadius.circular(10),
      ),
      // Konten di sini bisa berupa ListView.builder jika ada banyak program
      // Untuk saat ini, biarkan kosong sebagai placeholder
      child: const Center(
        child: Text(
          '', // Kosong sesuai gambar
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
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
