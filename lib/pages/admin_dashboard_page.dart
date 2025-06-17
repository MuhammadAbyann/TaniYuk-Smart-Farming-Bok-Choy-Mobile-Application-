import 'package:flutter/material.dart';
import 'package:smartfarmingpakcoy_apps/api/api_client.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  List users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final response = await ApiClient.get('/api/admin/users');
      setState(() {
        users = response;
      });
    } catch (e) {
      print("Error loading users: $e");
    }
  }

  Future<void> resetPassword(String id) async {
    await ApiClient.put('/api/admin/users/$id/reset-password', {});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password direset ke pakcoy123')));
  }

  Future<void> deleteUser(String id) async {
    await ApiClient.delete('/api/admin/users/$id');
    fetchUsers();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User dihapus')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (_, i) {
          final u = users[i];
          return ListTile(
            title: Text(u['email']),
            subtitle: Text("Role: ${u['role']}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.restart_alt), onPressed: () => resetPassword(u['_id'])),
                IconButton(icon: const Icon(Icons.delete), onPressed: () => deleteUser(u['_id'])),
              ],
            ),
          );
        },
      ),
    );
  }
}
