import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

// Mengubah AjukanBantuanScreen menjadi StatefulWidget
class AjukanBantuanScreen extends StatefulWidget {
  const AjukanBantuanScreen({super.key});

  @override
  State<AjukanBantuanScreen> createState() => _AjukanBantuanScreenState();
}

class _AjukanBantuanScreenState extends State<AjukanBantuanScreen> {
  final String _location = 'Indonesia, Sumatera Barat, Padang'; // Lokasi statis

  // Controllers untuk input form pengajuan
  final TextEditingController _namaProgramController = TextEditingController();
  final TextEditingController _deskripsiProgramController = TextEditingController();
  final TextEditingController _kategoriUsahaController = TextEditingController();

  // Controllers untuk menampilkan Nama Akun dan NIK di header
  final TextEditingController _namaAkunHeaderController = TextEditingController();
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
      // Mengambil data pengguna dari koleksi 'users' tingkat atas
      _firestore.collection('users').doc(currentUser.uid).snapshots().listen((
        userSnapshot,
      ) {
        if (userSnapshot.exists && userSnapshot.data() != null) {
          final userData = userSnapshot.data()!;
          setState(() {
            _namaAkunHeaderController.text = userData['fullName'] ?? 'Nama Tidak Tersedia';
            _nikHeaderController.text = userData['nik'] ?? 'NIK Tidak Tersedia';
          });
        }
      });
    } else {
      setState(() {
        _namaAkunHeaderController.text = 'Tidak Login';
        _nikHeaderController.text = 'Tidak Login';
      });
    }
  }

  // Fungsi untuk menyimpan pengajuan program ke Firestore
  Future<void> _submitProgram() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus login untuk mengajukan bantuan.'),
        ),
      );
      return;
    }

    // --- Perubahan Penting di Sini: Memverifikasi Usaha di Koleksi Top-Level 'usaha' ---
    // Mencari dokumen usaha milik pengguna yang sedang login di koleksi 'usaha'
    final userBusinessQuery = await _firestore
        .collection('usaha') // Mengakses koleksi 'usaha' tingkat atas
        .where('userId', isEqualTo: currentUser.uid) // Memfilter berdasarkan userId
        .limit(1) // Ambil hanya satu dokumen usaha (asumsi 1 user = 1 usaha utama)
        .get();

    if (userBusinessQuery.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Anda harus mengisi data usaha terlebih dahulu di bagian "Usaha Saya".', // Pesan disesuaikan
          ),
        ),
      );
      return;
    }

    // Ambil ID dokumen usaha yang ditemukan
    final businessDocId = userBusinessQuery.docs.first.id;

    if (_namaProgramController.text.isEmpty ||
        _deskripsiProgramController.text.isEmpty ||
        _kategoriUsahaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi semua bidang program.')),
      );
      return;
    }

    try {
      // --- Perubahan Penting di Sini: Menambahkan dokumen baru ke Koleksi Top-Level 'programBantuan' ---
      await _firestore.collection('programBantuan').add({
        'namaProgram': _namaProgramController.text.trim(),
        'deskripsiProgram': _deskripsiProgramController.text.trim(),
        'kategoriUsaha': _kategoriUsahaController.text.trim(),
        'status': 'Diajukan', // Status awal pengajuan
        'tanggalPengajuan': FieldValue.serverTimestamp(), // Timestamp pengajuan
        'userId': currentUser.uid, // Simpan UID pengguna
        'businessId': businessDocId, // Simpan ID usaha yang mengajukan
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengajuan program berhasil dikirim!')),
      );
      // Bersihkan form setelah pengajuan berhasil
      _namaProgramController.clear();
      _deskripsiProgramController.clear();
      _kategoriUsahaController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengajukan program: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _namaProgramController.dispose();
    _deskripsiProgramController.dispose();
    _kategoriUsahaController.dispose();
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
          'Ajukan Bantuan',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Menghilangkan tombol back default jika ada
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
                  _buildInputField(_namaProgramController),
                  const SizedBox(height: 25), // Spasi antar input
                  // Deskripsi Program
                  const Text(
                    'Deskripsi Program :',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  _buildMultiLineInputField(
                    _deskripsiProgramController,
                  ), // Input multi-baris
                  const SizedBox(height: 25),

                  // Kategori Usaha
                  const Text(
                    'Kategori Usaha :',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  _buildInputField(_kategoriUsahaController),
                  const SizedBox(height: 30), // Spasi sebelum tombol
                  // Tombol AJUKAN
                  SizedBox(
                    width: double.infinity, // Lebar tombol penuh
                    height: 50, // Tinggi tombol
                    child: ElevatedButton(
                      onPressed: _submitProgram, // Panggil fungsi pengajuan
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
                        child: TextField(
                          controller: _namaAkunHeaderController,
                          readOnly: true,
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
                          controller: _nikHeaderController,
                          readOnly: true,
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

  // Widget untuk input field standar (satu baris)
  Widget _buildInputField(TextEditingController controller) {
    return Container(
      height: 40, // Tinggi fixed untuk input field
      decoration: BoxDecoration(
        color: Colors.grey[300], // Background abu-abu terang
        borderRadius: BorderRadius.circular(8), // Sudut membulat
      ),
      child: TextField(
        controller: controller, // Menghubungkan controller
        decoration: const InputDecoration(
          border: InputBorder.none, // Tanpa border bawaan TextField
          contentPadding: EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 10,
          ), // Padding konten
        ),
        style: const TextStyle(color: Colors.black),
      ),
    );
  }

  // Widget untuk input field multi-baris (Deskripsi Program)
  Widget _buildMultiLineInputField(TextEditingController controller) {
    return Container(
      height: 120, // Tinggi fixed untuk multi-line input
      decoration: BoxDecoration(
        color: Colors.grey[300], // Background abu-abu terang
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller, // Menghubungkan controller
        maxLines: null, // Memungkinkan input multi-baris
        keyboardType:
            TextInputType.multiline, // Menggunakan keyboard multi-baris
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        ),
        style: const TextStyle(color: Colors.black),
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
              // Ikon Home (Beranda)
              icon: const Icon(
                Icons.grid_view,
                color: Color.fromARGB(255, 249, 249, 249),
                size: 30,
              ), // Warna putih
              onPressed: () {
                print('Home Grid pressed');
                Navigator.pushReplacementNamed(context, '/user_home');
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
              // Ikon Ajukan Bantuan (Aktif)
              icon: const Icon(Icons.send, color: Colors.green, size: 30),
              onPressed: () {
                print('Send pressed (Already on Ajukan Bantuan)');
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
                Navigator.pushReplacementNamed(context, '/aboutAplikasi');
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white, size: 30),
              onPressed: () {
                print('Help pressed');
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
    );
  }
}
