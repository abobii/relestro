import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/color_palette.dart';
import '../../services/theme_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final bool _darkMode = themeManager.isDark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Звук
            Card(
              child: SwitchListTile(
                title: const Text('Звуковые эффекты'),
                subtitle: const Text('Включить звуки реакций и взаимодействий'),
                value: _soundEnabled,
                onChanged: (value) {
                  setState(() {
                    _soundEnabled = value;
                  });
                  _showSoundInfo(value);
                },
                secondary: const Icon(Icons.volume_up),
              ),
            ),

            const SizedBox(height: 12),

            // Темная тема
            Card(
              child: SwitchListTile(
                title: const Text('Темная тема'),
                subtitle: const Text('Включить темное оформление приложения'),
                value: _darkMode,
                onChanged: (value) {
                  themeManager.toggleTheme(value);
                  _showThemeInfo(value);
                },
                secondary: Icon(
                  _darkMode ? Icons.dark_mode : Icons.light_mode,
                  color: _darkMode ? Colors.amber : Colors.blue,
                ),
              ),
            ),

            const SizedBox(height: 12),


            // Информация о приложении
            Card(
              child: ListTile(
                leading: const Icon(Icons.info, color: Colors.blue),
                title: const Text('О приложении'),
                subtitle: const Text('Версия 1.0.0'),
                onTap: _showAboutDialog,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSoundInfo(bool enabled) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          enabled 
            ? '🔊 Звуковые эффекты включены' 
            : '🔇 Звуковые эффекты выключены',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showThemeInfo(bool darkMode) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          darkMode 
            ? '🌙 Темная тема включена' 
            : '☀️ Светлая тема включена',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: darkMode ? Colors.grey[800] : Colors.blue,
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('О приложении'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🧪 Химический симулятор'),
            SizedBox(height: 8),
            Text('Версия: 1.0.0'),
            SizedBox(height: 8),
            Text('Дипломный проект'),
            SizedBox(height: 8),
            Text('Образовательное приложение для изучения химических реакций'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}