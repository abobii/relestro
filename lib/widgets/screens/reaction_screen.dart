import 'package:flutter/material.dart';
import '../../models/chemical_reaction.dart';
import '../../models/substance.dart';
import '../../models/reaction_result.dart';
import '../../services/reaction_service.dart';
import '../../utils/color_palette.dart';
import '../common/animated_button.dart';
import '../common/progress_bar.dart';
import '../particles/reaction_effect.dart';

class ReactionScreen extends StatefulWidget {
  final ChemicalReaction reaction;
  final Map<String, double> inputMasses;
  final List<Substance> allSubstances;
  final Function(ReactionResult) onReactionComplete;

  const ReactionScreen({
    super.key,
    required this.reaction,
    required this.inputMasses,
    required this.allSubstances,
    required this.onReactionComplete,
  });

  @override
  State<ReactionScreen> createState() => _ReactionScreenState();
}

class _ReactionScreenState extends State<ReactionScreen> with SingleTickerProviderStateMixin {
  final ReactionService _reactionService = ReactionService();
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  ReactionResult? _reactionResult;
  bool _showReactionEffect = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _startReaction();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startReaction() {
    _animationController.forward().then((_) {
      setState(() {
        _showReactionEffect = true;
      });
      
      Future.delayed(const Duration(seconds: 1), () {
        final result = _reactionService.performReaction(
          reaction: widget.reaction,
          inputMasses: widget.inputMasses,
          allSubstances: widget.allSubstances,
        );
        
        setState(() {
          _reactionResult = result;
        });
        
        widget.onReactionComplete(result);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Процесс реакции'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Уравнение реакции
                _buildReactionEquation(),
                
                const SizedBox(height: 20),
                
                // Прогресс реакции
                _buildReactionProgress(),
                
                const SizedBox(height: 20),
                
                // Результат реакции
                if (_reactionResult != null) _buildReactionResult(),
                
                const Spacer(),
                
                // Кнопка закрытия
                if (_reactionResult != null) _buildCloseButton(),
              ],
            ),
          ),
          
          // Эффект реакции
          if (_showReactionEffect) const ReactionEffect(),
        ],
      ),
    );
  }

  Widget _buildReactionEquation() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Уравнение реакции:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.reaction.reactionString,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionProgress() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ход реакции:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return ProgressBar(
                  progress: _progressAnimation.value,
                  height: 12,
                  label: '${(_progressAnimation.value * 100).toInt()}%',
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              _getProgressText(_progressAnimation.value),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionResult() {
    final result = _reactionResult!;
    
    return Card(
      color: result.success ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  result.success ? Icons.check_circle : Icons.error,
                  color: result.success ? AppColors.success : AppColors.error,
                ),
                const SizedBox(width: 8),
                Text(
                  result.success ? 'Реакция успешна!' : 'Ошибка реакции',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: result.success ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(result.message),
            
            if (result.success) ...[
              const SizedBox(height: 16),
              
              const Text(
                'Продукты реакции:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              
              const SizedBox(height: 8),
              
              ...result.productMasses.entries.map((entry) => 
                Text('• ${entry.key}: ${entry.value} г')
              ),
              
              if (result.limitingReagent != null) ...[
                const SizedBox(height: 8),
                Text('Лимитирующий реагент: ${result.limitingReagent}'),
              ],
              
              if (result.efficiency < 0.9) ...[
                const SizedBox(height: 8),
                Text(
                  'Эффективность: ${(result.efficiency * 100).toInt()}%',
                  style: const TextStyle(color: Colors.orange),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return AnimatedButton(
      onPressed: () => Navigator.pop(context),
      child: const Text(
        'Завершить',
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }

  String _getProgressText(double progress) {
    if (progress < 0.3) return 'Подготовка реагентов...';
    if (progress < 0.6) return 'Нагрев смеси...';
    if (progress < 0.9) return 'Протекание реакции...';
    return 'Завершение процесса...';
  }
}