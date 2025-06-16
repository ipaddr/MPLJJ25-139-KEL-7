import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // Digunakan untuk debugPrint
import 'package:cloud_firestore/cloud_firestore.dart'; // <<< PENTING: TAMBAHKAN IMPORT INI

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // <<< PENTING: TAMBAHKAN INISIALISASI INI

  // Mendapatkan stream perubahan status pengguna (login/logout)
  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  // Metode untuk mendaftar dengan email dan password
  // >>> LOGIKA PENYIMPANAN ROLE DEFAULT SAAT PENDAFTARAN DITAMBAHKAN DI SINI
  Future<User?> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // Simpan data pengguna baru ke koleksi 'users' di Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email,
          'role':
              'user', // <<< Role default untuk setiap pendaftaran baru adalah 'user'
          'createdAt':
              FieldValue.serverTimestamp(), // Opsional: untuk melacak waktu pendaftaran
        });
        debugPrint(
          'Pengguna berhasil didaftarkan dan data disimpan ke Firestore: ${user.email}',
        );
      }
      debugPrint('Pengguna berhasil didaftarkan: ${user?.email}');
      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Gagal mendaftar: ${e.message}');
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Kata sandi terlalu lemah.';
          break;
        case 'email-already-in-use':
          errorMessage = 'Email sudah digunakan oleh akun lain.';
          break;
        case 'invalid-email':
          errorMessage = 'Format email tidak valid.';
          break;
        default:
          errorMessage = 'Terjadi kesalahan saat mendaftar. Silakan coba lagi.';
      }
      throw FirebaseAuthException(code: e.code, message: errorMessage);
    } catch (e) {
      debugPrint('Terjadi kesalahan tidak terduga saat mendaftar: $e');
      throw Exception('Terjadi kesalahan tidak terduga.');
    }
  }
  // <<< AKHIR LOGIKA PENYIMPANAN ROLE DEFAULT

  // Metode untuk login dengan email dan password
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      debugPrint('Pengguna berhasil login: ${user?.email}');
      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Gagal login: ${e.message}');
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Pengguna dengan email tersebut tidak ditemukan.';
          break;
        case 'wrong-password':
          errorMessage = 'Kata sandi salah.';
          break;
        case 'invalid-email':
          errorMessage = 'Format email tidak valid.';
          break;
        case 'user-disabled':
          errorMessage = 'Akun pengguna telah dinonaktifkan.';
          break;
        default:
          errorMessage = 'Terjadi kesalahan saat login. Silakan coba lagi.';
      }
      throw FirebaseAuthException(code: e.code, message: errorMessage);
    } catch (e) {
      debugPrint('Terjadi kesalahan tidak terduga saat login: $e');
      throw Exception('Terjadi kesalahan tidak terduga.');
    }
  }

  // >>> PENTING: METODE BARU UNTUK MENDAPATKAN ROLE PENGGUNA DARI FIRESTORE
  Future<String?> getUserRole(String? uid) async {
    if (uid == null) {
      debugPrint('UID pengguna null, tidak dapat mengambil peran.');
      return null;
    }
    try {
      // Ambil dokumen pengguna dari koleksi 'users' berdasarkan UID
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        // Periksa apakah field 'role' ada dan bukan null
        if (userDoc.data() is Map<String, dynamic> &&
            (userDoc.data() as Map<String, dynamic>).containsKey('role')) {
          final role = userDoc['role'] as String?;
          debugPrint('Peran untuk UID $uid: $role');
          return role;
        } else {
          debugPrint(
            'Dokumen pengguna untuk UID $uid tidak memiliki field "role".',
          );
          return null; // Dokumen ada tapi tidak punya field 'role'
        }
      } else {
        debugPrint(
          'Dokumen pengguna untuk UID $uid tidak ditemukan di Firestore.',
        );
        return null; // Dokumen tidak ditemukan
      }
    } catch (e) {
      debugPrint('Error mendapatkan peran pengguna untuk UID $uid: $e');
      return null;
    }
  }
  // <<< AKHIR DARI METODE getUserRole

  // Metode untuk logout
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      debugPrint('Pengguna berhasil logout.');
    } catch (e) {
      debugPrint('Gagal logout: $e');
      throw Exception('Terjadi kesalahan saat logout.');
    }
  }
}
