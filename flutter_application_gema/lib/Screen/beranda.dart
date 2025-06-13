import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

// Mengubah Beranda menjadi StatefulWidget untuk menangani data dinamis dari Firestore
class Beranda extends StatefulWidget {
  const Beranda({super.key});

  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  // Lokasi statis sesuai gambar
  final String _location = 'Indonesia, Sumatera Barat, Padang';

  // Controllers untuk menampilkan Nama Akun dan NIK
  final TextEditingController _namaAkunController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();

  // Instance Firebase Auth dan Firestore
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Memanggil fungsi untuk mengambil data pengguna
  }

  // Fungsi untuk mengambil data pengguna dari Firestore
  void _fetchUserData() {
    User? currentUser =
        _auth.currentUser; // Mendapatkan pengguna yang sedang login

    if (currentUser != null) {
      _firestore.collection('users').doc(currentUser.uid).snapshots().listen((
        snapshot,
      ) {
        if (snapshot.exists && snapshot.data() != null) {
          final userData = snapshot.data()!;
          setState(() {
            // Memperbarui controller dengan data dari Firestore
            _namaAkunController.text =
                userData['fullName'] ?? 'Nama Tidak Tersedia';
            _nikController.text = userData['nik'] ?? 'NIK Tidak Tersedia';
          });
        } else {
          // Handle jika dokumen pengguna tidak ada
          setState(() {
            _namaAkunController.text = 'Pengguna Tidak Ditemukan';
            _nikController.text = 'NIK Tidak Ditemukan';
          });
        }
      });
    } else {
      // Handle jika tidak ada pengguna yang login
      setState(() {
        _namaAkunController.text = 'Tidak Login';
        _nikController.text = 'Tidak Login';
      });
    }
  }

  @override
  void dispose() {
    _namaAkunController.dispose();
    _nikController.dispose();
    super.dispose();
  }

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
            child: StreamBuilder<QuerySnapshot>(
              // Mengambil data dari koleksi 'berita' di Firestore
              stream:
                  FirebaseFirestore.instance
                      .collection('berita')
                      .orderBy('tanggal', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada berita tersedia.'),
                  );
                } else {
                  // Mengambil daftar dokumen berita
                  final newsDocs = snapshot.data!.docs;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(
                      16.0,
                    ), // Padding di sekeliling konten
                    child: Column(
                      children: [
                        // Daftar Berita (News Cards) dibuat secara dinamis
                        ...newsDocs
                            .map((doc) => _buildNewsCard(context, doc))
                            .toList(),
                      ],
                    ),
                  );
                }
              },
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
                        child: TextField(
                          // Menggunakan TextField
                          controller:
                              _namaAkunController, // Menghubungkan controller
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
                        child: TextField(
                          // Menggunakan TextField
                          controller:
                              _nikController, // Menghubungkan controller
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

  // Mengubah _buildNewsCard untuk menerima data berita
  Widget _buildNewsCard(BuildContext context, DocumentSnapshot newsDoc) {
    // Mengambil data dari dokumen
    Map<String, dynamic> data = newsDoc.data() as Map<String, dynamic>;
    String judul = data['judul'] ?? 'Judul Berita';
    String kontenSingkat =
        (data['konten'] as String? ?? 'Konten berita tidak tersedia.')
            .substring(
              0,
              (data['konten'] as String? ?? '').length > 100
                  ? 100
                  : (data['konten'] as String? ?? '').length,
            ) +
        '...'; // Ambil 100 karakter pertama
    String beritaId = newsDoc.id; // Mendapatkan ID dokumen berita

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.grey[200], // Warna background abu-abu terang
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black, width: 0.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Placeholder Gambar (Anda bisa menggantinya dengan Image.network jika ada URL gambar)
              Container(
                width: 100,
                height: 100,
                color: Colors.black, // Warna hitam untuk placeholder gambar
                child: const Icon(
                  Icons.article, // Mengubah ikon dari close menjadi article
                  color: Colors.white,
                  size: 50,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      judul,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      kontenSingkat,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 30, // Tinggi tombol READ NEWS
                      child: ElevatedButton(
                        onPressed: () {
                          print(
                            'Navigating to BeritaScreen with ID: $beritaId',
                          );
                          // Navigasi ke BeritaScreen dan lewati ID berita
                          Navigator.pushNamed(
                            context,
                            '/beritaDetail',
                            arguments: beritaId,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.grey[600], // Warna abu-abu gelap
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
        ),
        const SizedBox(height: 15), // Spasi antar kartu berita
      ],
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
