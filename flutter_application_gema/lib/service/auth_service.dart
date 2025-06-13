import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // Digunakan untuk debugPrint

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mendapatkan stream perubahan status pengguna (login/logout)
  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  // Metode untuk mendaftar dengan email dan password
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
      // Melemparkan exception dengan pesan yang lebih user-friendly
      throw FirebaseAuthException(code: e.code, message: errorMessage);
    } catch (e) {
      debugPrint('Terjadi kesalahan tidak terduga saat mendaftar: $e');
      throw Exception('Terjadi kesalahan tidak terduga.');
    }
  }

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
      // Melemparkan exception dengan pesan yang lebih user-friendly
      throw FirebaseAuthException(code: e.code, message: errorMessage);
    } catch (e) {
      debugPrint('Terjadi kesalahan tidak terduga saat login: $e');
      throw Exception('Terjadi kesalahan tidak terduga.');
    }
  }

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
