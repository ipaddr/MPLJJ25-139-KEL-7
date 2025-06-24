import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:flutter_application_gema/Screen/beranda_admin.dart';

// <<< PASTIKAN IMPORT FILE-FILE INI SUDAH BENAR DAN ADA
// Mengimpor semua halaman yang digunakan dalam rute aplikasi
import 'package:flutter_application_gema/Screen/login_user.dart';
import 'package:flutter_application_gema/Screen/beranda.dart'; // Halaman Beranda/User Home
import 'package:flutter_application_gema/Screen/program_saya.dart';
import 'package:flutter_application_gema/Screen/ajukan_bantuan.dart';
import 'package:flutter_application_gema/Screen/about_aplikasi.dart';
import 'package:flutter_application_gema/Screen/register_user.dart';
import 'package:flutter_application_gema/Screen/berita_screen.dart';
// >>>

// Import file firebase_options.dart Anda. Ini dihasilkan oleh Firebase CLI.
// Pastikan Anda telah menjalankan `flutterfire configure` sebelumnya.
// Jika file ini tidak ada, Anda perlu menyiapkan Firebase di proyek Flutter Anda.
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Pastikan binding Flutter sudah diinisialisasi
  await Firebase.initializeApp(
    // <<< PENTING: UNCOMMENT DAN PASTIKAN OPSI INI DIGUNAKAN JIKA ANDA TELAH MENYIAPKAN FIREBASE
    // Jika Anda belum menyiapkan Firebase, Anda akan mendapatkan error di sini.
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
      debugShowCheckedModeBanner: false, // Menghilangkan banner debug
      theme: ThemeData(
        primarySwatch: Colors.grey, // Warna dasar aplikasi
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto', // Font default
      ),
      routes: {
        '/': (context) => const LoginPage(), // Halaman awal aplikasi adalah Login
        
        // Rute untuk halaman admin utama (dengan navbar)
        '/admin_home': (context) => const BerandaAdminScreen(), // Kini BerandaAdminScreen sudah terimpor
        
        // Rute untuk halaman user biasa
        '/user_home': (context) => const Beranda(), // Ini sudah benar mengarah ke Beranda
        '/programSaya': (context) => const BantuanSayaScreen(),
        '/ajukanBantuan': (context) => const AjukanBantuanScreen(),
        '/aboutAplikasi': (context) => const AboutAplikasiScreen(),
        '/register': (context) => const RegisterScreen(),
        
        // Catatan: '/beranda' tidak perlu lagi sebagai rute terpisah jika '/user_home' sudah mengarah ke Beranda
        // dan ini adalah titik masuk utama untuk user biasa setelah login.
      },
      
      // onGenerateRoute digunakan untuk rute dengan argumen, seperti detail berita
      onGenerateRoute: (settings) {
        if (settings.name == '/beritaDetail') {
          // Memastikan argumen adalah String (ID berita)
          final args = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) {
              return BeritaScreen(beritaId: args); // Meneruskan ID berita ke BeritaScreen
            },
          );
        }
        // Jika rute tidak ditemukan di daftar 'routes' atau 'onGenerateRoute',
        // tampilkan halaman error.
        return MaterialPageRoute(
          builder: (context) => const Center(child: Text('Error: Halaman tidak ditemukan')),
        );
      },
      initialRoute: '/', // Menetapkan rute awal aplikasi
    );
  }
}
