import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fungsi untuk mendaftar pengguna dengan email, password, role, fullName, dan nik
  Future<User?> signUpWithEmailAndPassword(
      String email, String password, String role, String fullName, String nik) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Simpan data pengguna ke koleksi 'users' di Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'role': role,
          'fullName': fullName,
          'nik': nik,
          'createdAt': FieldValue.serverTimestamp(),
          'verified': false, // <<< PENTING: Set status verifikasi awal ke false
        });
      }
      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('Password terlalu lemah.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('Akun sudah terdaftar untuk email tersebut.');
      }
      throw Exception(e.message ?? 'Terjadi kesalahan Firebase Auth.');
    } catch (e) {
      throw Exception('Gagal mendaftar: ${e.toString()}');
    }
  }

  // Fungsi untuk login pengguna
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Setelah login berhasil, cek status verifikasi di Firestore
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          bool? isVerified = userDoc.get('verified') as bool?;
          
          if (isVerified == true) {
            return user; // Pengguna diverifikasi, izinkan login
          } else {
            // Pengguna belum diverifikasi, logout dan lempar exception
            await _auth.signOut(); // Pastikan pengguna di-logout
            throw Exception('Akun Anda belum diverifikasi oleh admin. Mohon tunggu konfirmasi.');
          }
        } else {
          // Dokumen pengguna tidak ditemukan di Firestore, mungkin ada inkonsistensi
          await _auth.signOut();
          throw Exception('Data pengguna tidak ditemukan. Mohon coba lagi atau daftar ulang.');
        }
      }
      return null; // Seharusnya tidak tercapai karena Exception di atas atau user != null
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('Tidak ada pengguna ditemukan untuk email tersebut.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Password salah untuk email tersebut.');
      }
      throw Exception(e.message ?? 'Terjadi kesalahan Firebase Auth.');
    } catch (e) {
      throw Exception('Gagal login: ${e.toString()}');
    }
  }

  // Fungsi untuk mengambil peran pengguna dari Firestore
  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc.get('role') as String?;
      }
      return null;
    } catch (e) {
      print('Error getting user role: $e');
      return null;
    }
  }

  // Fungsi untuk logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Mendapatkan stream perubahan status autentikasi
  Stream<User?> get user {
    return _auth.authStateChanges();
  }
}