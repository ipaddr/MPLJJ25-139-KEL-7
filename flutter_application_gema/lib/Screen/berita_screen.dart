import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BeritaScreen extends StatelessWidget {
  // ID berita yang akan ditampilkan. Akan dilewatkan saat navigasi.
  final String beritaId;

  const BeritaScreen({super.key, required this.beritaId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang putih
      appBar: AppBar(
        title: const Text(
          'Detail Berita',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Tombol kembali otomatis
        automaticallyImplyLeading: true,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        // Mengambil dokumen berita dari koleksi 'berita' berdasarkan beritaId
        future:
            FirebaseFirestore.instance.collection('berita').doc(beritaId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Tampilkan indikator loading saat data sedang diambil
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Tampilkan pesan error jika terjadi kesalahan
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            // Tampilkan pesan jika berita tidak ditemukan
            return const Center(child: Text('Berita tidak ditemukan.'));
          } else {
            // Data berita berhasil diambil, tampilkan kontennya
            var data = snapshot.data!.data() as Map<String, dynamic>;

            // Asumsikan ada field 'judul', 'konten', dan 'tanggal' di dokumen Firestore
            String judul = data['judul'] ?? 'Judul Tidak Tersedia';
            String konten = data['konten'] ?? 'Konten tidak tersedia.';
            Timestamp? tanggalTimestamp = data['tanggal'];
            String tanggal =
                tanggalTimestamp != null
                    ? tanggalTimestamp.toDate().toLocal().toString().split(
                      ' ',
                    )[0]
                    : 'Tanggal Tidak Tersedia';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    judul,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tanggal: $tanggal',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    konten,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5, // Spasi baris untuk keterbacaan
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
