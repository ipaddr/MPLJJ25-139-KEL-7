import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

// Mengubah BantuanSayaScreen menjadi StatefulWidget
class BantuanSayaScreen extends StatefulWidget {
  const BantuanSayaScreen({super.key});

  @override
  State<BantuanSayaScreen> createState() => _BantuanSayaScreenState();
}

class _BantuanSayaScreenState extends State<BantuanSayaScreen> {
  final String _location = 'Indonesia, Sumatera Barat, Padang'; // Lokasi statis

  // Controllers untuk input dan tampilan data usaha
  final TextEditingController _namaUsahaController = TextEditingController();
  final TextEditingController _jenisUsahaController = TextEditingController();
  final TextEditingController _deskripsiUsahaController =
      TextEditingController();

  // Controllers untuk menampilkan Nama Akun dan NIK di header
  final TextEditingController _namaAkunHeaderController =
      TextEditingController();
  final TextEditingController _nikHeaderController = TextEditingController();

  // Instance Firebase Auth dan Firestore
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Variabel untuk menyimpan data usaha yang sudah ada
  Map<String, dynamic>? _businessData;
  bool _isLoadingUserData = true; // State untuk loading data pengguna dan usaha

  @override
  void initState() {
    super.initState();
    _fetchUserDataAndBusiness(); // Memanggil fungsi untuk mengambil data pengguna dan usaha
  }

  // Fungsi untuk mengambil data pengguna dan usaha dari Firestore
  void _fetchUserDataAndBusiness() {
    User? currentUser =
        _auth.currentUser; // Mendapatkan pengguna yang sedang login

    if (currentUser != null) {
      // Mendengarkan perubahan data pengguna untuk header
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

      // Mendengarkan perubahan data usaha pengguna
      _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('usaha')
          .doc('myBusiness')
          .snapshots()
          .listen((businessSnapshot) {
            if (businessSnapshot.exists && businessSnapshot.data() != null) {
              setState(() {
                _businessData = businessSnapshot.data();
                _isLoadingUserData = false;
              });
            } else {
              setState(() {
                _businessData = null; // Tidak ada data usaha
                _isLoadingUserData = false;
              });
            }
          });
    } else {
      // Jika tidak ada pengguna yang login
      setState(() {
        _namaAkunHeaderController.text = 'Tidak Login';
        _nikHeaderController.text = 'Tidak Login';
        _businessData = null;
        _isLoadingUserData = false;
      });
    }
  }

  // Fungsi untuk menyimpan data usaha ke Firestore
  Future<void> _saveBusinessData() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus login untuk menyimpan data usaha.'),
        ),
      );
      return;
    }

    if (_namaUsahaController.text.isEmpty ||
        _jenisUsahaController.text.isEmpty ||
        _deskripsiUsahaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi semua bidang usaha.')),
      );
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('usaha')
          .doc('myBusiness')
          .set(
            {
              'namaUsaha': _namaUsahaController.text.trim(),
              'jenisUsaha': _jenisUsahaController.text.trim(),
              'deskripsiUsaha': _deskripsiUsahaController.text.trim(),
              'lastUpdated':
                  FieldValue.serverTimestamp(), // Tambahkan timestamp update
            },
            SetOptions(merge: true),
          ); // Gunakan merge agar tidak menimpa field lain jika ada

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data usaha berhasil disimpan!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan data usaha: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _namaUsahaController.dispose();
    _jenisUsahaController.dispose();
    _deskripsiUsahaController.dispose();
    _namaAkunHeaderController.dispose();
    _nikHeaderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser =
        _auth
            .currentUser; // Dapatkan user saat ini untuk dilewatkan ke widget lain

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
            child:
                _isLoadingUserData
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
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
                          // Kondisional: tampilkan form input atau hasil inputan
                          _businessData == null
                              ? _buildProgramSayaInputForm() // Tampilkan form jika belum ada data
                              : _buildProgramSayaDisplay(
                                _businessData!,
                              ), // Tampilkan data jika sudah ada
                          const SizedBox(
                            height: 25,
                          ), // Spasi antara dua bagian utama

                          const Text(
                            'PROGRAM YANG DISETUJUI :',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 15),
                          // Kotak untuk "PROGRAM YANG DISETUJUI" - Sekarang akan menampilkan data dari Firestore
                          _buildProgramDisetujuiBox(
                            currentUser,
                          ), // Melewatkan currentUser
                          const SizedBox(
                            height: 25,
                          ), // Spasi antara dua bagian utama

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

  // MARK: - Custom Widgets

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

  // Widget untuk form input usaha
  Widget _buildProgramSayaInputForm() {
    return Container(
      width: double.infinity, // Lebar penuh
      padding: const EdgeInsets.all(20.0), // Padding di dalam kotak
      decoration: BoxDecoration(
        color: Colors.grey[300], // Warna abu-abu yang lebih terang
        borderRadius: BorderRadius.circular(10), // Sudut membulat
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri
        children: [
          const Text(
            'Nama Usaha :',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          const SizedBox(height: 10),
          _buildTextField(_namaUsahaController),
          const SizedBox(height: 10),
          const Text(
            'Jenis Usaha :',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          const SizedBox(height: 10),
          _buildTextField(_jenisUsahaController),
          const SizedBox(height: 10),
          const Text(
            'Deskripsi Usaha:',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          const SizedBox(height: 10),
          _buildTextField(_deskripsiUsahaController, maxLines: 3),
          const SizedBox(height: 20), // Spasi sebelum tombol
          // Tombol SIMPAN
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: _saveBusinessData, // Panggil fungsi simpan
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800], // Warna biru gelap
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 3, // Efek bayangan
              ),
              child: const Text(
                'SIMPAN',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan hasil inputan usaha (read-only)
  Widget _buildProgramSayaDisplay(Map<String, dynamic> businessData) {
    return Container(
      width: double.infinity, // Lebar penuh
      padding: const EdgeInsets.all(20.0), // Padding di dalam kotak
      decoration: BoxDecoration(
        color: Colors.grey[300], // Warna abu-abu yang lebih terang
        borderRadius: BorderRadius.circular(10), // Sudut membulat
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri
        children: [
          const Text(
            'Nama Usaha :',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          const SizedBox(height: 10),
          _buildDisplayField(businessData['namaUsaha'] ?? 'Tidak ada data'),
          const SizedBox(height: 10),
          const Text(
            'Jenis Usaha :',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          const SizedBox(height: 10),
          _buildDisplayField(businessData['jenisUsaha'] ?? 'Tidak ada data'),
          const SizedBox(height: 10),
          const Text(
            'Deskripsi Usaha:',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          const SizedBox(height: 10),
          _buildDisplayField(
            businessData['deskripsiUsaha'] ?? 'Tidak ada data',
            maxLines: null,
          ), // maxLines null untuk teks panjang
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                // Memberi kesempatan user untuk mengedit kembali jika ingin
                setState(() {
                  // Mengisi controller dengan data yang ada agar bisa diedit
                  _namaUsahaController.text = businessData['namaUsaha'] ?? '';
                  _jenisUsahaController.text = businessData['jenisUsaha'] ?? '';
                  _deskripsiUsahaController.text =
                      businessData['deskripsiUsaha'] ?? '';
                  _businessData =
                      null; // Set null agar form input muncul kembali
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600], // Warna biru
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 3,
              ),
              child: const Text(
                'EDIT USAHA',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget pembantu untuk TextField yang bisa diedit
  Widget _buildTextField(TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        isDense: true,
      ),
      style: const TextStyle(fontSize: 14, color: Colors.black),
    );
  }

  // Widget pembantu untuk menampilkan teks sebagai hasil inputan (read-only style)
  Widget _buildDisplayField(String text, {int? maxLines}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: Colors.black),
        maxLines: maxLines,
        overflow: maxLines == null ? TextOverflow.clip : TextOverflow.ellipsis,
      ),
    );
  }

  // Widget untuk "PROGRAM YANG DISETUJUI" dengan StreamBuilder
  Widget _buildProgramDisetujuiBox(User? currentUser) {
    if (currentUser == null) {
      return Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 150, maxHeight: 300),
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text(
            'Silakan login untuk melihat program yang diajukan.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 150,
        maxHeight: 300,
      ), // Tinggi maksimal untuk memungkinkan scrolling
      padding: const EdgeInsets.all(10.0), // Padding di dalam kotak
      decoration: BoxDecoration(
        color: Colors.grey[300], // Warna abu-abu yang lebih terang
        borderRadius: BorderRadius.circular(10), // Sudut membulat
      ),
      child: StreamBuilder<QuerySnapshot>(
        // Mendengarkan data dari sub-koleksi 'programAjuan'
        stream:
            _firestore
                .collection('users')
                .doc(currentUser.uid)
                .collection('usaha')
                .doc(
                  'myBusiness',
                ) // Asumsikan 'myBusiness' adalah ID dokumen data usaha
                .collection('programAjuan')
                .orderBy(
                  'tanggalPengajuan',
                  descending: true,
                ) // Urutkan berdasarkan tanggal terbaru
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error memuat program: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Anda belum mengajukan program apa pun.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            );
          } else {
            // Tampilkan daftar program
            final programDocs = snapshot.data!.docs;
            return ListView.builder(
              shrinkWrap:
                  true, // Agar ListView hanya mengambil ruang yang dibutuhkan
              physics:
                  const ClampingScrollPhysics(), // Memungkinkan scrolling di dalam kotak, tetapi terbatas
              itemCount: programDocs.length,
              itemBuilder: (context, index) {
                var programData =
                    programDocs[index].data() as Map<String, dynamic>;
                String namaProgram =
                    programData['namaProgram'] ?? 'Nama Program Tidak Tersedia';
                String status = programData['status'] ?? 'N/A';
                Timestamp? tanggalPengajuan = programData['tanggalPengajuan'];
                String tanggal =
                    tanggalPengajuan != null
                        ? tanggalPengajuan.toDate().toLocal().toString().split(
                          ' ',
                        )[0]
                        : 'Tanggal Tidak Tersedia';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          namaProgram,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('Status: $status'),
                        Text('Diajukan pada: $tanggal'),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildProgramTersediaBox() {
    return Container(
      width: double.infinity, // Lebar penuh
      height:
          150, // Tinggi fixed untuk kotak ini (disesuaikan agar mirip dengan 'Disetujui')
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.grey[300], // Warna abu-abu yang lebih terang
        borderRadius: BorderRadius.circular(10),
      ),
      // Konten di sini bisa berupa ListView.builder jika ada banyak program
      // Untuk saat ini, biarkan kosong sebagai placeholder
      child: const Center(
        child: Text(
          'Daftar program yang tersedia akan tampil di sini', // Placeholder
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.black54),
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
                color: Color.fromARGB(255, 252, 252, 252),
                size: 30,
              ), // Warna putih
              onPressed: () {
                print('Home Grid pressed');
                Navigator.pushReplacementNamed(context, '/beranda');
              },
            ),
            IconButton(
              icon: const Icon(Icons.map, color: Colors.green, size: 30),
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
