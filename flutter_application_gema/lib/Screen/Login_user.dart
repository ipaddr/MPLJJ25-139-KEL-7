import 'package:flutter/material.dart';

// Pastikan Anda telah mengimpor halaman Beranda (HomeScreen)
// Jika HomeScreen berada di file terpisah, misalnya:
// import 'package:flutter_application_gema/pages/home_screen.dart';
// Sesuaikan path import sesuai lokasi file Anda.
// Saya akan asumsikan Anda telah mengatur struktur folder seperti yang saya sarankan sebelumnya.
// Jika HomeScreen masih di file yang sama dengan main.dart (tidak disarankan untuk proyek besar),
// maka tidak perlu import.

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GEMA ID Login',
      debugShowCheckedModeBanner:
          false, // Menghilangkan debug banner di pojok kanan atas
      theme: ThemeData(
        primarySwatch: Colors.green, // Tema warna utama, bisa disesuaikan
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily:
            'Roboto', // Menggunakan font Roboto sebagai default, bisa diganti
      ),
      // Kita akan menggunakan named routes untuk navigasi
      routes: {
        '/':
            (context) =>
                const LoginPage(), // Halaman login sebagai halaman awal
        '/beranda':
            (context) => const Text(
              'Ini Halaman Beranda Dummy',
            ), // Placeholder untuk HomeScreen
        // Anda perlu mengganti ini dengan import 'package:flutter_application_gema/pages/home_screen.dart';
        // dan kemudian const HomeScreen()
        // Contoh: '/home': (context) => const HomeScreen(),
      },
      initialRoute: '/', // Set halaman awal ke Login
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil ukuran layar untuk penyesuaian responsif
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang putih sesuai gambar
      appBar: AppBar(
        title: const Text(
          'Login',
          style: TextStyle(
            color: Colors.black, // Warna teks AppBar
            fontWeight: FontWeight.normal, // Teks login tidak bold
          ),
        ),
        backgroundColor: Colors.transparent, // AppBar transparan
        elevation: 0, // Tidak ada bayangan di bawah AppBar
        automaticallyImplyLeading:
            false, // Menghilangkan tombol back default jika ada
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

                      _buildInputField(
                        'Masukkan ID Anda',
                        Icons.person_outline,
                      ), // Input ID
                      const SizedBox(height: 18), // Spasi antar input field
                      _buildInputField(
                        'Masukkan Password Anda',
                        Icons.lock_outline,
                        isPassword: true,
                      ), // Input Password

                      const SizedBox(height: 35), // Spasi sebelum tombol login

                      SizedBox(
                        width: double.infinity, // Lebar tombol full
                        child: ElevatedButton(
                          onPressed: () {
                            // Aksi ketika tombol login ditekan
                            print('Login button pressed');
                            // Navigasi ke halaman Beranda setelah login
                            // Menggunakan pushReplacementNamed agar halaman login tidak bisa kembali
                            Navigator.pushReplacementNamed(context, '/beranda');
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
                            'Login',
                            style: TextStyle(
                              fontSize:
                                  19, // Ukuran font tombol yang lebih besar
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25), // Spasi setelah tombol login

                      TextButton(
                        onPressed: () {
                          // Aksi ketika teks "Daftar GEMA ID?" ditekan
                          print('Daftar GEMA ID? atau lupa password?');
                          // Arahkan ke halaman pendaftaran atau lupa password
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
                          'Daftar GEMA ID ? atau lupa password?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:
                                Colors.black54, // Warna teks yang sedikit buram
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
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
    IconData icon, {
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green[800], // Warna background input field
        borderRadius: BorderRadius.circular(
          12,
        ), // Sudut membulat untuk input field
      ),
      child: TextField(
        obscureText:
            isPassword, // Sembunyikan teks jika ini adalah password field
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
