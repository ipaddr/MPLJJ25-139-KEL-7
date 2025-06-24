import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_gema/service/auth_service.dart'; // Import AuthService

class ProfileAdminScreen extends StatefulWidget {
  const ProfileAdminScreen({super.key});

  @override
  State<ProfileAdminScreen> createState() => _ProfileAdminScreenState();
}

class _ProfileAdminScreenState extends State<ProfileAdminScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  String _fullName = 'Memuat...';
  String _email = 'Memuat...';
  String _nik = 'Memuat...';
  String _role = 'Memuat...';

  @override
  void initState() {
    super.initState();
    _fetchAdminProfile();
  }

  Future<void> _fetchAdminProfile() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      setState(() {
        _fullName = 'Tidak Login';
        _email = 'Tidak Login';
        _nik = 'Tidak Tersedia';
        _role = 'Tidak Tersedia';
      });
      return;
    }

    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (userDoc.exists) {
        setState(() {
          _fullName = userDoc.get('fullName') ?? 'Nama Admin';
          _email = userDoc.get('email') ?? 'Email Admin';
          _nik = userDoc.get('nik') ?? 'NIK Tidak Tersedia';
          _role = userDoc.get('role') ?? 'Role Tidak Tersedia';
        });
      } else {
        setState(() {
          _fullName = 'Data Tidak Ditemukan';
          _email = 'Data Tidak Ditemukan';
          _nik = 'Tidak Tersedia';
          _role = 'Tidak Tersedia';
        });
      }
    } catch (e) {
      print('Error fetching admin profile: $e');
      setState(() {
        _fullName = 'Error Memuat';
        _email = 'Error Memuat';
        _nik = 'Error';
        _role = 'Error';
      });
    }
  }

  Future<void> _performLogout() async {
    try {
      await _authService.signOut();
      Navigator.pushReplacementNamed(context, '/'); // Kembali ke halaman login
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal logout: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profil Admin', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.green.shade100,
                child: Icon(Icons.person, size: 80, color: Colors.green.shade700),
              ),
            ),
            const SizedBox(height: 20),
            _buildProfileInfoRow('Nama Lengkap', _fullName),
            _buildProfileInfoRow('Email', _email),
            _buildProfileInfoRow('NIK', _nik),
            _buildProfileInfoRow('Peran', _role.toUpperCase()),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: _performLogout,
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Logout', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          const Divider(),
        ],
      ),
    );
  }
}
