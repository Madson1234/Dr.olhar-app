import 'package:just_audio/just_audio.dart';

/// Envolve o pacote `just_audio` para tocar uma captura de ausculta gravada.
class AudioPlayerService {
  AudioPlayerService() : _player = AudioPlayer();

  final AudioPlayer _player;

  Stream<PlayerState> get estadoStream => _player.playerStateStream;
  Stream<Duration> get posicaoStream => _player.positionStream;
  Duration? get duracao => _player.duration;
  bool get tocando => _player.playing;

  Future<Duration?> carregar(String caminho) => _player.setFilePath(caminho);

  /// Toca a partir da posição atual — ou do início, se a última reprodução
  /// já tiver chegado ao fim.
  Future<void> tocar() async {
    if (_player.processingState == ProcessingState.completed) {
      await _player.seek(Duration.zero);
    }
    await _player.play();
  }

  Future<void> pausar() => _player.pause();

  Future<void> irParaInicio() => _player.seek(Duration.zero);

  Future<void> dispose() => _player.dispose();
}
