import 'package:flutter/material.dart';

class StatistikLaporanAdminScreen extends StatelessWidget {
  const StatistikLaporanAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistik Laporan Admin',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16.0,
              runSpacing: 16.0,
              children: [
                _buildStatCard('Jumlah Penerima', '1.250.000', Colors.green),
                _buildStatCard('Jumlah Bantuan', '3.750.000', Colors.blue),
                _buildStatCard(
                  'Bantuan Disalurkan',
                  '3.000.000',
                  Colors.orange,
                ),
                _buildStatCard('Sisa Bantuan', '750.000', Colors.red),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionHeader('Distribusi Bantuan per Provinsi'),
            _buildChartPlaceholder(context, 'Grafik Bar (Provinsi)'),
            const SizedBox(height: 20),
            _buildSectionHeader('Status Verifikasi Lapangan'),
            _buildChartPlaceholder(context, 'Grafik Donat (Verifikasi)'),
            const SizedBox(height: 20),
            _buildSectionHeader('Tren Pengeluaran Bantuan'),
            _buildChartPlaceholder(context, 'Grafik Garis (Pengeluaran)'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Container(
        width: 180, // Lebar kartu statistik
        padding: const EdgeInsets.all(20.0),
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
                fontSize: 20,
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
