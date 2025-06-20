import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // Digunakan untuk debugPrint
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  // MODIFIKASI: Tambahkan parameter 'role'
  Future<User?> signUpWithEmailAndPassword(
    String email,
    String password,
    String role, // <<< TAMBAHKAN INI
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // Simpan data pengguna baru ke koleksi 'users' di Firestore dengan role yang dipilih
        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email,
          'role': role, // <<< GUNAKAN PARAMETER ROLE DI SINI
          'createdAt': FieldValue.serverTimestamp(),
        });
        debugPrint(
          'Pengguna berhasil didaftarkan dan data disimpan ke Firestore: ${user.email} dengan role $role',
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

  // Metode untuk login dengan email dan password (tetap sama)
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

  Future<String?> getUserRole(String? uid) async {
    if (uid == null) {
      debugPrint('UID pengguna null, tidak dapat mengambil peran.');
      return null;
    }
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        if (userDoc.data() is Map<String, dynamic> &&
            (userDoc.data() as Map<String, dynamic>).containsKey('role')) {
          final role = userDoc['role'] as String?;
          debugPrint('Peran untuk UID $uid: $role');
          return role;
        } else {
          debugPrint(
            'Dokumen pengguna untuk UID $uid tidak memiliki field "role".',
          );
          return null;
        }
      } else {
        debugPrint(
          'Dokumen pengguna untuk UID $uid tidak ditemukan di Firestore.',
        );
        return null;
      }
    } catch (e) {
      debugPrint('Error mendapatkan peran pengguna untuk UID $uid: $e');
      return null;
    }
  }

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