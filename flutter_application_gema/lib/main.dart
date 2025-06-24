import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core

// Mengimpor semua halaman yang digunakan dalam rute aplikasi
import 'package:flutter_application_gema/Screen/login_user.dart';
import 'package:flutter_application_gema/Screen/beranda.dart'; // Halaman Beranda/User Home
import 'package:flutter_application_gema/Screen/program_saya.dart';
import 'package:flutter_application_gema/Screen/ajukan_bantuan.dart';
import 'package:flutter_application_gema/Screen/about_aplikasi.dart';
import 'package:flutter_application_gema/Screen/register_user.dart';
import 'package:flutter_application_gema/Screen/berita_screen.dart';
import 'package:flutter_application_gema/Screen/beranda_admin.dart'; // <<< PENTING: Ini adalah BerandaAdminScreen
import 'package:flutter_application_gema/Screen/verifikasi_pengguna.dart'; // Untuk AdminUserVerificationScreen
import 'package:flutter_application_gema/Screen/verifikasi_monitoring_laporan_admin.dart'; // Untuk VerifikasiMonitoringLaporanAdminScreen
import 'package:flutter_application_gema/Screen/tambah_berita.dart'; // Untuk AddNewsScreen (pastikan ini nama filenya)


// Import file firebase_options.dart Anda. Ini dihasilkan oleh Firebase CLI.
// Pastikan Anda telah menjalankan `flutterfire configure` sebelumnya.
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
        primarySwatch: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      routes: {
        '/': (context) => const LoginPage(), // Halaman awal aplikasi adalah Login
        
        // --- PERBAIKAN DI SINI ---
        // Rute untuk halaman admin utama (dengan bottom nav)
        // Sekarang langsung mengarah ke BerandaAdminScreen
        '/admin_home': (context) => const BerandaAdminScreen(), 
        
        // Rute untuk halaman user biasa
        '/user_home': (context) => const Beranda(),
        '/programSaya': (context) => const BantuanSayaScreen(),
        '/ajukanBantuan': (context) => const AjukanBantuanScreen(),
        '/aboutAplikasi': (context) => const AboutAplikasiScreen(),
        '/register': (context) => const RegisterScreen(),
        
        // Rute untuk halaman admin spesifik yang diakses dari tombol di dashboard atau tempat lain
        // Pastikan Anda memiliki AdminUserVerificationScreen di file verifikasi_pengguna.dart
        '/admin_user_verification': (context) => const AdminUserVerificationScreen(),
        '/verifikasi_monitoring_laporan_admin': (context) => const VerifikasiMonitoringLaporanAdminScreen(),
        '/add_news_screen': (context) => const AddNewsScreen(), 
      },
      
      onGenerateRoute: (settings) {
        if (settings.name == '/beritaDetail') {
          final args = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) {
              return BeritaScreen(beritaId: args);
            },
          );
        }
        return MaterialPageRoute(
          builder: (context) => const Center(child: Text('Error: Halaman tidak ditemukan')),
        );
      },
      initialRoute: '/',
    );
  }
}
