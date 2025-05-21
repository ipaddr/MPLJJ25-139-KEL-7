import 'package:flutter/material.dart';

// Import halaman-halaman Anda dari folder 'pages'
import 'package:flutter_application_gema/Screen/login_user.dart';
import 'package:flutter_application_gema/Screen/beranda.dart';
import 'package:flutter_application_gema/Screen/program_saya.dart';
import 'package:flutter_application_gema/Screen/ajukan_bantuan.dart';
import 'package:flutter_application_gema/Screen/about_aplikasi.dart';

// Jika Anda berencana memiliki satu BottomNavigationBar sentral,
// Anda akan membuat file navigation_bar.dart dengan widget MainNavigationPage di dalamnya.
// Untuk saat ini, kita asumsikan setiap halaman memiliki BottomNavigationBar sendiri
// seperti yang sudah kita buat di setiap kode halaman.
// import 'package:flutter_application_gema/navigation_bar.dart'; // Akan digunakan jika ada MainNavigationPage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GEMA App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Set tema global di sini agar konsisten di seluruh aplikasi
        primarySwatch: Colors.grey, // Warna utama
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto', // Contoh font
      ),
      // Definisikan rute aplikasi Anda
      routes: {
        '/': (context) => const LoginPage(),
        '/beranda': (context) => const Beranda(),
        '/programSaya': (context) => const BantuanSayaScreen(),
        '/ajukanBantuan': (context) => const AjukanBantuanScreen(),
        '/aboutAplikasi': (context) => const AboutAplikasiScreen(),
      },
      // Anda bisa menggunakan initialRoute jika Anda lebih suka menentukannya di sini
      initialRoute: '/',
    );
  }
}
