import 'package:flutter/material.dart';
import 'package:smartfarmingpakcoy_apps/api/api_client.dart';
import 'package:smartfarmingpakcoy_apps/pages/login_page.dart';
import 'package:smartfarmingpakcoy_apps/pages/home_page.dart';
import 'package:smartfarmingpakcoy_apps/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  String token = "";

  @override
  void initState() {
    super.initState();
    fetchTokenAndProfile();
  }

  Future<void> fetchTokenAndProfile() async {
    final token = await AuthService.getToken() ?? '';

    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token tidak ditemukan. Silakan login ulang.')),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
      return;
    }

    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      final data = await ApiClient.getUserProfile(token);

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
                token: token,
                user: User(
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
          },
        ),
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
                _buildInfoRow(Icons.email, "Contact Us"),
                _buildInfoRow(Icons.privacy_tip, "Privacy Policy"),
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.teal),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
