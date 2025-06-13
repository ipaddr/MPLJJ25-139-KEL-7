import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

// Mengubah AboutAplikasiScreen menjadi StatefulWidget
class AboutAplikasiScreen extends StatefulWidget {
  const AboutAplikasiScreen({super.key});

  @override
  State<AboutAplikasiScreen> createState() => _AboutAplikasiScreenState();
}

class _AboutAplikasiScreenState extends State<AboutAplikasiScreen> {
  final String _location = 'Indonesia, Sumatera Barat, Padang'; // Lokasi statis

  // Controllers untuk menampilkan Nama Akun dan NIK di header
  final TextEditingController _namaAkunHeaderController =
      TextEditingController();
  final TextEditingController _nikHeaderController = TextEditingController();

  // Instance Firebase Auth dan Firestore
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Memanggil fungsi untuk mengambil data pengguna untuk header
  }

  // Fungsi untuk mengambil data pengguna dari Firestore untuk header
  void _fetchUserData() {
    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      _firestore.collection('users').doc(currentUser.uid).snapshots().listen((
        userSnapshot,
      ) {
        if (userSnapshot.exists && userSnapshot.data() != null) {
          final userData = userSnapshot.data()!;
          setState(() {
            _namaAkunHeaderController.text =
                userData['fullName'] ?? 'Nama Tidak Tersedia';
            _nikHeaderController.text = userData['nik'] ?? 'NIK Tidak Tersedia';
          });
        } else {
          // Handle jika dokumen pengguna tidak ada
          setState(() {
            _namaAkunHeaderController.text = 'Pengguna Tidak Ditemukan';
            _nikHeaderController.text = 'NIK Tidak Ditemukan';
          });
        }
      });
    } else {
      // Jika tidak ada pengguna yang login
      setState(() {
        _namaAkunHeaderController.text = 'Tidak Login';
        _nikHeaderController.text = 'Tidak Login';
      });
    }
  }

  @override
  void dispose() {
    _namaAkunHeaderController.dispose();
    _nikHeaderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang putih
      appBar: AppBar(
        title: const Text(
          'Bantuan Aplikasi',
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
                crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri
                children: [
                  // Pusat Bantuan Informasi
                  const Text(
                    'Pusat Bantuan Informasi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Kotak deskripsi
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[300], // Warna abu-abu terang
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Halaman ini menyediakan informasi dan panduan untuk membantu pengguna memahami cara menggunakan platform GEMA serta menyelesaikan masalah yang umum terjadi.',
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                      textAlign: TextAlign.justify, // Rata kanan-kiri
                    ),
                  ),
                  const SizedBox(height: 25),

                  // FAQ (Pertanyaaan yang Sering Diajukan)
                  const Text(
                    'FAQ (Pertanyaaan yang Sering Diajukan)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Daftar FAQ (menggunakan Column dengan Text dan bullet point)
                  _buildFaqItem('Bagaimana cara mengajukan program?'),
                  const SizedBox(height: 10),
                  _buildFaqItem('Apa syarat verifikasi data?'),
                  const SizedBox(height: 10),
                  _buildFaqItem('Bagaimana mengecek status program saya?'),
                  const SizedBox(height: 30),

                  // Pesan privasi
                  const Text(
                    'Data anda akan dijaga kerahasiaannya sesuai kebijakan privasi platform GEMA',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                    textAlign: TextAlign.justify, // Rata kanan-kiri
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
                        child: TextField(
                          // Menggunakan TextField
                          controller:
                              _namaAkunHeaderController, // Menghubungkan controller
                          readOnly: true, // Read-only
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
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
                        child: TextField(
                          // Menggunakan TextField
                          controller:
                              _nikHeaderController, // Menghubungkan controller
                          readOnly: true, // Read-only
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
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

  // Widget pembantu untuk item FAQ dengan bullet point
  Widget _buildFaqItem(String question) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.grey[300], // Background abu-abu terang
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment
                .start, // Agar bullet point sejajar dengan baris pertama teks
        children: [
          const Text(
            '• ', // Bullet point
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          Expanded(
            child: Text(
              question,
              style: const TextStyle(fontSize: 16, color: Colors.black),
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
                color: Color.fromARGB(255, 255, 255, 255),
                size: 30,
              ), // Warna putih
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
                color: Colors.green,
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
