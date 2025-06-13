import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_gema/service/auth_service.dart'; // Import AuthService
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

// Kelas RegisterScreen
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controller untuk input
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _nikController =
      TextEditingController(); // Controller baru untuk NIK
  final TextEditingController _emailController =
      TextEditingController(); // Menggunakan ini untuk ID/Email
  final TextEditingController _passwordController = TextEditingController();

  // Instance dari AuthService dan Firestore
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _fullNameController.dispose();
    _nikController.dispose(); // Dispose the new NIK controller
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil ukuran layar untuk penyesuaian responsif
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang putih sesuai login.screen
      appBar: AppBar(
        title: const Text(
          'Register',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ), // Warna teks hitam
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Tombol kembali otomatis jika ada route yang bisa kembali
        // Ini akan menampilkan tombol back untuk kembali ke LoginScreen
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        // Menggunakan SingleChildScrollView agar konten bisa discroll jika keyboard muncul
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                screenHeight -
                AppBar().preferredSize.height -
                MediaQuery.of(context).padding.top,
          ),
          child: IntrinsicHeight(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
              ), // Padding horizontal di sekeliling card
              child: Center(
                child: Container(
                  width:
                      screenWidth *
                      0.85, // Lebar card sekitar 85% dari lebar layar
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25.0,
                    vertical: 35.0,
                  ), // Padding di dalam card
                  decoration: BoxDecoration(
                    color:
                        Colors
                            .grey[350], // Warna abu-abu yang lebih terang untuk background card
                    borderRadius: BorderRadius.circular(
                      25.0,
                    ), // Sudut membulat yang lebih besar
                  ),
                  child: Column(
                    mainAxisSize:
                        MainAxisSize
                            .min, // Agar column mengambil ukuran minimum yang dibutuhkan
                    children: <Widget>[
                      const Text(
                        'GEMA ID',
                        style: TextStyle(
                          fontSize:
                              32, // Ukuran font yang lebih besar untuk GEMA ID
                          fontWeight: FontWeight.w900, // Sangat bold
                          color: Colors.black,
                          letterSpacing: 1.5, // Sedikit spasi antar huruf
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ), // Spasi kecil antara judul dan deskripsi
                      const Text(
                        'Teknologi untuk Kesejahteraan yang Merata',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500, // Sedikit lebih tebal
                        ),
                      ),
                      const SizedBox(height: 35), // Spasi setelah deskripsi
                      // Input Nama Lengkap
                      _buildInputField(
                        'Masukan Nama Lengkap Anda',
                        Icons.person_outline, // Contoh ikon
                        _fullNameController,
                      ),
                      const SizedBox(height: 18), // Spasi antar input field
                      // Input NIK (Nomor Induk Kependudukan)
                      _buildInputField(
                        'Masukan NIK Anda',
                        Icons.badge_outlined, // Ikon baru untuk NIK
                        _nikController,
                        keyboardType:
                            TextInputType.number, // Hanya menerima angka
                      ),
                      const SizedBox(height: 18), // Spasi antar input field
                      // Input ID (digunakan sebagai email untuk Firebase Auth)
                      _buildInputField(
                        'Masukan ID Anda (Email)',
                        Icons.email_outlined, // Contoh ikon
                        _emailController,
                      ),
                      const SizedBox(height: 18), // Spasi antar input field
                      // Input Password
                      _buildInputField(
                        'Masukan Password Anda',
                        Icons.lock_outline,
                        _passwordController,
                        isPassword: true,
                      ),

                      const SizedBox(height: 35), // Spasi sebelum tombol Daftar

                      SizedBox(
                        width: double.infinity, // Lebar tombol full
                        child: ElevatedButton(
                          onPressed: () async {
                            // Aksi ketika tombol Daftar ditekan
                            print('Tombol Daftar ditekan');
                            try {
                              // Memanggil metode signUp dari AuthService
                              final user = await _authService
                                  .signUpWithEmailAndPassword(
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                  );

                              if (user != null) {
                                // Pendaftaran autentikasi berhasil, sekarang simpan data tambahan ke Firestore
                                await _firestore
                                    .collection('users')
                                    .doc(user.uid)
                                    .set({
                                      'fullName':
                                          _fullNameController.text.trim(),
                                      'nik': _nikController.text.trim(),
                                      'email': _emailController.text.trim(),
                                      'createdAt':
                                          FieldValue.serverTimestamp(), // Tambahkan timestamp pembuatan
                                    });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Pendaftaran berhasil untuk ${user.email} dan data disimpan!',
                                    ),
                                  ),
                                );
                                // Kembali ke halaman login setelah pendaftaran berhasil
                                Navigator.pop(context);
                              }
                            } on FirebaseAuthException catch (e) {
                              // Menampilkan pesan error dari Firebase Auth
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.message ??
                                        'Terjadi kesalahan pendaftaran',
                                  ),
                                ),
                              );
                            } catch (e) {
                              // Menampilkan pesan error umum (termasuk error Firestore)
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors
                                    .green[700], // Warna hijau yang gelap untuk tombol
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ), // Padding vertikal tombol
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ), // Sudut tombol yang membulat
                            ),
                            elevation: 5, // Sedikit bayangan pada tombol
                          ),
                          child: const Text(
                            'Daftar',
                            style: TextStyle(
                              fontSize:
                                  19, // Ukuran font tombol yang lebih besar
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25), // Spasi setelah tombol Daftar

                      TextButton(
                        onPressed: () {
                          // Aksi ketika teks "Sudah Punya Akun GEMA ID ? Masuk" ditekan
                          print('Navigating back to Login Screen');
                          // Navigasi kembali ke halaman login
                          Navigator.pop(
                            context,
                          ); // Menggunakan pop untuk kembali ke halaman sebelumnya
                        },
                        style: TextButton.styleFrom(
                          padding:
                              EdgeInsets
                                  .zero, // Hapus padding default TextButton
                          minimumSize:
                              Size.zero, // Hapus min size default TextButton
                          tapTargetSize:
                              MaterialTapTargetSize
                                  .shrinkWrap, // Shrink tap target
                        ),
                        child: const Text(
                          'Sudah Punya Akun GEMA ID ? Masuk',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:
                                Colors.black54, // Warna teks yang sedikit buram
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            decoration:
                                TextDecoration.underline, // Tambah underline
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget pembantu untuk membuat TextField (input field)
  Widget _buildInputField(
    String hintText,
    IconData icon,
    TextEditingController controller, { // Menambahkan parameter controller
    bool isPassword = false,
    TextInputType keyboardType =
        TextInputType.text, // Parameter baru untuk tipe keyboard
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green[800], // Warna background input field
        borderRadius: BorderRadius.circular(
          12,
        ), // Sudut membulat untuk input field
      ),
      child: TextField(
        controller: controller, // Menghubungkan controller ke TextField
        obscureText:
            isPassword, // Sembunyikan teks jika ini adalah password field
        keyboardType: keyboardType, // Menentukan tipe keyboard
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ), // Warna teks input dan ukuran
        cursorColor: Colors.white, // Warna kursor
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: Colors.white70,
          ), // Ikon di awal input field
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ), // Warna dan ukuran hint
          border: InputBorder.none, // Hapus border default TextField
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 10,
          ), // Padding konten input
        ),
      ),
    );
  }
}
