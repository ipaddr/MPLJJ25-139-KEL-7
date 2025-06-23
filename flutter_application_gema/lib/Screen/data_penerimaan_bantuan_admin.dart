import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:intl/intl.dart'; // Untuk format tanggal

class DataPenerimaanBantuanAdminScreen extends StatefulWidget {
  const DataPenerimaanBantuanAdminScreen({super.key});

  @override
  State<DataPenerimaanBantuanAdminScreen> createState() => _DataPenerimaanBantuanAdminScreenState();
}

class _DataPenerimaanBantuanAdminScreenState extends State<DataPenerimaanBantuanAdminScreen> {
  String? _selectedStatusFilter;
  String _searchQuery = '';
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fungsi untuk membangun Collection Group Query Firestore
  // Ini akan membaca dari SEMUA sub-koleksi 'pengajuan_bantuan' di seluruh database
  Query _buildFirestoreQuery() {
    Query query = _firestore.collectionGroup('pengajuan_bantuan'); // <<< PENTING: COLLECTION GROUP QUERY

    if (_selectedStatusFilter != null && _selectedStatusFilter!.isNotEmpty) {
      query = query.where('status_pengajuan', isEqualTo: _selectedStatusFilter); // Menggunakan field status_pengajuan
    }

    query = query.orderBy('tanggal_pengajuan', descending: true); // Urutkan berdasarkan tanggal terbaru

    return query;
  }

  // Fungsi untuk mendapatkan total jumlah dokumen (untuk pagination)
  Future<int> _getTotalDocumentsCount() async {
    final query = _buildFirestoreQuery();
    final snapshot = await query.count().get();
    return snapshot.count ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Column( // Menggunakan Column utama untuk struktur layout
      children: [
        // Header Halaman
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 40.0), // Padding lebih besar lagi
          decoration: BoxDecoration(
            gradient: LinearGradient( // Gradien yang lebih kontras (biru untuk verifikasi)
              colors: [Colors.blue.shade600!, Colors.blue.shade800!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3), // Shadow lebih gelap dan tebal
                blurRadius: 20, // Blur lebih besar
                offset: const Offset(0, 10), // Offset lebih besar
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Verifikasi Pengajuan', // Judul halaman diubah untuk pengajuan
                style: TextStyle(
                  fontSize: 32, // Ukuran font lebih besar
                  fontWeight: FontWeight.w900, // Sangat bold
                  color: Colors.white,
                  letterSpacing: 1.0, // Spasi huruf
                ),
              ),
              Icon(Icons.checklist, size: 45, color: Colors.white), // Ikon yang sesuai
            ],
          ),
        ),
        const SizedBox(height: 35), // Spasi setelah header

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: _buildFilterSearchSection(context),
        ),
        const SizedBox(height: 40), // Spasi setelah filter/pencarian
        
        // Bagian Tabel Data
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _buildFirestoreQuery().snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.blue)); // Warna loading
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0), // Padding lebih besar
                    child: Text(
                      'Error memuat data: ${snapshot.error}\nPastikan koneksi internet Anda stabil dan aturan keamanan Firestore sudah benar.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 18),
                    ),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 80, color: Colors.grey), // Ikon yang sesuai
                      SizedBox(height: 25),
                      Text(
                        'Tidak ada pengajuan bantuan yang ditemukan.', // Teks disesuaikan
                        style: TextStyle(fontSize: 22, color: Colors.grey, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }

              final List<DocumentSnapshot> allDocuments = snapshot.data!.docs;

              final filteredDocuments = allDocuments.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final namaProgram = (data['nama_program'] as String? ?? '').toLowerCase();
                final userNama = (data['user_nama'] as String? ?? '').toLowerCase();
                final userNik = (data['user_nik'] as String? ?? '').toLowerCase();
                final query = _searchQuery.toLowerCase();

                return namaProgram.contains(query) || userNama.contains(query) || userNik.contains(query);
              }).toList();

              final int startIndex = (_currentPage - 1) * _itemsPerPage;
              final int endIndex = startIndex + _itemsPerPage;
              final List<DocumentSnapshot> paginatedDocuments = filteredDocuments.sublist(
                startIndex.clamp(0, filteredDocuments.length),
                endIndex.clamp(0, filteredDocuments.length),
              );

              return SingleChildScrollView(
                 scrollDirection: Axis.vertical,
                 child: _buildPengajuanTableSection(context, paginatedDocuments), // Nama method diubah
              );
            },
          ),
        ),
        
        // Bagian Pagination (di luar StreamBuilder agar selalu terlihat)
        FutureBuilder<int>(
          future: _getTotalDocumentsCount(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(15.0),
                child: CircularProgressIndicator(strokeWidth: 4, color: Colors.blue), // Warna loading
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

  // --- Widget Bagian Filter dan Pencarian ---
  Widget _buildFilterSearchSection(BuildContext context) {
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(35.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pencarian & Filter Pengajuan', // Judul disesuaikan
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blue), // Warna disesuaikan
            ),
            const SizedBox(height: 35),
            TextField(
              decoration: InputDecoration(
                labelText: 'Cari Nama Program / Nama User / NIK', // Label disesuaikan
                hintText: 'Misal: Bantuan Modal atau Ani Santoso',
                labelStyle: TextStyle(color: Colors.blue.shade700, fontSize: 16), // Warna label
                hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 16), // Warna hint
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  borderSide: BorderSide(color: Colors.blue.shade400!, width: 2.0), // Border lebih tebal
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  borderSide: BorderSide(color: Colors.blue.shade900!, width: 4.0), // Border sangat tebal saat fokus
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.blue, size: 24), // Ikon lebih besar
                suffixIcon: _searchQuery.isNotEmpty ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                ) : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _currentPage = 1;
                });
              },
            ),
            const SizedBox(height: 25),
            _buildDropdownFilter(
              labelText: 'Status Pengajuan', // Label disesuaikan
              value: _selectedStatusFilter,
              items: const ['Menunggu', 'Disetujui', 'Ditolak'], // Opsi disesuaikan
              onChanged: (value) {
                setState(() {
                  _selectedStatusFilter = value;
                  _currentPage = 1;
                });
              },
            ),
            const SizedBox(height: 35),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Filter dan pencarian diterapkan!', style: TextStyle(color: Colors.white))),
                      );
                    },
                    icon: const Icon(Icons.filter_alt, color: Colors.white, size: 24),
                    label: const Text('Terapkan Filter', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800], // Warna biru lebih gelap
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      elevation: 10,
                      shadowColor: Colors.blue.shade700!.withOpacity(0.6),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _selectedStatusFilter = null;
                      _currentPage = 1;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Filter dan pencarian direset!', style: TextStyle(color: Colors.blue))),
                    );
                  },
                  icon: const Icon(Icons.refresh, color: Colors.blue, size: 24),
                  label: const Text('Reset', style: TextStyle(color: Colors.blue, fontSize: 19, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(color: Colors.blue.shade800, width: 2.5),
                    ),
                    elevation: 10,
                    shadowColor: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget pembantu untuk Dropdown Filter
  Widget _buildDropdownFilter({
    required String labelText,
    String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.blue.shade800, fontSize: 16), // Warna label
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.0),
          borderSide: BorderSide(color: Colors.blue.shade400, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.0),
          borderSide: BorderSide(color: Colors.blue.shade900, width: 4.0),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
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

  // --- Widget Bagian Tabel Data ---
  Widget _buildPengajuanTableSection(BuildContext context, List<DocumentSnapshot> data) { // Nama method diubah
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
              child: Text(
                'Daftar Pengajuan Bantuan', // Judul tabel disesuaikan
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 30),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 100),
                child: DataTable(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue.shade200, width: 2.0), // Border lebih tebal
                    borderRadius: BorderRadius.circular(20),
                  ),
                  headingRowColor: MaterialStateProperty.resolveWith((states) => Colors.blue.shade100), // Warna header tabel
                  dataRowHeight: 75,
                  columnSpacing: 40,
                  columns: const [
                    DataColumn(label: Text('No.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16))),
                    DataColumn(label: Text('Nama Program', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16))), // Kolom disesuaikan
                    DataColumn(label: Text('Pemohon', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16))), // Kolom disesuaikan
                    DataColumn(label: Text('NIK Pemohon', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16))), // Kolom disesuaikan
                    DataColumn(label: Text('Tanggal', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16))), // Kolom disesuaikan
                    DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16))),
                    DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16))),
                  ],
                  rows: List<DataRow>.generate(
                    data.length,
                    (index) {
                      final doc = data[index];
                      final item = doc.data() as Map<String, dynamic>;
                      final String namaProgram = item['nama_program'] ?? 'N/A'; // Field dari pengajuan
                      final String userNama = item['user_nama'] ?? 'N/A';       // Field dari duplikasi
                      final String userNik = item['user_nik'] ?? 'N/A';         // Field dari duplikasi
                      final Timestamp? timestamp = item['tanggal_pengajuan'] as Timestamp?;
                      final String tanggalPengajuanFormatted = timestamp != null
                          ? DateFormat('dd MMM').format(timestamp.toDate())
                          : 'N/A';
                      final String statusPengajuan = item['status_pengajuan'] ?? 'N/A'; // Field status dari pengajuan

                      Color statusColor = Colors.grey;
                      Color statusBgColor = Colors.grey.withOpacity(0.1);
                      if (statusPengajuan == 'Disetujui') {
                        statusColor = Colors.green.shade800;
                        statusBgColor = Colors.green.withOpacity(0.1);
                      } else if (statusPengajuan == 'Ditolak') {
                        statusColor = Colors.red.shade800!;
                        statusBgColor = Colors.red.withOpacity(0.1);
                      } else if (statusPengajuan == 'Menunggu') {
                        statusColor = Colors.amber.shade800;
                        statusBgColor = Colors.amber.withOpacity(0.1);
                      }

                      return DataRow(
                        cells: [
                          DataCell(Text('${(index + 1) + (_currentPage - 1) * _itemsPerPage}', style: const TextStyle(fontSize: 15))),
                          DataCell(
                            Container(
                              constraints: const BoxConstraints(maxWidth: 150), // Batasi lebar teks nama program
                              child: Text(namaProgram, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15)),
                            ),
                          ),
                          DataCell(Text(userNama, style: const TextStyle(fontSize: 15))),
                          DataCell(Text(userNik, style: const TextStyle(fontSize: 15))),
                          DataCell(Text(tanggalPengajuanFormatted, style: const TextStyle(fontSize: 15))),
                          DataCell(
                            _buildStatusBadge(statusPengajuan, statusColor, statusBgColor),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.info_outline, color: Colors.blue, size: 26),
                                  tooltip: 'Lihat Detail Pengajuan',
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Melihat detail pengajuan ${namaProgram} oleh ${userNama}')),
                                    );
                                    // TODO: Navigasi ke halaman detail pengajuan
                                  },
                                ),
                                if (statusPengajuan == 'Menunggu') // Tombol aksi hanya untuk status Menunggu
                                  IconButton(
                                    icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 26),
                                    tooltip: 'Setujui Pengajuan',
                                    onPressed: () {
                                      _showApprovalDialog(context, item['user_uid'], doc.id, 'Disetujui', namaProgram);
                                    },
                                  ),
                                if (statusPengajuan == 'Menunggu')
                                  IconButton(
                                    icon: const Icon(Icons.highlight_off, color: Colors.red, size: 26),
                                    tooltip: 'Tolak Pengajuan',
                                    onPressed: () {
                                      _showApprovalDialog(context, item['user_uid'], doc.id, 'Ditolak', namaProgram);
                                    },
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 26),
                                  tooltip: 'Hapus Pengajuan',
                                  onPressed: () {
                                    _confirmDelete(context, item['user_uid'], doc.id, namaProgram);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pembantu untuk badge status
  Widget _buildStatusBadge(String status, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: textColor.withOpacity(0.5), width: 2.0),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  // Dialog konfirmasi setuju/tolak
  Future<void> _showApprovalDialog(BuildContext context, String userUid, String pengajuanId, String newStatus, String namaProgram) async {
    final bool isApproved = newStatus == 'Disetujui';
    final Color dialogColor = isApproved ? Colors.green.shade700 : Colors.red.shade700;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            '${isApproved ? 'Setujui' : 'Tolak'} Pengajuan', // Judul dialog disesuaikan
            style: TextStyle(fontWeight: FontWeight.bold, color: dialogColor, fontSize: 22),
          ),
          content: Text(
            'Apakah Anda yakin ingin ${isApproved ? 'menyetujui' : 'menolak'} pengajuan program "${namaProgram}"?',
            style: const TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
              child: const Text('Batal', style: TextStyle(fontSize: 16)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: dialogColor),
              child: Text(isApproved ? 'Setujui' : 'Tolak', style: const TextStyle(color: Colors.white, fontSize: 16)),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  // Update status di sub-koleksi user tersebut
                  await _firestore
                      .collection('users').doc(userUid)
                      .collection('pengajuan_bantuan').doc(pengajuanId)
                      .update({
                    'status_pengajuan': newStatus, // Update field status_pengajuan
                    'last_updated_by_admin': FieldValue.serverTimestamp(),
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Pengajuan ${namaProgram} berhasil di${newStatus.toLowerCase()}!', style: const TextStyle(color: Colors.white)),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal ${newStatus.toLowerCase()} pengajuan: $e', style: const TextStyle(color: Colors.white)),
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
  Future<void> _confirmDelete(BuildContext context, String userUid, String pengajuanId, String namaProgram) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Hapus Pengajuan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 22)), // Judul dialog disesuaikan
          content: Text('Apakah Anda yakin ingin menghapus pengajuan program "${namaProgram}"? Data yang dihapus tidak dapat dikembalikan.'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
              child: const Text('Batal', style: TextStyle(fontSize: 16)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
              child: const Text('Hapus', style: TextStyle(color: Colors.white, fontSize: 16)),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  // Hapus dokumen dari sub-koleksi user tersebut
                  await _firestore
                      .collection('users').doc(userUid)
                      .collection('pengajuan_bantuan').doc(pengajuanId)
                      .delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Pengajuan ${namaProgram} berhasil dihapus!', style: const TextStyle(color: Colors.white)),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus pengajuan: $e', style: const TextStyle(color: Colors.white)),
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

  // --- Widget Bagian Pagination ---
  Widget _buildPaginationSection(int totalPages) {
    if (totalPages <= 1 && _searchQuery.isEmpty && _selectedStatusFilter == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 35),
            onPressed: _currentPage > 1
                ? () {
                    setState(() {
                      _currentPage--;
                    });
                  }
                : null,
            color: Colors.blue[700], // Warna disesuaikan dengan tema halaman ini
            disabledColor: Colors.grey.shade500,
          ),
          const SizedBox(width: 12),
          ...List.generate(totalPages, (index) {
            int pageNumber = index + 1;
            if (totalPages > 5 &&
                pageNumber != 1 &&
                pageNumber != totalPages &&
                (pageNumber < _currentPage - 1 || pageNumber > _currentPage + 1)) {
              if (pageNumber == _currentPage - 2 || pageNumber == _currentPage + 2) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text('...', style: TextStyle(color: Colors.grey, fontSize: 22, fontWeight: FontWeight.bold)),
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
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 35),
            onPressed: _currentPage < totalPages
                ? () {
                    setState(() {
                      _currentPage++;
                    });
                  }
                : null,
            color: Colors.blue[700], // Warna disesuaikan dengan tema halaman ini
            disabledColor: Colors.grey.shade500,
          ),
        ],
      ),
    );
  }

  // Widget pembantu untuk tombol pagination
  Widget _buildPaginationButton(String text, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue[700] : Colors.grey[200], // Warna disesuaikan
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isActive ? Colors.blue.shade700 : Colors.grey.shade400!, width: 2.0),
          boxShadow: isActive
              ? [BoxShadow(color: Colors.blue.withOpacity(0.5), blurRadius: 12, offset: const Offset(0, 5))]
              : [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 6, offset: const Offset(0, 4))],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black87,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            fontSize: 19,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}