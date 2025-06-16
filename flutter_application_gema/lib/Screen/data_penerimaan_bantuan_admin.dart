import 'package:flutter/material.dart';

class DataPenerimaanBantuanAdminScreen extends StatelessWidget {
  const DataPenerimaanBantuanAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Penerima Bantuan Admin',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Placeholder untuk elemen filter/pencarian
            _buildFilterSearchPlaceholder(),
            const SizedBox(height: 20),
            // Placeholder untuk tabel data
            _buildDataTablePlaceholder(context),
            const SizedBox(height: 20),
            // Placeholder untuk navigasi halaman (pagination)
            _buildPaginationPlaceholder(),
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
                labelText: 'Cari berdasarkan nama/NIK',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 10),
            // Placeholder untuk dropdown filter
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Filter Provinsi',
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
                      labelText: 'Filter Status',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Terverifikasi',
                        child: Text('Terverifikasi'),
                      ),
                      DropdownMenuItem(
                        value: 'Belum Terverifikasi',
                        child: Text('Belum Terverifikasi'),
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

  Widget _buildDataTablePlaceholder(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('No.')),
            DataColumn(label: Text('NIK')),
            DataColumn(label: Text('Nama')),
            DataColumn(label: Text('Provinsi')),
            DataColumn(label: Text('Kabupaten/Kota')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Aksi')),
          ],
          rows: List<DataRow>.generate(
            5, // Jumlah baris contoh
            (index) => DataRow(
              cells: [
                DataCell(Text('${index + 1}')),
                DataCell(Text('1234567890${index}3')),
                DataCell(Text('Nama Penerima ${index + 1}')),
                DataCell(Text('Sumatera Barat')),
                DataCell(Text('Padang')),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          index % 2 == 0
                              ? Colors.green.withOpacity(0.2)
                              : Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      index % 2 == 0 ? 'Terverifikasi' : 'Pending',
                      style: TextStyle(
                        color: index % 2 == 0 ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, color: Colors.blue),
                        onPressed: () {
                          // Aksi lihat detail
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.amber),
                        onPressed: () {
                          // Aksi edit
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
