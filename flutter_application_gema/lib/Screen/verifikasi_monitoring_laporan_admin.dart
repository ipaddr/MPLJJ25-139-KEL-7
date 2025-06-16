import 'package:flutter/material.dart';

class VerifikasiMonitoringLaporanAdminScreen extends StatelessWidget {
  const VerifikasiMonitoringLaporanAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verifikasi Monitoring Lapangan Admin',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildFilterSearchPlaceholder(), // Menggunakan filter yang sama
            const SizedBox(height: 20),
            _buildMonitoringTablePlaceholder(
              context,
            ), // Tabel khusus untuk monitoring
            const SizedBox(height: 20),
            _buildPaginationPlaceholder(), // Pagination yang sama
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSearchPlaceholder() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter dan Pencarian',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'Cari berdasarkan ID Verifikasi/Nama Petugas',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Filter Lokasi',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Sumatera Barat',
                        child: Text('Sumatera Barat'),
                      ),
                      DropdownMenuItem(
                        value: 'Jawa Barat',
                        child: Text('Jawa Barat'),
                      ),
                    ],
                    onChanged: (value) {},
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Filter Status Verifikasi',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Disetujui',
                        child: Text('Disetujui'),
                      ),
                      DropdownMenuItem(
                        value: 'Ditolak',
                        child: Text('Ditolak'),
                      ),
                      DropdownMenuItem(
                        value: 'Menunggu',
                        child: Text('Menunggu'),
                      ),
                    ],
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonitoringTablePlaceholder(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('No.')),
            DataColumn(label: Text('ID Verifikasi')),
            DataColumn(label: Text('Petugas')),
            DataColumn(label: Text('Tanggal Kunjungan')),
            DataColumn(label: Text('Lokasi')),
            DataColumn(label: Text('Status Verifikasi')),
            DataColumn(label: Text('Aksi')),
          ],
          rows: List<DataRow>.generate(
            5, // Jumlah baris contoh
            (index) => DataRow(
              cells: [
                DataCell(Text('${index + 1}')),
                DataCell(Text('VER-${1000 + index}')),
                DataCell(Text('Petugas ${index + 1}')),
                DataCell(Text('2023-01-${10 + index}')),
                DataCell(Text('Kab. Padang')),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          index % 3 == 0
                              ? Colors.green.withOpacity(0.2)
                              : (index % 3 == 1
                                  ? Colors.red.withOpacity(0.2)
                                  : Colors.amber.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      index % 3 == 0
                          ? 'Disetujui'
                          : (index % 3 == 1 ? 'Ditolak' : 'Menunggu'),
                      style: TextStyle(
                        color:
                            index % 3 == 0
                                ? Colors.green
                                : (index % 3 == 1 ? Colors.red : Colors.amber),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.info, color: Colors.blue),
                        onPressed: () {
                          // Aksi lihat detail verifikasi
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationPlaceholder() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () {}),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(5),
          ),
          child: const Text('1', style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(width: 5),
        const Text('2', style: TextStyle(color: Colors.grey)),
        const SizedBox(width: 5),
        const Text('...', style: TextStyle(color: Colors.grey)),
        const SizedBox(width: 5),
        const Text('10', style: TextStyle(color: Colors.grey)),
        IconButton(icon: const Icon(Icons.arrow_forward_ios), onPressed: () {}),
      ],
    );
  }
}
