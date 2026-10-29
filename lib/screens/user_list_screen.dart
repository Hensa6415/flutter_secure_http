import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../widgets/user_card.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<User> _allUsers = [];
  List<User> _filteredUsers = [];
  
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedTimeoutSeconds = 10; // Latihan 5: Parameter Timeout

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final users = await _apiService.getUsers(
        timeout: Duration(seconds: _selectedTimeoutSeconds),
      );
      setState(() {
        _allUsers = users;
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Latihan 4: Real-time search filter
  void _filterUsers(String query) {
    setState(() {
      _filteredUsers = _allUsers
          .where((user) =>
              user.name.toLowerCase().contains(query.toLowerCase()) ||
              user.email.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengguna'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          // Dropdown Latihan 5 untuk ubah timeout
          PopupMenuButton<int>(
            icon: const Icon(Icons.timer),
            tooltip: 'Ubah Duration Timeout',
            onSelected: (seconds) {
              setState(() => _selectedTimeoutSeconds = seconds);
              _loadUsers();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 1, child: Text('Timeout 1 Detik (Tes Timeout)')),
              const PopupMenuItem(value: 5, child: Text('Timeout 5 Detik')),
              const PopupMenuItem(value: 10, child: Text('Timeout 10 Detik (Default)')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Latihan 4: Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterUsers,
              decoration: InputDecoration(
                hintText: 'Cari berdasarkan nama atau email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadUsers, child: const Text('Coba Lagi')),
            ],
          ),
        ),
      );
    }

    if (_filteredUsers.isEmpty) {
      return const Center(child: Text('Data pengguna tidak ditemukan'));
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        itemCount: _filteredUsers.length,
        itemBuilder: (context, index) {
          final user = _filteredUsers[index];
          return UserCard(user: user);
        },
      ),
    );
  }
}