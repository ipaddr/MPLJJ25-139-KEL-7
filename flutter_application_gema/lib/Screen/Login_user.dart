import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// Import AuthService
import 'package:flutter_application_gema/service/auth_service.dart';
// Sesuaikan path jika berbeda
// >>>

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Login',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                screenHeight -
                AppBar().preferredSize.height -
                MediaQuery.of(context).padding.top,
          ),
          child: IntrinsicHeight(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Center(
                child: Container(
                  width: screenWidth * 0.85,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25.0,
                    vertical: 35.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[350],
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text(
                        'GEMA ID',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Teknologi untuk Kesejahteraan yang Merata',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 35),
                      _buildInputField(
                        'Masukkan ID Anda',
                        Icons.person_outline,
                        _emailController,
                      ),
                      const SizedBox(height: 18),
                      _buildInputField(
                        'Masukkan Password Anda',
                        Icons.lock_outline,
                        _passwordController,
                        isPassword: true,
                      ),
                      const SizedBox(height: 35),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            print('Login button pressed');
                            try {
                              // Memanggil metode login dari AuthService
                              User? user = await _authService
                                  .signInWithEmailAndPassword(
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                  );

                              if (user != null) {
                                // <<< LOGIKA NAVIGASI BERDASARKAN ROLE DIMULAI DI SINI
                                String? userRole = await _authService
                                    .getUserRole(user.uid);

                                if (userRole == 'admin') {
                                  // Jika peran adalah 'admin', navigasi ke halaman admin
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Login berhasil sebagai Admin: ${user.email}',
                                      ),
                                    ),
                                  );
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/admin_home',
                                  );
                                } else if (userRole == 'user') {
                                  // Jika peran adalah 'user', navigasi ke halaman user
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Login berhasil: ${user.email}',
                                      ),
                                    ),
                                  );
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/user_home',
                                  );
                                } else {
                                  // Jika role tidak ditemukan atau tidak valid di Firestore
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Peran pengguna tidak dikenal atau tidak diatur.',
                                      ),
                                    ),
                                  );
                                  // Opsional: Logout pengguna jika role tidak valid
                                  await _authService.signOut();
                                }
                                // >>> LOGIKA NAVIGASI BERAKHIR DI SINI
                              }
                            } on FirebaseAuthException catch (e) {
                              // Menampilkan pesan error dari Firebase Auth
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.message ?? 'Terjadi kesalahan login',
                                  ),
                                ),
                              );
                            } catch (e) {
                              // Menampilkan pesan error umum
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      TextButton(
                        onPressed: () {
                          print('Navigating to Register Screen');
                          Navigator.pushNamed(context, '/register');
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Daftar GEMA ID ? atau lupa password?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
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

  Widget _buildInputField(
    String hintText,
    IconData icon,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white70),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white70, fontSize: 16),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 10,
          ),
        ),
      ),
    );
  }
}
