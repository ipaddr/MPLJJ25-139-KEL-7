import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Digunakan untuk potensi penghapusan akun Firebase Auth

class AdminUserVerificationScreen extends StatefulWidget {
  const AdminUserVerificationScreen({super.key});

  @override
  State<AdminUserVerificationScreen> createState() => _AdminUserVerificationScreenState();
}

class _AdminUserVerificationScreenState extends State<AdminUserVerificationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final FirebaseAuth _auth = FirebaseAuth.instance; // Diperlukan jika ingin menghapus akun Firebase Auth

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Verifikasi Pengguna Baru',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
            child: Text(
              'Daftar Pengguna Menunggu Verifikasi',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
          ),
          // StreamBuilder untuk menampilkan daftar pengguna yang belum diverifikasi
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .where('verified', isEqualTo: false) // Filter hanya pengguna yang belum diverifikasi
                  .orderBy('createdAt', descending: true) // Urutkan berdasarkan tanggal pendaftaran terbaru
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error memuat data: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 50, color: Colors.green),
                        SizedBox(height: 10),
                        Text(
                          'Tidak ada pengguna baru yang menunggu verifikasi.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                final List<DocumentSnapshot> unverifiedUsers = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: unverifiedUsers.length,
                  itemBuilder: (context, index) {
                    final userDoc = unverifiedUsers[index];
                    final userData = userDoc.data() as Map<String, dynamic>;

                    final String fullName = userData['fullName'] ?? 'Nama Tidak Tersedia';
                    final String email = userData['email'] ?? 'Email Tidak Tersedia';
                    final String nik = userData['nik'] ?? 'NIK Tidak Tersedia';
                    final String role = userData['role'] ?? 'Peran Tidak Tersedia';
                    final Timestamp? createdAt = userData['createdAt'] as Timestamp?;
                    final String registrationDate = createdAt != null
                        ? '${createdAt.toDate().day}/${createdAt.toDate().month}/${createdAt.toDate().year}'
                        : 'Tanggal Tidak Tersedia';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fullName,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            const SizedBox(height: 4),
                            Text('Email: $email', style: const TextStyle(fontSize: 14, color: Colors.black54)),
                            Text('NIK: $nik', style: const TextStyle(fontSize: 14, color: Colors.black54)),
                            Text('Peran: ${role.toUpperCase()}', style: const TextStyle(fontSize: 14, color: Colors.black54)),
                            Text('Daftar pada: $registrationDate', style: const TextStyle(fontSize: 14, color: Colors.black54)),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => _verifyUser(userDoc.id, fullName),
                                  icon: const Icon(Icons.check_circle_outline, size: 20, color: Colors.white),
                                  label: const Text('Verifikasi', style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    elevation: 2,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () => _confirmDeleteUser(userDoc.id, fullName),
                                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                  label: const Text('Hapus', style: TextStyle(color: Colors.red)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.withOpacity(0.1),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk memverifikasi pengguna (mengubah 'verified' menjadi true)
  Future<void> _verifyUser(String uid, String fullName) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'verified': true,
        'verifiedAt': FieldValue.serverTimestamp(), // Tambahkan timestamp verifikasi
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pengguna "$fullName" berhasil diverifikasi!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memverifikasi pengguna "$fullName": ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Dialog konfirmasi sebelum menghapus pengguna
  Future<void> _confirmDeleteUser(String uid, String fullName) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus Pengguna', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Apakah Anda yakin ingin menghapus pengguna "$fullName"? Tindakan ini tidak dapat dibatalkan.'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _deleteUser(uid, fullName);
              },
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk menghapus dokumen pengguna dari Firestore
  // Catatan: Ini HANYA menghapus dokumen dari Firestore, tidak menghapus akun Firebase Auth.
  // Menghapus akun Firebase Auth memerlukan Admin SDK (server-side).
  Future<void> _deleteUser(String uid, String fullName) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
      // Opsional: Jika Anda ingin menghapus akun Firebase Auth juga, Anda perlu Admin SDK.
      // Misal: await _auth.currentUser?.delete(); // Ini hanya menghapus akun pengguna yang sedang login, bukan yang lain.
      // Untuk menghapus user lain, Anda perlu Admin SDK di Cloud Functions.

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pengguna "$fullName" berhasil dihapus!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus pengguna "$fullName": ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
