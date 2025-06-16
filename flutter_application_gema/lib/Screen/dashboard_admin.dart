import 'package:flutter/material.dart';
import 'package:flutter_application_gema/Screen/data_penerimaan_bantuan_admin.dart'; // Impor Data Penerimaan Bantuan Admin untuk navigasi
import 'package:flutter_application_gema/Screen/verifikasi_monitoring_laporan_admin.dart'; // Impor Verifikasi Monitoring Laporan Admin untuk navigasi

class DashboardAdminScreen extends StatelessWidget {
  const DashboardAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            Wrap(
              spacing: 16.0, // Spasi horizontal antar kartu
              runSpacing: 16.0, // Spasi vertikal antar baris kartu
              children: [
                // Kartu "Data Penerima Bantuan"
                _buildCard(
                  context,
                  icon: Icons.description,
                  title: 'Data Penerima Bantuan',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                const DataPenerimaanBantuanAdminScreen(),
                      ),
                    );
                  },
                ),
                // Kartu "Verifikasi Monitoring Lapangan"
                _buildCard(
                  context,
                  icon: Icons.laptop_windows,
                  title: 'Verifikasi Monitoring Lapangan',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                const VerifikasiMonitoringLaporanAdminScreen(),
                      ),
                    );
                  },
                ),
                // Tambahkan kartu lain sesuai gambar Dashboard Admin
                _buildInfoCard('Jumlah Keluarga', '1.250.000', Colors.blue),
                _buildInfoCard('Jumlah Bantuan', '3.750.000', Colors.green),
                _buildInfoCard(
                  'Bantuan Disalurkan',
                  '1.000.000',
                  Colors.orange,
                ),
                _buildInfoCard('Verifikasi Lapangan', '10.000', Colors.red),
              ],
            ),
            const SizedBox(height: 20),
            // Placeholder untuk Grafik Cepat Hitung
            _buildSectionHeader('Grafik Cepat Hitung'),
            _buildChartPlaceholder(context, 'Grafik Bar'),
            const SizedBox(height: 20),
            // Placeholder untuk Perkembangan Penerima Bantuan
            _buildSectionHeader('Perkembangan Penerima Bantuan'),
            _buildChartPlaceholder(context, 'Grafik Garis'),
            const SizedBox(height: 20),
            // Placeholder untuk Distribusi Provinsi
            _buildSectionHeader('Distribusi Provinsi'),
            _buildChartPlaceholder(context, 'Peta Indonesia'),
            const SizedBox(height: 20),
            // Placeholder untuk Grafik Bar Tambahan
            _buildChartPlaceholder(context, 'Grafik Bar Lainnya'),
          ],
        ),
      ),
    );
  }

  // Fungsi pembangun kartu aksi
  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String title,
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
          width:
              MediaQuery.of(context).size.width > 700
                  ? MediaQuery.of(context).size.width *
                      0.25 // Lebar lebih besar di layar desktop
                  : MediaQuery.of(context).size.width * 0.4, // Lebar responsif
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

  // Fungsi pembangun kartu informasi ringkasan
  Widget _buildInfoCard(String title, String value, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Container(
        width: 150, // Ukuran tetap untuk kartu info kecil
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

  // Fungsi pembangun header bagian
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Fungsi placeholder untuk grafik
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
