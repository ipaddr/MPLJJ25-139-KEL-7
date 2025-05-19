import 'package:flutter/material.dart';

class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 200,
            color: Colors.grey[300],
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'GEMA',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                const SizedBox(height: 10),
                const Icon(Icons.access_time),
                const Text("00:00"),
                const Text("XX/XX/XX"),
                const SizedBox(height: 20),
                SidebarButton(icon: Icons.dashboard, label: "Beranda"),
                SidebarButton(icon: Icons.people, label: "Program saya"),
                SidebarButton(icon: Icons.send, label: "Ajukan Program"),
                SidebarButton(icon: Icons.help_outline, label: "Bantuan"),
                SidebarButton(icon: Icons.logout, label: "Log Out"),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Bar
                Container(
                  color: Colors.grey[200],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Indonesia, Sumatera Barat, Padang"),
                      Row(
                        children: [
                          const Icon(Icons.person),
                          const SizedBox(width: 8),
                          Container(
                            width: 100,
                            height: 30,
                            color: Colors.yellow,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.person, color: Colors.green),
                                SizedBox(width: 4),
                                Text("Nama Akun"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Grid Menu
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: const [
                        MenuCard(icon: Icons.dashboard, label: "BERANDA"),
                        MenuCard(icon: Icons.groups, label: "Program saya"),
                        MenuCard(icon: Icons.send, label: "Ajukan Program"),
                        MenuCard(icon: Icons.help, label: "Bantuan"),
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

class SidebarButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const SidebarButton({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      onTap: () {
        // Aksi navigasi di sini
      },
    );
  }
}

class MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const MenuCard({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
