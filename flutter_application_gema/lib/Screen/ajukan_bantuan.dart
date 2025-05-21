import 'package:flutter/material.dart';

// Import halaman-halaman lain yang akan dihubungkan melalui BottomNavigationBar
// Sesuaikan path import ini dengan lokasi file Anda di proyek.
// Contoh:
// import 'package:flutter_application_gema/pages/home_screen.dart';
// import 'package:flutter_application_gema/pages/program_saya_screen.dart';
// import 'package:flutter_application_gema/pages/bantuan_aplikasi_screen.dart';
// import 'package:flutter_application_gema/pages/ajukan_bantuan_screen.dart'; // Import diri sendiri jika ingin navigasi ke diri sendiri (opsional)

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GEMA Ajukan Bantuan',
      debugShowCheckedModeBanner: false, // Menghilangkan debug banner
      theme: ThemeData(
        primarySwatch: Colors.grey, // Tema warna utama
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto', // Contoh font
      ),
      // Di sini Anda biasanya akan mendefinisikan semua rute yang ada di aplikasi Anda
      // Saya tidak akan mengulang semua rute di sini karena ini adalah file halaman,
      // tapi pastikan Anda telah mendefinisikannya di `main.dart`
      home:
          const AjukanBantuanScreen(), // AjukanBantuanScreen sebagai halaman awal untuk contoh ini
    );
  }
}

class AjukanBantuanScreen extends StatelessWidget {
  const AjukanBantuanScreen({super.key});

  final String _location = 'Indonesia, Sumatera Barat, Padang'; // Lokasi statis

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang putih
      appBar: AppBar(
        title: const Text(
          'Ajukan Bantuan',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading:
            false, // Menghilangkan tombol back default jika ada
      ),
      body: Column(
        children: [
          // Bagian Header Kustom (GEMA, Nama Akun, NIK, Lokasi) - Konsisten
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
                    CrossAxisAlignment.start, // Rata kiri untuk label input
                children: [
                  // Nama Program
                  const Text(
                    'Nama Program :',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  _buildInputField(),
                  const SizedBox(height: 25), // Spasi antar input
                  // Deskripsi Program
                  const Text(
                    'Deskripsi Program :',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  _buildMultiLineInputField(), // Input multi-baris
                  const SizedBox(height: 25),

                  // Kategori Usaha
                  const Text(
                    'Kategori Usaha :',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  _buildInputField(),
                  const SizedBox(height: 30), // Spasi sebelum tombol
                  // Tombol AJUKAN
                  SizedBox(
                    width: double.infinity, // Lebar tombol penuh
                    height: 50, // Tinggi tombol
                    child: ElevatedButton(
                      onPressed: () {
                        print('AJUKAN button pressed');
                        // Logika untuk mengirim pengajuan
                        // Anda bisa menambahkan konfirmasi atau navigasi ke halaman lain setelah pengajuan
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF2C4372,
                        ), // Warna biru gelap sesuai gambar
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            8,
                          ), // Sudut membulat
                        ),
                        elevation: 5, // Sedikit bayangan
                      ),
                      child: const Text(
                        'AJUKAN',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
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

  // MARK: - Custom Widgets (Konsisten dengan halaman sebelumnya)

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

  // Widget untuk input field standar (satu baris)
  Widget _buildInputField() {
    return Container(
      height: 40, // Tinggi fixed untuk input field
      decoration: BoxDecoration(
        color: Colors.grey[300], // Background abu-abu terang
        borderRadius: BorderRadius.circular(8), // Sudut membulat
      ),
      child: const TextField(
        decoration: InputDecoration(
          border: InputBorder.none, // Tanpa border bawaan TextField
          contentPadding: EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 10,
          ), // Padding konten
        ),
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  // Widget untuk input field multi-baris (Deskripsi Program)
  Widget _buildMultiLineInputField() {
    return Container(
      height: 120, // Tinggi fixed untuk multi-line input
      decoration: BoxDecoration(
        color: Colors.grey[300], // Background abu-abu terang
        borderRadius: BorderRadius.circular(8),
      ),
      child: const TextField(
        maxLines: null, // Memungkinkan input multi-baris
        keyboardType:
            TextInputType.multiline, // Menggunakan keyboard multi-baris
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        ),
        style: TextStyle(color: Colors.black),
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
