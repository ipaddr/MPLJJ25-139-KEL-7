// lib/Screen/ajukan_bantuan.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart';     // Import FirebaseAuth

class AjukanBantuanScreen extends StatefulWidget {
  const AjukanBantuanScreen({super.key});

  @override
  State<AjukanBantuanScreen> createState() => _AjukanBantuanScreenState();
}

class _AjukanBantuanScreenState extends State<AjukanBantuanScreen> {
  // Controllers untuk input form pengajuan
  final TextEditingController _namaProgramController = TextEditingController();
  final TextEditingController _deskripsiProgramController = TextEditingController();
  final TextEditingController _kategoriUsahaController = TextEditingController();

  // Instance Firebase Auth dan Firestore
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Variabel untuk data pengguna yang akan ditampilkan di header
  String _userName = 'Memuat...';
  String _userNIK = 'Memuat...';
  String _userLocation = 'Memuat...'; // Akan diambil dari Firestore
  String? _userUid; // UID pengguna yang sedang login

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Memanggil fungsi untuk mengambil data pengguna saat widget diinisialisasi
  }

  // Fungsi untuk mengambil data pengguna dari Firestore untuk header
  Future<void> _loadUserData() async {
    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      setState(() {
        _userUid = currentUser.uid; // Simpan UID pengguna
      });
      try {
        // Ambil dokumen pengguna dari koleksi 'users'
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser.uid).get();

        if (userDoc.exists && userDoc.data() != null) {
          final userData = userDoc.data()! as Map<String, dynamic>;
          setState(() {
            // Ambil data nama, NIK, dan lokasi dari Firestore
            _userName = userData['nama'] ?? 'Nama Tidak Tersedia'; // Menggunakan field 'nama'
            _userNIK = userData['nik'] ?? 'NIK Tidak Tersedia';    // Menggunakan field 'nik'
            _userLocation = userData['lokasi'] ?? 'Lokasi Tidak Tersedia'; // Menggunakan field 'lokasi'
          });
        } else {
          debugPrint('Dokumen user tidak ditemukan untuk UID: ${currentUser.uid}');
          setState(() {
            _userName = 'Data Tidak Ditemukan';
            _userNIK = 'Data Tidak Ditemukan';
            _userLocation = 'Data Tidak Ditemukan';
          });
        }
      } catch (e) {
        debugPrint('Error memuat data pengguna: $e');
        setState(() {
          _userName = 'Error Memuat Data';
          _userNIK = 'Error Memuat Data';
          _userLocation = 'Error Memuat Data';
        });
      }
    } else {
      // Jika pengguna belum login atau sesi telah berakhir
      setState(() {
        _userName = 'Silakan Login';
        _userNIK = 'Silakan Login';
        _userLocation = 'Silakan Login';
      });
      // Opsional: Arahkan kembali ke halaman login jika user tidak terautentikasi
      // Navigator.pushReplacementNamed(context, '/');
    }
  }

  // Fungsi untuk menyimpan pengajuan program ke Firestore
  Future<void> _submitPengajuan() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null || _userUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus login untuk mengajukan bantuan.')),
      );
      return;
    }

    // Validasi input form
    if (_namaProgramController.text.isEmpty ||
        _deskripsiProgramController.text.isEmpty ||
        _kategoriUsahaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field harus diisi!')),
      );
      return;
    }

    try {
      // PENTING: Menyimpan pengajuan di sub-koleksi 'pengajuan_bantuan' langsung di bawah dokumen user
      // Ini sesuai dengan skema Collection Group Query untuk admin.
      await _firestore
          .collection('users')
          .doc(_userUid) // UID user yang sedang login
          .collection('pengajuan_bantuan') // Nama sub-koleksi
          .add({
        'nama_program': _namaProgramController.text.trim(),
        'deskripsi_program': _deskripsiProgramController.text.trim(),
        'kategori_usaha': _kategoriUsahaController.text.trim(),
        'tanggal_pengajuan': FieldValue.serverTimestamp(), // Timestamp saat pengajuan dibuat
        'status_pengajuan': 'Menunggu', // Status awal pengajuan
        'user_uid': _userUid,          // Duplikasi UID user
        'user_nama': _userName,        // Duplikasi nama user
        'user_nik': _userNIK,          // Duplikasi NIK user
        'user_lokasi': _userLocation,  // Duplikasi lokasi user
        // Anda bisa menambahkan field lain yang relevan seperti URL gambar bukti, dll.
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Pengajuan bantuan berhasil dikirim!'),
            backgroundColor: Colors.green),
      );

      // Bersihkan form setelah pengajuan berhasil
      _namaProgramController.clear();
      _deskripsiProgramController.clear();
      _kategoriUsahaController.clear();
    } catch (e) {
      debugPrint('Error mengajukan bantuan: $e'); // Untuk debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Gagal mengajukan bantuan: ${e.toString()}'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    // Pastikan semua TextEditingController di-dispose untuk mencegah memory leaks
    _namaProgramController.dispose();
    _deskripsiProgramController.dispose();
    _kategoriUsahaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Ajukan Bantuan',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Menghilangkan tombol back default
      ),
      body: Column( // Menggunakan Column utama untuk struktur layout
        children: [
          // Bagian Header Kustom (GEMA, Nama Akun, NIK, Lokasi)
          _buildCustomHeader(),
          // Garis pembatas horizontal tipis di bawah header
          Container(
            height: 1,
            color: Colors.grey.shade300, // Warna garis pemisah lebih halus
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
          Expanded( // Memastikan SingleChildScrollView mengambil sisa ruang
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0), // Padding di sekeliling konten
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri untuk label input
                children: [
                  // Nama Program
                  Text('Nama Program :', style: _labelStyle()),
                  const SizedBox(height: 8),
                  _buildInputField(_namaProgramController, 'Contoh: Bantuan Modal Usaha untuk UMKM'),
                  const SizedBox(height: 25), // Spasi antar input

                  // Deskripsi Program
                  Text('Deskripsi Program :', style: _labelStyle()),
                  const SizedBox(height: 8),
                  _buildMultilineInputField(_deskripsiProgramController, 'Jelaskan detail program yang diajukan...', maxLines: 5),
                  const SizedBox(height: 25),

                  // Kategori Usaha
                  Text('Kategori Usaha :', style: _labelStyle()),
                  const SizedBox(height: 8),
                  _buildInputField(_kategoriUsahaController, 'Contoh: Pertanian, Perdagangan, Jasa, Manufaktur'),
                  const SizedBox(height: 40), // Spasi sebelum tombol

                  // Tombol AJUKAN
                  SizedBox(
                    width: double.infinity, // Lebar tombol penuh
                    height: 55, // Tinggi tombol sedikit lebih besar
                    child: ElevatedButton(
                      onPressed: _submitPengajuan, // Panggil fungsi pengajuan
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C4372), // Warna biru gelap sesuai gambar
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // Sudut membulat
                        ),
                        elevation: 5, // Sedikit bayangan
                        shadowColor: Colors.blue.shade300, // Warna bayangan
                      ),
                      child: const Text(
                        'AJUKAN BANTUAN', // Teks lebih spesifik
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.8, // Sedikit spasi huruf
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Garis pembatas horizontal tipis di atas bottom navigation
          // Container(height: 1, color: Colors.grey.shade300), // Jika menggunakan BottomNavigationBar terpisah
        ],
      ),
      // bottomNavigationBar: _buildBottomNavigationBar(context), // Hapus ini jika navbar di MainScreen
    );
  }

  // MARK: - Custom Widgets

  // Widget untuk header kustom yang menampilkan GEMA, Nama Akun, NIK, dan Lokasi
  Widget _buildCustomHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'GEMA',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900, // Lebih bold
              color: Colors.green, // Warna hijau agar menonjol
              letterSpacing: 2.5, // Spasi huruf lebih lebar
            ),
          ),
          Expanded( // Agar informasi user tidak meluber
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end, // Rata kanan
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min, // Agar Row sekecil mungkin
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.person, size: 28, color: Colors.black54), // Ukuran ikon lebih kecil
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nama Akun: $_userName', style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        Text('NIK: $_userNIK', style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 18, color: Colors.black54),
                    const SizedBox(width: 5),
                    Text(
                      _userLocation, // Menggunakan lokasi dari state
                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk label input (Nama Program, Deskripsi, Kategori)
  TextStyle _labelStyle() {
    return const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87);
  }

  // Widget untuk menampilkan info baris (Nama Akun, NIK, Lokasi)
  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ],
    );
  }

  // Widget untuk input field standar (satu baris)
  Widget _buildInputField(TextEditingController controller, String hintText) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400!, width: 1.0), // Border tipis
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade700!, width: 2.0), // Border tebal saat fokus
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15), // Padding vertikal lebih besar
      ),
      style: const TextStyle(color: Colors.black),
    );
  }

  // Widget untuk input field multi-baris (Deskripsi Program)
  Widget _buildMultilineInputField(TextEditingController controller, String hintText, {int maxLines = 5}) {
    return TextField(
      controller: controller,
      maxLines: maxLines, // Memungkinkan input multi-baris hingga maxLines
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400!, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade700!, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
      style: const TextStyle(color: Colors.black),
    );
  }

  // CATATAN: Widget _buildBottomNavigationBar telah dihapus dari sini.
  // bottomNavigationBar seharusnya diimplementasikan di AdminMainScreen atau UserMainScreen
  // sebagai navigasi utama aplikasi, bukan di setiap halaman individu.
}
