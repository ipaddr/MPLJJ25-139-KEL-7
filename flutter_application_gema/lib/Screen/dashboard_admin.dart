// lib/Screen/dashboard_admin.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_gema/Screen/data_penerimaan_bantuan_admin.dart';
import 'package:flutter_application_gema/Screen/verifikasi_monitoring_laporan_admin.dart'; // <<< IMPORT INI SUDAH BENAR (NAMA LAMA)

class DashboardAdminScreen extends StatelessWidget {
  const DashboardAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // SingleChildScrollView diperlukan di sini agar konten dashboard bisa discroll
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard Nasional',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Menggunakan LayoutBuilder untuk membuat Wrap lebih responsif
            LayoutBuilder(
              builder: (context, constraints) {
                // Tentukan lebar kartu berdasarkan lebar layar
                double cardWidth = (constraints.maxWidth / 2) - 8; // 2 kartu per baris dengan spasi
                if (constraints.maxWidth > 600) { // Untuk layar yang lebih lebar, 3 atau 4 kartu per baris
                  cardWidth = (constraints.maxWidth / 3) - 10; // Contoh 3 kartu per baris
                  if (constraints.maxWidth > 900) {
                    cardWidth = (constraints.maxWidth / 4) - 12; // Contoh 4 kartu per baris
                  }
                }
                
                return Wrap(
                  spacing: 16.0, // Spasi horizontal antar kartu
                  runSpacing: 16.0, // Spasi vertikal antar baris kartu
                  alignment: WrapAlignment.center, // Pusatkan kartu jika tidak penuh satu baris
                  children: [
                    // Kartu "Data Penerima Bantuan"
                    _buildCard(
                      context,
                      icon: Icons.description,
                      title: 'Data Penerima Bantuan',
                      cardWidth: cardWidth, // Teruskan lebar kartu
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DataPenerimaanBantuanAdminScreen(),
                          ),
                        );
                      },
                    ),
                    // Kartu "Verifikasi Monitoring Lapangan"
                    _buildCard(
                      context,
                      icon: Icons.laptop_windows,
                      title: 'Verifikasi Monitoring Lapangan', // <<< KEMBALIKAN JUDUL INI (JIKA PERNAH DIUBAH)
                      cardWidth: cardWidth, // Teruskan lebar kartu
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            // <<< BARIS INI YANG HARUS KEMBALI KE NAMA KELAS LAMA
                            builder: (context) => const VerifikasiMonitoringLaporanAdminScreen(),
                          ),
                        );
                      },
                    ),
                    // Kartu info ringkasan, gunakan lebar yang sama dengan kartu aksi untuk konsistensi atau tetap kecil
                    _buildInfoCard('Jumlah Keluarga', '1.250.000', Colors.blue, cardWidth),
                    _buildInfoCard('Jumlah Bantuan', '3.750.000', Colors.green, cardWidth),
                    _buildInfoCard('Bantuan Disalurkan', '1.000.000', Colors.orange, cardWidth),
                    _buildInfoCard('Verifikasi Lapangan', '10.000', Colors.red, cardWidth),
                  ],
                );
              }
            ),
            const SizedBox(height: 20),
            _buildSectionHeader('Grafik Cepat Hitung'),
            _buildChartPlaceholder(context, 'Grafik Bar'),
            const SizedBox(height: 20),
            _buildSectionHeader('Perkembangan Penerima Bantuan'),
            _buildChartPlaceholder(context, 'Grafik Garis'),
            const SizedBox(height: 20),
            _buildSectionHeader('Distribusi Provinsi'),
            _buildChartPlaceholder(context, 'Peta Indonesia'),
            const SizedBox(height: 20),
            _buildChartPlaceholder(context, 'Grafik Bar Lainnya'),
          ],
        ),
      ),
    );
  }

  // Fungsi pembangun kartu aksi (ubah parameter cardWidth)
  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required double cardWidth, // <<< TAMBAHKAN INI
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Container(
          width: cardWidth, // <<< GUNAKAN PARAMETER INI
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.green),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi pembangun kartu informasi ringkasan (ubah parameter cardWidth)
  Widget _buildInfoCard(String title, String value, Color color, double cardWidth) { // <<< TAMBAHKAN INI
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Container(
        width: cardWidth, // <<< GUNAKAN PARAMETER INI
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi pembangun header bagian (tidak berubah)
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Fungsi placeholder untuk grafik (tidak berubah)
  Widget _buildChartPlaceholder(BuildContext context, String chartType) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Container(
        width: double.infinity,
        height: 200,
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'Placeholder untuk $chartType',
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}