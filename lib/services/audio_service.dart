import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playSound(String path) async {
    try {
      await _player.play(AssetSource(path));
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  void dispose() {
    _player.dispose();
  }
}