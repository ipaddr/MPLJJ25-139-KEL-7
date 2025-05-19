import 'package:flutter/material.dart';

class BantuanPage extends StatelessWidget {
  const BantuanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 180,
            color: Colors.grey.shade300,
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Logo dan jam
                Column(
                  children: [
                    Icon(Icons.eco, size: 48, color: Colors.green.shade700),
                    const SizedBox(height: 8),
                    const Text(
                      "GEMA",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Icon(Icons.access_time, size: 16),
                    const SizedBox(height: 4),
                    const Text("00:00"),
                    const Text("XX/XX/XX"),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                // Menu Sidebar
                sidebarItem(Icons.home, "Beranda"),
                sidebarItem(Icons.assignment, "Program saya"),
                sidebarItem(Icons.send, "Ajukan Program"),
                sidebarItem(Icons.help, "Bantuan"),
                sidebarItem(Icons.logout, "Log Out"),
              ],
            ),
          ),

          // Konten Utama
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  height: 60,
                  color: Colors.grey.shade400,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Indonesia, Sumatera Barat, Padang",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 24),
                          const SizedBox(width: 8),
                          Container(
                            width: 80,
                            height: 20,
                            color: Colors.grey,
                            alignment: Alignment.center,
                            child: const Text(
                              "Nama Akun",
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Konten Bantuan
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Pusat Bantuan Informasi",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Halaman ini menyediakan informasi dan panduan untuk membantu pengguna\nmemahami cara menggunakan platform GEMA serta menyelesaikan masalah\nyang umum terjadi.",
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 24),

                          const Text(
                            "FAQ (Pertanyaaan yang Sering Diajukan)",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text("• Bagaimana cara mengajukan program?"),
                          const Text("• Apa syarat verifikasi data?"),
                          const Text(
                            "• Bagaimana mengecek status program saya?",
                          ),

                          const SizedBox(height: 32),
                          const Text(
                            "Data anda akan dijaga kerahasiaannya sesuai kebijakan privasi platform GEMA",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget sidebarItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        children: [Icon(icon, size: 18), const SizedBox(width: 8), Text(label)],
      ),
    );
  }
}
