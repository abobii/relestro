// lib/services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  // Регистрация
  Future<AppUser?> register(String username, String password, {String? image, int? age, int? gender}) async {
    try {
      // Проверяем, существует ли пользователь
      final existingUserResponse = await _client
          .from('users')
          .select()
          .eq('username', username);

      if (existingUserResponse.isNotEmpty) {
        throw Exception('Пользователь с таким именем уже существует');
      }

      // Создаем нового пользователя
      final response = await _client
          .from('users')
          .insert({
            'username': username,
            'password': password,
            'image': image,
            'age': age,
            'gender': gender,
          })
          .select()
          .single();

      _currentUser = AppUser.fromJson(response);
      return _currentUser;
    } catch (e) {
      throw Exception('Ошибка регистрации: $e');
    }
  }

  // Вход
  Future<AppUser?> login(String username, String password) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('username', username)
          .eq('password', password)
          .single();

      _currentUser = AppUser.fromJson(response);
      return _currentUser;
    } catch (e) {
      throw Exception('Неверное имя пользователя или пароль');
    }
  }

  // Выход
  void logout() {
    _currentUser = null;
  }

  // Проверка авторизации
  bool get isLoggedIn => _currentUser != null;
}