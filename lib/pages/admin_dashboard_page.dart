import 'package:flutter/material.dart';
import 'package:smartfarmingpakcoy_apps/api/api_client.dart';
import 'package:smartfarmingpakcoy_apps/pages/login_page.dart';
import 'package:smartfarmingpakcoy_apps/services/auth_service.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  List users = [];
  List notifications = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
    fetchNotifications();
  }

  Future<void> fetchUsers() async {
    try {
      final response = await ApiClient.get('/api/admin/users');
      setState(() => users = response);
    } catch (e) {
      debugPrint("Error loading users: $e");
    }
  }

  Future<void> fetchNotifications() async {
    try {
      final res = await ApiClient.get('/api/admin/notifications');
      setState(() => notifications = res);
    } catch (e) {
      debugPrint("Error loading notifications: $e");
    }
  }

  Future<void> resetPassword(String id) async {
    await ApiClient.put('/api/admin/users/$id/reset-password', {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password direset ke pakcoy123')),
    );
  }

  Future<void> deleteUser(String id) async {
    await ApiClient.delete('/api/admin/users/$id');
    await fetchUsers();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User dihapus')),
    );
  }

  Future<void> logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: logout,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh",
            onPressed: () {
              fetchUsers();
              fetchNotifications();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("👥 Daftar Pengguna",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (users.isEmpty)
              const Center(child: Text("Belum ada user"))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: users.length,
                itemBuilder: (_, i) {
                  final u = users[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(u['email']),
                      subtitle: Text("Role: ${u['role']}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.restart_alt),
                            tooltip: "Reset Password",
                            onPressed: () => resetPassword(u['_id']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            tooltip: "Hapus User",
                            onPressed: () => deleteUser(u['_id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            const Text("🔔 Notifikasi Lupa Password",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (notifications.isEmpty)
              const Text("Belum ada notifikasi"),
            for (var notif in notifications)
              ListTile(
                leading: const Icon(Icons.mail_outline),
                title: Text(notif['email']),
                subtitle: Text("Waktu: ${notif['time'] ?? '-'}"),
              )
          ],
        ),
      ),
    );
  }
}
