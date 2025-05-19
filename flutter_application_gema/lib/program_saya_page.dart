import 'package:flutter/material.dart';

class ProgramSayaPage extends StatelessWidget {
  const ProgramSayaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar kiri
          Container(
            width: 180,
            color: Colors.grey.shade300,
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo + GEMA
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.eco, size: 36),
                      const SizedBox(height: 4),
                      const Text(
                        "GEMA",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // Time + Date
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, size: 16),
                      SizedBox(width: 4),
                      Text("00:00"),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16),
                      SizedBox(width: 4),
                      Text("XX/XX/XX"),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Menu
                menuItem(Icons.home, "Beranda"),
                menuItem(Icons.people, "Program saya"),
                menuItem(Icons.send, "Ajukan Program"),
                menuItem(Icons.help, "Bantuan"),
                menuItem(Icons.logout, "Log Out"),
              ],
            ),
          ),

          // Konten utama
          Expanded(
            child: Column(
              children: [
                // Header atas
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
                          const Icon(Icons.account_circle, size: 28),
                          const SizedBox(width: 8),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Nama Akun",
                                style: TextStyle(fontSize: 12),
                              ),
                              Container(
                                width: 60,
                                height: 15,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Konten tengah
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: ListView(
                      children: [
                        const Text(
                          "PROGRAM SAYA",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Info Usaha
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Nama Usaha :",
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 8),
                              Text("Status :", style: TextStyle(fontSize: 16)),
                              SizedBox(height: 8),
                              Text(
                                "Deskripsi Usaha:",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        const Text(
                          "PROGRAM YANG TERSEDIA :",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Box Program Tersedia
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ],
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
}

// Widget untuk menu sidebar
Widget menuItem(IconData icon, String label) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    child: Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    ),
  );
}
