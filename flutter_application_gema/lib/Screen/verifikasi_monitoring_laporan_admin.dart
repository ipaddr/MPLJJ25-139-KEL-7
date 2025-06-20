import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <<< PENTING: Import Firestore

class VerifikasiMonitoringLaporanAdminScreen extends StatefulWidget { // <<< UBAH JADI StatefulWidget
  const VerifikasiMonitoringLaporanAdminScreen({super.key});

  @override
  State<VerifikasiMonitoringLaporanAdminScreen> createState() => _VerifikasiMonitoringLaporanAdminScreenState();
}

class _VerifikasiMonitoringLaporanAdminScreenState extends State<VerifikasiMonitoringLaporanAdminScreen> { // <<< UBAH NAMA STATE
  String? _selectedLokasiFilter;
  String? _selectedStatusFilter;
  String _searchQuery = ''; // State untuk query pencarian
  int _currentPage = 1; // Untuk pagination
  final int _itemsPerPage = 10; // Jumlah item per halaman

  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Instance Firestore

  // Fungsi untuk membangun Query Firestore berdasarkan filter
  Query _buildFirestoreQuery() {
    Query query = _firestore.collection('monitoring_lapangan'); // Ganti dengan nama koleksi Anda

    if (_selectedLokasiFilter != null && _selectedLokasiFilter!.isNotEmpty) {
      query = query.where('lokasi', isEqualTo: _selectedLokasiFilter);
    }
    if (_selectedStatusFilter != null && _selectedStatusFilter!.isNotEmpty) {
      query = query.where('status_verifikasi', isEqualTo: _selectedStatusFilter);
    }

    // Urutkan data, penting untuk konsistensi tampilan dan pagination
    query = query.orderBy('tanggal_kunjungan', descending: true); // Urutkan berdasarkan tanggal terbaru

    return query;
  }

  // Fungsi untuk mendapatkan total jumlah dokumen
  Future<int> _getTotalDocumentsCount() async {
    final query = _buildFirestoreQuery();
    final snapshot = await query.count().get();
    return snapshot.count ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Column( // Ganti SingleChildScrollView utama dengan Column
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0), // Padding lebih besar untuk seluruh konten
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Verifikasi Laporan', // Judul yang lebih ringkas
                style: TextStyle(
                  fontSize: 28, // Ukuran font lebih besar untuk judul utama
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange, // Warna judul khusus untuk Verifikasi
                ),
              ),
              const SizedBox(height: 25), // Spasi lebih besar setelah judul

              // Bagian Filter dan Pencarian
              _buildFilterSearchSection(context),
              const SizedBox(height: 30), // Spasi setelah filter/pencarian
            ],
          ),
        ),

        // Bagian Tabel Data
        Expanded( // Memastikan tabel memenuhi sisa ruang yang tersedia
          child: StreamBuilder<QuerySnapshot>(
            stream: _buildFirestoreQuery().snapshots(), // Mendengarkan stream data
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.deepOrange)); // Tampilkan loading
              }
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
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, size: 50, color: Colors.grey),
                      SizedBox(height: 10),
                      Text(
                        'Tidak ada laporan monitoring yang ditemukan.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              final List<DocumentSnapshot> allDocuments = snapshot.data!.docs;

              // Filter data di sisi klien untuk pencarian teks
              final filteredDocuments = allDocuments.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final idVerifikasi = (data['id_verifikasi'] as String? ?? '').toLowerCase();
                final namaPetugas = (data['nama_petugas'] as String? ?? '').toLowerCase();
                final query = _searchQuery.toLowerCase();

                return idVerifikasi.contains(query) || namaPetugas.contains(query);
              }).toList();

              // Implementasi pagination di sisi klien
              final int startIndex = (_currentPage - 1) * _itemsPerPage;
              final int endIndex = startIndex + _itemsPerPage;
              final List<DocumentSnapshot> paginatedDocuments = filteredDocuments.sublist(
                startIndex.clamp(0, filteredDocuments.length),
                endIndex.clamp(0, filteredDocuments.length),
              );

              return _buildMonitoringTableSection(context, paginatedDocuments); // Teruskan data ke tabel
            },
          ),
        ),

        // Bagian Pagination (di luar StreamBuilder agar selalu terlihat)
        FutureBuilder<int>(
          future: _getTotalDocumentsCount(), // Hitung total dokumen
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.deepOrange),
              );
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return const SizedBox.shrink(); // Sembunyikan jika ada error
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
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Laporan Monitoring',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Cari ID Verifikasi / Nama Petugas',
                hintText: 'Masukkan ID atau nama petugas',
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
                  _currentPage = 1; // Reset halaman saat pencarian berubah
                });
              },
            ),
            const SizedBox(height: 15),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return Row(
                    children: [
                      Expanded(
                        child: _buildDropdownFilter(
                          labelText: 'Lokasi',
                          value: _selectedLokasiFilter,
                          items: const ['Sumatera Barat', 'Jawa Barat', 'DKI Jakarta', 'Sumatera Utara'], // Sesuaikan lokasi
                          onChanged: (value) {
                            setState(() {
                              _selectedLokasiFilter = value;
                              _currentPage = 1; // Reset halaman saat filter berubah
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildDropdownFilter(
                          labelText: 'Status Verifikasi',
                          value: _selectedStatusFilter,
                          items: const ['Disetujui', 'Ditolak', 'Menunggu'], // Sesuaikan dengan nilai di Firestore
                          onChanged: (value) {
                            setState(() {
                              _selectedStatusFilter = value;
                              _currentPage = 1; // Reset halaman saat filter berubah
                            });
                          },
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildDropdownFilter(
                        labelText: 'Lokasi',
                        value: _selectedLokasiFilter,
                        items: const ['Sumatera Barat', 'Jawa Barat', 'DKI Jakarta', 'Sumatera Utara'],
                        onChanged: (value) {
                          setState(() {
                            _selectedLokasiFilter = value;
                            _currentPage = 1;
                          });
                        },
                      ),
                      const SizedBox(height: 15),
                      _buildDropdownFilter(
                        labelText: 'Status Verifikasi',
                        value: _selectedStatusFilter,
                        items: const ['Disetujui', 'Ditolak', 'Menunggu'],
                        onChanged: (value) {
                          setState(() {
                            _selectedStatusFilter = value;
                            _currentPage = 1;
                          });
                        },
                      ),
                    ],
                  );
                }
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
                      backgroundColor: Colors.deepOrange[700], // Warna tombol utama
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 3,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _selectedLokasiFilter = null;
                      _selectedStatusFilter = null;
                      _currentPage = 1; // Reset halaman
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
                      side: BorderSide(color: Colors.deepOrange.shade700!), // Warna border tombol reset
                    ),
                    elevation: 3,
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

  // --- Widget Bagian Tabel Data ---
  Widget _buildMonitoringTableSection(BuildContext context, List<DocumentSnapshot> data) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20.0), // Padding horizontal untuk Card tabel
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Text(
                'Daftar Laporan Monitoring',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 15),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox( // Tambahkan ConstrainedBox untuk lebar minimum tabel
                constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 60), // Lebar minimum agar tidak terlalu sempit
                child: DataTable(
                  headingRowColor: MaterialStateProperty.resolveWith((states) => Colors.deepOrange.shade100), // Warna header tabel
                  dataRowHeight: 60, // Tinggi baris data
                  columnSpacing: 25, // Spasi antar kolom
                  columns: const [
                    DataColumn(label: Text('No.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange))),
                    DataColumn(label: Text('ID Verifikasi', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange))),
                    DataColumn(label: Text('Petugas', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange))),
                    DataColumn(label: Text('Tanggal Kunjungan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange))),
                    DataColumn(label: Text('Lokasi', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange))),
                    DataColumn(label: Text('Status Verifikasi', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange))),
                    DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange))),
                  ],
                  rows: List<DataRow>.generate(
                    data.length, // Jumlah baris sesuai data dari Firestore
                    (index) {
                      final doc = data[index];
                      final item = doc.data() as Map<String, dynamic>; // Konversi ke Map
                      final String idVerifikasi = item['id_verifikasi'] ?? 'N/A';
                      final String namaPetugas = item['nama_petugas'] ?? 'N/A';
                      final Timestamp? timestamp = item['tanggal_kunjungan'] as Timestamp?;
                      final String tanggalKunjungan = timestamp != null
                          ? '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}'
                          : 'N/A';
                      final String lokasi = item['lokasi'] ?? 'N/A';
                      final String statusVerifikasi = item['status_verifikasi'] ?? 'N/A'; // Pastikan field 'status_verifikasi' ada

                      Color statusColor = Colors.grey;
                      Color statusBgColor = Colors.grey.withOpacity(0.1);
                      if (statusVerifikasi == 'Disetujui') {
                        statusColor = Colors.green.shade800!;
                        statusBgColor = Colors.green.withOpacity(0.1);
                      } else if (statusVerifikasi == 'Ditolak') {
                        statusColor = Colors.red.shade800!;
                        statusBgColor = Colors.red.withOpacity(0.1);
                      } else if (statusVerifikasi == 'Menunggu') {
                        statusColor = Colors.amber.shade800!;
                        statusBgColor = Colors.amber.withOpacity(0.1);
                      }

                      return DataRow(
                        cells: [
                          DataCell(Text('${(index + 1) + (_currentPage - 1) * _itemsPerPage}')), // Nomor urut yang benar
                          DataCell(Text(idVerifikasi)),
                          DataCell(Text(namaPetugas)),
                          DataCell(Text(tanggalKunjungan)),
                          DataCell(Text(lokasi)),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusBgColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                statusVerifikasi,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.info, color: Colors.blue),
                                  tooltip: 'Lihat Detail',
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Melihat detail laporan ${idVerifikasi}')),
                                    );
                                    // TODO: Navigasi ke halaman detail laporan
                                  },
                                ),
                                // Tambahkan tombol Aksi lain jika diperlukan, misal "Approve/Reject"
                                if (statusVerifikasi == 'Menunggu') // Contoh: Hanya tampilkan tombol ini jika status 'Menunggu'
                                  IconButton(
                                    icon: const Icon(Icons.check_circle, color: Colors.green),
                                    tooltip: 'Setujui',
                                    onPressed: () {
                                      _showApprovalDialog(context, doc.id, idVerifikasi, 'Disetujui');
                                    },
                                  ),
                                if (statusVerifikasi == 'Menunggu')
                                  IconButton(
                                    icon: const Icon(Icons.cancel, color: Colors.red),
                                    tooltip: 'Tolak',
                                    onPressed: () {
                                      _showApprovalDialog(context, doc.id, idVerifikasi, 'Ditolak');
                                    },
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  tooltip: 'Hapus Laporan',
                                  onPressed: () {
                                    _confirmDelete(context, doc.id, idVerifikasi);
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

  // Dialog konfirmasi setuju/tolak
  Future<void> _showApprovalDialog(BuildContext context, String docId, String idVerifikasi, String newStatus) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('$newStatus Laporan', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Apakah Anda yakin ingin $newStatus laporan verifikasi dengan ID "$idVerifikasi"?'),
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
                  await _firestore.collection('monitoring_lapangan').doc(docId).update({
                    'status_verifikasi': newStatus,
                    'last_updated': FieldValue.serverTimestamp(), // Tambahkan timestamp update
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Laporan ${idVerifikasi} berhasil di$newStatus!', style: const TextStyle(color: Colors.white)),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal $newStatus laporan: $e', style: const TextStyle(color: Colors.white)),
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


  // Dialog konfirmasi hapus (disesuaikan untuk laporan monitoring)
  Future<void> _confirmDelete(BuildContext context, String docId, String idVerifikasi) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus Laporan', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Apakah Anda yakin ingin menghapus laporan verifikasi dengan ID "$idVerifikasi"? Data yang dihapus tidak dapat dikembalikan.'),
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
                  await _firestore.collection('monitoring_lapangan').doc(docId).delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Laporan ${idVerifikasi} berhasil dihapus!', style: const TextStyle(color: Colors.white)),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus laporan: $e', style: const TextStyle(color: Colors.white)),
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
    if (totalPages <= 1 && _searchQuery.isEmpty && _selectedLokasiFilter == null && _selectedStatusFilter == null) {
      return const SizedBox.shrink(); // Sembunyikan pagination jika hanya ada 1 halaman dan tidak ada filter
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

  // Widget pembantu untuk tombol pagination
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