import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:flutter_application_gema/Screen/admin_main_screen.dart';

// <<< PASTIKAN IMPORT FILE-FILE INI SUDAH BENAR DAN ADA
// Jika AdminMainScreen berada di pages/, ubah pathnya
import 'package:flutter_application_gema/Screen/login_user.dart';      // Halaman Login Anda
import 'package:flutter_application_gema/Screen/beranda.dart';          // Halaman Beranda/User Home
import 'package:flutter_application_gema/Screen/program_saya.dart';
import 'package:flutter_application_gema/Screen/ajukan_bantuan.dart';
import 'package:flutter_application_gema/Screen/about_aplikasi.dart';
import 'package:flutter_application_gema/Screen/register_user.dart';
import 'package:flutter_application_gema/Screen/berita_screen.dart';
// import 'package:flutter_application_gema/Screen/dashboard_admin.dart'; // Tidak perlu diimpor langsung di sini jika dipakai di AdminMainScreen
// >>>

// Import file firebase_options.dart jika sudah dijalankan 'flutterfire configure'
// import 'firebase_options.dart'; // <<< PENTING: UNCOMMENT JIKA ADA

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // <<< PENTING: UNCOMMENT DAN PASTIKAN OPSI INI DIGUNAKAN JIKA ANDA TELAH MENYIAPKAN FIREBASE
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
        primarySwatch: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      routes: {
        '/': (context) => const LoginPage(),
        // Rute untuk halaman admin_main_screen yang sudah ada navbar
        '/admin_home': (context) => const AdminMainScreen(), // <<< UBAH KE ADMINMAINSCREEN
        // Rute untuk halaman user biasa
        '/user_home': (context) => const Beranda(), // Ini sudah benar mengarah ke Beranda
        '/programSaya': (context) => const BantuanSayaScreen(),
        '/ajukanBantuan': (context) => const AjukanBantuanScreen(),
        '/aboutAplikasi': (context) => const AboutAplikasiScreen(),
        '/register': (context) => const RegisterScreen(),
        // '/beranda' jika Anda ingin memiliki rute terpisah untuk beranda tanpa navbar utama (tapi /user_home sudah ada)
        // '/beranda': (context) => const Beranda(), // Ini mungkin duplikat jika /user_home juga Beranda
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
          builder: (context) => const Text('Error: Halaman tidak ditemukan'),
        );
      },
      initialRoute: '/',
    );
  }
}