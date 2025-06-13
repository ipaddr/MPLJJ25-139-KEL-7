import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
// Anda perlu mengimpor firebase_options.dart jika Anda menggunakan FlutterFire CLI
// import 'package:flutter_application_gema/firebase_options.dart';

// Import halaman-halaman Anda dari folder 'Screen'
import 'package:flutter_application_gema/Screen/login_user.dart';
import 'package:flutter_application_gema/Screen/beranda.dart';
import 'package:flutter_application_gema/Screen/program_saya.dart';
import 'package:flutter_application_gema/Screen/ajukan_bantuan.dart';
import 'package:flutter_application_gema/Screen/about_aplikasi.dart';
import 'package:flutter_application_gema/Screen/register_user.dart';
import 'package:flutter_application_gema/Screen/berita_screen.dart'; // Pastikan ini diimpor

// Jika Anda berencana memiliki satu BottomNavigationBar sentral,
// Anda akan membuat file navigation_bar.dart dengan widget MainNavigationPage di dalamnya.
// Untuk saat ini, kita asumsikan setiap halaman memiliki BottomNavigationBar sendiri
// seperti yang sudah kita buat di setiap kode halaman.
// import 'package:flutter_application_gema/navigation_bar.dart'; // Akan digunakan jika ada MainNavigationPage

void main() async {
  // Tambahkan 'async' di sini karena ada operasi asynchronous
  WidgetsFlutterBinding.ensureInitialized(); // Pastikan binding Flutter sudah diinisialisasi
  await Firebase.initializeApp(
    // Inisialisasi Firebase
    // Uncomment baris di bawah ini jika Anda telah menjalankan 'flutterfire configure'
    // dan memiliki file firebase_options.dart
    // options: DefaultFirebaseOptions.currentPlatform,
  );
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
      // Definisikan rute aplikasi Anda yang tidak memerlukan argumen
      routes: {
        '/': (context) => const LoginPage(),
        '/beranda': (context) => const Beranda(),
        '/programSaya': (context) => const BantuanSayaScreen(),
        '/ajukanBantuan': (context) => const AjukanBantuanScreen(),
        '/aboutAplikasi': (context) => const AboutAplikasiScreen(),
        '/register': (context) => const RegisterScreen(),
        // Rute '/beritaDetail' akan ditangani oleh onGenerateRoute
        // Karena membutuhkan argumen (beritaId)
      },
      // Gunakan onGenerateRoute untuk menangani rute dengan argumen
      onGenerateRoute: (settings) {
        if (settings.name == '/beritaDetail') {
          // Asumsikan argumen adalah ID berita (String)
          final args = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) {
              return BeritaScreen(beritaId: args);
            },
          );
        }
        // Jika rute tidak ditemukan di 'routes' map dan bukan '/beritaDetail',
        // kembalikan rute yang tidak dikenal atau halaman error.
        return MaterialPageRoute(
          builder: (context) => const Text('Error: Halaman tidak ditemukan'),
        );
      },
      // Anda bisa menggunakan initialRoute jika Anda lebih suka menentukannya di sini
      initialRoute: '/',
    );
  }
}
