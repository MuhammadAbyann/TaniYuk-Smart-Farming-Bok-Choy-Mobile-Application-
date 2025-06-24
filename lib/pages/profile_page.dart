import 'package:flutter/material.dart';
import 'package:smartfarmingpakcoy_apps/api/api_client.dart';
import 'package:smartfarmingpakcoy_apps/pages/login_page.dart';
import 'package:smartfarmingpakcoy_apps/services/auth_service.dart';
import 'package:smartfarmingpakcoy_apps/models/user.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String email = "";
  String lokasiLahan = "";
  String jenisTanaman = "";
  String luasLahan = "";
  String lamaPanen = "";

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    print('[DEBUG] Masuk ke fetchProfile()');
    try {
      final data = await ApiClient.getUserProfile();

      setState(() {
        email = data.email;
        lokasiLahan = data.lokasiLahan ?? '';
        jenisTanaman = data.jenisTanaman ?? '';
        luasLahan = data.luasLahan ?? '';
        lamaPanen = data.lamaPanen ?? '';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat profil: $e')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  void editProfileDialog() {
    final lokasiController = TextEditingController(text: lokasiLahan);
    final jenisController = TextEditingController(text: jenisTanaman);
    final luasController = TextEditingController(text: luasLahan);
    final panenController = TextEditingController(text: lamaPanen);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Informasi Lahan'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: lokasiController, decoration: const InputDecoration(labelText: 'Lokasi Lahan')),
              TextField(controller: jenisController, decoration: const InputDecoration(labelText: 'Jenis Tanaman')),
              TextField(controller: luasController, decoration: const InputDecoration(labelText: 'Luas Lahan')),
              TextField(controller: panenController, decoration: const InputDecoration(labelText: 'Lama Panen')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              final success = await ApiClient.updateUserProfile(
                User(
                  email: email,
                  lokasiLahan: lokasiController.text,
                  jenisTanaman: jenisController.text,
                  luasLahan: luasController.text,
                  lamaPanen: panenController.text,
                ),
              );

              if (success) {
                await fetchProfile();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profil berhasil diperbarui')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gagal memperbarui profil')),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    await AuthService.logout();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  void showContactPopup() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Contact Us'),
        content: const Text('Admin Contacts:\n085216588735\n081297702262\n088901742261'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        backgroundColor: Colors.teal,
        // Menghapus tombol back kiri atas
        automaticallyImplyLeading: false, 
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: editProfileDialog),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.teal,
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(email, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),

              _buildInfoSection("Informasi Lahan", [
                _buildInfoRow(Icons.location_on, "Lokasi Lahan: $lokasiLahan"),
                _buildInfoRow(Icons.local_florist, "Jenis Tanaman: $jenisTanaman"),
                _buildInfoRow(Icons.square_foot, "Luas Lahan: $luasLahan"),
                _buildInfoRow(Icons.timer, "Lama Panen: $lamaPanen"),
              ]),

              const SizedBox(height: 20),

              _buildInfoSection("Lainnya", [
                _buildInfoRow(Icons.email, "Contact Us", onPressed: showContactPopup), // Menambahkan fungsi pop-up pada "Contact Us"
              ]),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text("Keluar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {VoidCallback? onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.teal),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: onPressed,
              child: Text(text),
            ),
          ),
        ],
      ),
    );
  }
}
