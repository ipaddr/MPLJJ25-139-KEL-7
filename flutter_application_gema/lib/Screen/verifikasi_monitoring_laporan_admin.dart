import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

// VerifikasiMonitoringLaporanAdminScreen adalah StatefulWidget karena akan mengelola state
// seperti filter, query pencarian, dan halaman pagination.
class VerifikasiMonitoringLaporanAdminScreen extends StatefulWidget {
  const VerifikasiMonitoringLaporanAdminScreen({super.key});

  @override
  State<VerifikasiMonitoringLaporanAdminScreen> createState() => _VerifikasiMonitoringLaporanAdminScreenState();
}

class _VerifikasiMonitoringLaporanAdminScreenState extends State<VerifikasiMonitoringLaporanAdminScreen> {
  // State untuk menyimpan pilihan filter status verifikasi
  String? _selectedStatusFilter;

  // State untuk menyimpan query pencarian dari input teks
  String _searchQuery = '';

  // State untuk pagination (nomor halaman saat ini)
  int _currentPage = 1;
  // Jumlah item yang ditampilkan per halaman
  final int _itemsPerPage = 10;

  // Instance FirebaseFirestore untuk berinteraksi dengan database Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fungsi ini membangun objek Query Firestore berdasarkan filter yang dipilih.
  // Sekarang menargetkan koleksi top-level 'programBantuan'.
  Query _buildFirestoreQuery() {
    // --- PERUBAHAN PENTING DI SINI: Targetkan koleksi top-level 'programBantuan' ---
    Query query = _firestore.collection('programBantuan');

    // Filter berdasarkan status (sesuai field 'status' di dokumen programBantuan)
    if (_selectedStatusFilter != null && _selectedStatusFilter!.isNotEmpty) {
      query = query.where('status', isEqualTo: _selectedStatusFilter);
    }

    // Urutkan data berdasarkan 'tanggalPengajuan' secara descending (terbaru lebih dulu)
    query = query.orderBy('tanggalPengajuan', descending: true);

    return query;
  }

  // Fungsi untuk mendapatkan total jumlah dokumen yang sesuai dengan filter
  Future<int> _getTotalDocumentsCount() async {
    final query = _buildFirestoreQuery();
    final snapshot = await query.count().get();
    return snapshot.count ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Column( // Menggunakan Column sebagai widget utama untuk menata UI secara vertikal
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0), // Padding lebih besar untuk seluruh konten
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri untuk elemen dalam kolom
            children: [
              // Judul halaman "Verifikasi Laporan Bantuan"
              const Text(
                'Verifikasi Laporan Bantuan', // Judul yang lebih ringkas
                style: TextStyle(
                  fontSize: 28, // Ukuran font lebih besar untuk judul utama
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange, // Warna judul khusus untuk Verifikasi
                ),
              ),
              const SizedBox(height: 25), // Spasi lebih besar setelah judul

              // Bagian Filter dan Pencarian, dibangun oleh widget terpisah
              _buildFilterSearchSection(context),
              const SizedBox(height: 30), // Spasi setelah filter/pencarian
            ],
          ),
        ),

        // Bagian Tabel Data, dibungkus dalam Expanded agar memenuhi sisa ruang vertikal
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            // Mendengarkan stream data dari Firestore berdasarkan query yang dibangun
            stream: _buildFirestoreQuery().snapshots(),
            builder: (context, snapshot) {
              // Menampilkan indikator loading saat data sedang dimuat
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.deepOrange)); // Tampilkan loading
              }
              // Menampilkan pesan error jika terjadi kesalahan saat memuat data
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Error memuat data: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                );
              }
              // Menampilkan pesan jika tidak ada data yang ditemukan
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, size: 50, color: Colors.grey),
                      SizedBox(height: 10),
                      Text(
                        'Tidak ada pengajuan program bantuan yang ditemukan.', // Teks disesuaikan
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              final List<DocumentSnapshot> allDocuments = snapshot.data!.docs;

              // Filter data di sisi klien untuk pencarian teks (_searchQuery).
              // Mencari di namaProgram, deskripsiProgram, atau kategoriUsaha dari dokumen programBantuan.
              final filteredDocuments = allDocuments.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final namaProgram = (data['namaProgram'] as String? ?? '').toLowerCase();
                final deskripsiProgram = (data['deskripsiProgram'] as String? ?? '').toLowerCase();
                final kategoriUsaha = (data['kategoriUsaha'] as String? ?? '').toLowerCase();
                final query = _searchQuery.toLowerCase();

                return namaProgram.contains(query) || deskripsiProgram.contains(query) || kategoriUsaha.contains(query);
              }).toList();

              // Implementasi pagination di sisi klien:
              final int startIndex = (_currentPage - 1) * _itemsPerPage;
              final int endIndex = startIndex + _itemsPerPage;
              final List<DocumentSnapshot> paginatedDocuments = filteredDocuments.sublist(
                startIndex.clamp(0, filteredDocuments.length),
                endIndex.clamp(0, filteredDocuments.length),
              );

              // --- PERUBAHAN UTAMA DI SINI: Memanggil _buildMonitoringBoxChartSection ---
              return _buildMonitoringBoxChartSection(context, paginatedDocuments);
            },
          ),
        ),

        // Bagian Pagination, ditampilkan di luar StreamBuilder agar selalu terlihat
        FutureBuilder<int>(
          future: _getTotalDocumentsCount(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.deepOrange),
              );
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return const SizedBox.shrink();
            }

            final int totalItems = snapshot.data!;
            final int totalPages = (totalItems / _itemsPerPage).ceil();

            return _buildPaginationSection(totalPages);
          },
        ),
      ],
    );
  }

  // MARK: - Custom Widgets untuk Struktur UI

  Widget _buildFilterSearchSection(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Pengajuan Bantuan', // Judul disesuaikan
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Cari Nama Program / Deskripsi / Kategori Usaha', // Label disesuaikan
                hintText: 'Masukkan kata kunci',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.deepOrange.shade700!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.deepOrange.shade900!, width: 2),
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.deepOrange),
                contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _currentPage = 1;
                });
              },
            ),
            const SizedBox(height: 15),
            // Filter Status Pengajuan
            _buildDropdownFilter(
              labelText: 'Status Pengajuan',
              value: _selectedStatusFilter,
              items: const ['Disetujui', 'Ditolak', 'Diajukan'], // Sesuaikan dengan nilai di Firestore
              onChanged: (value) {
                setState(() {
                  _selectedStatusFilter = value;
                  _currentPage = 1;
                });
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Filter dan pencarian diterapkan!')),
                      );
                    },
                    icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                    label: const Text('Terapkan', style: TextStyle(color: Colors.white, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange[700],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 3,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _selectedStatusFilter = null;
                        _currentPage = 1;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Filter dan pencarian direset!')),
                      );
                    },
                    icon: const Icon(Icons.clear, color: Colors.deepOrange),
                    label: const Text('Reset', style: TextStyle(color: Colors.deepOrange, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.deepOrange.shade700!),
                      ),
                      elevation: 3,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String labelText,
    String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.deepOrange.shade700!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.deepOrange.shade900!, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      ),
      value: value,
      items: items.map((String val) {
        return DropdownMenuItem<String>(
          value: val,
          child: Text(val),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  // --- Widget Bagian Tampilan "Box Chart" ---
  // Menggantikan _buildMonitoringTableSection
  Widget _buildMonitoringBoxChartSection(BuildContext context, List<DocumentSnapshot> data) {
    return Expanded( // Memastikan ListView mengisi sisa ruang yang tersedia
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20.0), // Padding di sekitar list
        itemCount: data.length,
        itemBuilder: (context, index) {
          final doc = data[index];
          final item = doc.data() as Map<String, dynamic>;

          final String namaProgram = item['namaProgram'] ?? 'N/A';
          final String userIdPengaju = item['userId'] ?? 'N/A';
          final Timestamp? timestamp = item['tanggalPengajuan'] as Timestamp?;
          final String tanggalPengajuan = timestamp != null
              ? '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}'
              : 'N/A';
          final String kategoriUsaha = item['kategoriUsaha'] ?? 'N/A';
          final String statusPengajuan = item['status'] ?? 'N/A';
          final String deskripsiProgram = item['deskripsiProgram'] ?? 'Tidak ada deskripsi.'; // Ambil deskripsi

          Color statusColor = Colors.grey;
          Color statusBgColor = Colors.grey.withOpacity(0.1);
          if (statusPengajuan == 'Disetujui') {
            statusColor = Colors.green.shade800!;
            statusBgColor = Colors.green.withOpacity(0.1);
          } else if (statusPengajuan == 'Ditolak') {
            statusColor = Colors.red.shade800!;
            statusBgColor = Colors.red.withOpacity(0.1);
          } else if (statusPengajuan == 'Diajukan') {
            statusColor = Colors.amber.shade800!;
            statusBgColor = Colors.amber.withOpacity(0.1);
          }

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0), // Margin antar kartu
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          namaProgram,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          statusPengajuan,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pengaju: $userIdPengaju',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  Text(
                    'Tanggal: $tanggalPengajuan',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  Text(
                    'Kategori: $kategoriUsaha',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Deskripsi: ${deskripsiProgram.length > 100 ? deskripsiProgram.substring(0, 100) + '...' : deskripsiProgram}', // Potong deskripsi jika terlalu panjang
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  // Baris Tombol Aksi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end, // Rata kanan tombol aksi
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Melihat detail program ${namaProgram}')),
                          );
                          // TODO: Navigasi ke halaman detail laporan, bisa kirim doc.id atau seluruh item data
                          // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => DetailProgramScreen(programData: item)));
                        },
                        icon: const Icon(Icons.info_outline, size: 20, color: Colors.blue),
                        label: const Text('Detail', style: TextStyle(color: Colors.blue)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (statusPengajuan == 'Diajukan') // Tampilkan tombol ini hanya jika status 'Diajukan'
                        ElevatedButton.icon(
                          onPressed: () {
                            _showApprovalDialog(context, doc.reference, namaProgram, 'Disetujui');
                          },
                          icon: const Icon(Icons.check_circle_outline, size: 20, color: Colors.green),
                          label: const Text('Setujui', style: TextStyle(color: Colors.green)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.withOpacity(0.1),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                        ),
                      const SizedBox(width: 8),
                      if (statusPengajuan == 'Diajukan') // Tampilkan tombol ini hanya jika status 'Diajukan'
                        ElevatedButton.icon(
                          onPressed: () {
                            _showApprovalDialog(context, doc.reference, namaProgram, 'Ditolak');
                          },
                          icon: const Icon(Icons.cancel_outlined, size: 20, color: Colors.red),
                          label: const Text('Tolak', style: TextStyle(color: Colors.red)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.withOpacity(0.1),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                        ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          _confirmDelete(context, doc.reference, namaProgram);
                        },
                        icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                        label: const Text('Hapus', style: TextStyle(color: Colors.grey)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.withOpacity(0.1),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Dialog konfirmasi setuju/tolak
  Future<void> _showApprovalDialog(BuildContext context, DocumentReference docRef, String namaProgram, String newStatus) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('$newStatus Pengajuan', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Apakah Anda yakin ingin $newStatus pengajuan program "$namaProgram"?'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: newStatus == 'Disetujui' ? Colors.green : Colors.red,
              ),
              child: Text(newStatus, style: const TextStyle(color: Colors.white)),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  await docRef.update({
                    'status': newStatus,
                    'last_updated_admin': FieldValue.serverTimestamp(),
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Pengajuan "${namaProgram}" berhasil di$newStatus!', style: const TextStyle(color: Colors.white)),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal $newStatus pengajuan: ${e.toString()}', style: const TextStyle(color: Colors.white)),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Dialog konfirmasi hapus
  Future<void> _confirmDelete(BuildContext context, DocumentReference docRef, String namaProgram) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus Pengajuan', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Apakah Anda yakin ingin menghapus pengajuan program "$namaProgram"? Data yang dihapus tidak dapat dikembalikan.'),
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
                try {
                  await docRef.delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Pengajuan "${namaProgram}" berhasil dihapus!', style: const TextStyle(color: Colors.white)),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus pengajuan: ${e.toString()}', style: const TextStyle(color: Colors.white)),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // MARK: - Widget Bagian Pagination

  Widget _buildPaginationSection(int totalPages) {
    if (totalPages <= 1 && _searchQuery.isEmpty && _selectedStatusFilter == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 28),
            onPressed: _currentPage > 1
                ? () {
                    setState(() {
                      _currentPage--;
                    });
                  }
                : null,
            color: Colors.deepOrange[700],
            disabledColor: Colors.grey,
          ),
          const SizedBox(width: 8),
          ...List.generate(totalPages, (index) {
            int pageNumber = index + 1;
            if (totalPages > 5 &&
                pageNumber != 1 &&
                pageNumber != totalPages &&
                (pageNumber < _currentPage - 1 || pageNumber > _currentPage + 1)) {
              if (pageNumber == _currentPage - 2 || pageNumber == _currentPage + 2) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Text('...', style: TextStyle(color: Colors.grey, fontSize: 16)),
                );
              }
              return const SizedBox.shrink();
            }
            return _buildPaginationButton('$pageNumber', pageNumber == _currentPage, () {
              setState(() {
                _currentPage = pageNumber;
              });
            });
          }),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 28),
            onPressed: _currentPage < totalPages
                ? () {
                    setState(() {
                      _currentPage++;
                    });
                  }
                : null,
            color: Colors.deepOrange[700],
            disabledColor: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationButton(String text, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.deepOrange[700] : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? Colors.deepOrange.shade700! : Colors.transparent),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
