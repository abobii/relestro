import 'package:flutter/material.dart';
import '../../models/lab_assistant.dart';
import '../../utils/color_palette.dart';

class LabAssistantWidget extends StatefulWidget {
  final LabAssistant assistant;
  final VoidCallback? onTap;

  const LabAssistantWidget({
    super.key,
    required this.assistant,
    this.onTap,
  });

  @override
  State<LabAssistantWidget> createState() => _LabAssistantWidgetState();
}

class _LabAssistantWidgetState extends State<LabAssistantWidget> {
  String _currentPhrase = '';

  @override
  void initState() {
    super.initState();
    _currentPhrase = widget.assistant.nextPhrase;
  }

  void _handleTap() {
    setState(() {
      _currentPhrase = widget.assistant.nextPhrase;
    });
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary),
        ),
        child: Row(
          children: [
            // Изображение лаборанта
            _buildAssistantImage(),
            
            const SizedBox(width: 12),
            
            // Текстовая информация
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.assistant.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentPhrase,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssistantImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: ClipOval(
        child: widget.assistant.imagePath.isNotEmpty
            ? Image.asset(
                widget.assistant.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('❌ Ошибка загрузки изображения: $error');
                  return _buildPlaceholderIcon();
                },
              )
            : _buildPlaceholderIcon(),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      color: AppColors.primary.withOpacity(0.2),
      child: const Icon(
        Icons.person,
        color: AppColors.primary,
        size: 30,
      ),
    );
  }
}