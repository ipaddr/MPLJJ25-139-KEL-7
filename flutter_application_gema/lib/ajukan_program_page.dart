import 'package:flutter/material.dart';

class ProgramSayaPage extends StatelessWidget {
  const ProgramSayaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajukan Program')),
      body: const Center(child: Text('Halaman Ajukan Program')),
    );
  }
}

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
              Icon(Icons.eco, size: 48, color: Colors.green.shade700),
              const SizedBox(height: 8),
              const Text("GEMA", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Icon(Icons.access_time, size: 16),
              const SizedBox(height: 4),
              const Text("00:00"),
              const Text("XX/XX/XX"),
              const SizedBox(height: 20),
              const Divider(),
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
                        const Icon(Icons.person),
                        const SizedBox(width: 8),
                        Container(
                          width: 100,
                          height: 24,
                          color: Colors.yellow.shade700,
                          alignment: Alignment.center,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person, size: 16),
                              SizedBox(width: 4),
                              Text("Nama Akun", style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Text(
                  "PROGRAM SAYA",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              // Informasi Program Saya
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Nama Usaha :", style: TextStyle(fontSize: 14)),
                    SizedBox(height: 4),
                    Text("Status :", style: TextStyle(fontSize: 14)),
                    SizedBox(height: 4),
                    Text("Deskripsi Usaha:", style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "PROGRAM YANG TERSEDIA :",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              // Program yang Tersedia
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(""),
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
