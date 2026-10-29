import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/post.dart';

class ApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  // Latihan 5: Configurable Timeout (default 10 detik)
  Future<List<User>> getUsers({Duration timeout = const Duration(seconds: 10)}) async {
    try {
      print('Request GET: $_baseUrl/users (Timeout: ${timeout.inSeconds}s)');
      final response = await http
          .get(Uri.parse('$_baseUrl/users'))
          .timeout(timeout);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat data. Status: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Request timeout (${timeout.inSeconds}s). Periksa koneksi internet Anda.');
    } on SocketException {
      throw Exception('Tidak ada koneksi internet.');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Latihan 3: Method GET /posts
  Future<List<Post>> getPosts() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/posts'))
          .timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat posts.');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<String> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email.isNotEmpty && password.isNotEmpty) {
      return 'dummy_token_${DateTime.now().millisecondsSinceEpoch}';
    } else {
      throw Exception('Email dan password tidak boleh kosong');
    }
  }
}