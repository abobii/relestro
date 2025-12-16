// lib/screens/chat_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'auth_screen.dart';

class ChatScreen extends StatefulWidget {
  final AppUser user;

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  Timer? _refreshTimer;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      _fetchMessages();
    });
  }

  Future<void> _fetchMessages() async {
    try {
      // Получаем сообщения без связи с таблицей users
      final response = await Supabase.instance.client
          .from('messages')
          .select()
          .order('created_at', ascending: true);

      if (mounted) {
        setState(() {
          _messages = List<Map<String, dynamic>>.from(response);
        });
        
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      }
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }

  Future<void> _addMessage() async {
    if (_textController.text.isEmpty) {
      _showError('Введите сообщение');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Сохраняем username прямо в таблице messages
      await Supabase.instance.client.from('messages').insert({
        'username': widget.user.username, // Сохраняем имя пользователя напрямую
        'text': _textController.text,
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'user_id': widget.user.id, // Сохраняем ID пользователя
      });

      _textController.clear();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сообщение отправлено!')),
      );
    } catch (e) {
      _showError('Ошибка отправки: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _isMyMessage(Map<String, dynamic> message) {
    // Проверяем по username или user_id
    final messageUsername = message['username']?.toString();
    final messageUserId = message['user_id'];
    
    return messageUsername == widget.user.username || 
           messageUserId == widget.user.id;
  }

  Future<void> _deleteMessage(String messageId) async {
    try {
      await Supabase.instance.client
          .from('messages')
          .delete()
          .eq('id', messageId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Сообщение удалено'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      _showError('Ошибка удаления: $e');
    }
  }

  void _showDeleteDialog(Map<String, dynamic> message) {
    if (!_isMyMessage(message)) return;
    
    final messageId = message['id']?.toString();
    final messageText = message['text']?.toString() ?? 'это сообщение';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Удалить сообщение?'),
          content: Text('Вы уверены, что хотите удалить "$messageText"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (messageId != null) {
                  _deleteMessage(messageId);
                }
              },
              child: const Text(
                'Удалить',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _logout() {
    _authService.logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return 'только что';
    try {
      final dateTime = DateTime.parse(timestamp.toString());
      final localTime = dateTime.toLocal();
      return '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'только что';
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Чат - ${widget.user.username}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Выйти',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading && _messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Нет сообщений',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          // Получаем username напрямую из сообщения
                          final username = message['username']?.toString() ?? 'Аноним';
                          final isMyMessage = _isMyMessage(message);
                          
                          return GestureDetector(
                            onLongPress: () => _showDeleteDialog(message),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: isMyMessage ? Colors.green : Colors.blue,
                                    radius: 20,
                                    child: Text(
                                      username.isNotEmpty ? username[0].toUpperCase() : '?',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isMyMessage ? Colors.green.shade50 : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                username,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: isMyMessage ? Colors.green : Colors.blue,
                                                ),
                                              ),
                                              if (isMyMessage) ...[
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green.shade200,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: const Text(
                                                    'Вы',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(message['text']?.toString() ?? 'Нет текста'),
                                          const SizedBox(height: 4),
                                          Text(
                                            _formatTime(message['created_at']),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Введите сообщение...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isLoading ? null : _addMessage,
                  icon: const Icon(Icons.send, color: Colors.blue),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue.shade50,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}