import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_gema/service/auth_service.dart'; // Sesuaikan path

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  String? _selectedRole; // Variabel untuk menyimpan pilihan role
  final List<String> _roles = ['user', 'admin']; // Pilihan role yang tersedia

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _registerUser() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password dan Konfirmasi Password tidak cocok!')),
      );
      return;
    }
    if (_selectedRole == null) { // Validasi jika role belum dipilih
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih peran (role) Anda.')),
      );
      return;
    }

    try {
      // Panggil signUpWithEmailAndPassword dengan parameter role
      User? user = await _authService.signUpWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _selectedRole!, // Menggunakan selectedRole yang sudah divalidasi
      );

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pendaftaran berhasil untuk ${user.email} dengan role $_selectedRole!')),
        );
        // Setelah pendaftaran berhasil, navigasi kembali ke halaman login
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Terjadi kesalahan saat pendaftaran.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Akun Baru'),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Buat Akun GEMA ID Baru',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 30),
            _buildInputField(
              'Email',
              Icons.email,
              _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 15),
            _buildInputField(
              'Password',
              Icons.lock,
              _passwordController,
              isPassword: true,
            ),
            const SizedBox(height: 15),
            _buildInputField(
              'Konfirmasi Password',
              Icons.lock,
              _confirmPasswordController,
              isPassword: true,
            ),
            const SizedBox(height: 25), // Spasi sebelum dropdown

            // Widget Dropdown untuk memilih Role
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[200], // Warna background dropdown
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade700),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: const Text('Pilih Peran Anda', style: TextStyle(color: Colors.black54)),
                  value: _selectedRole,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.green),
                  items: _roles.map((String role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role.toUpperCase()), // Tampilkan sebagai huruf besar
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRole = newValue;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 30), // Spasi setelah dropdown

            ElevatedButton(
              onPressed: _registerUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 4,
              ),
              child: const Text(
                'Daftar Sekarang',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Kembali ke halaman login
              },
              child: Text(
                'Sudah punya akun? Login di sini.',
                style: TextStyle(color: Colors.green[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    String hintText,
    IconData icon,
    TextEditingController controller, {
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade700),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.green[700]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        ),
      ),
    );
  }
}