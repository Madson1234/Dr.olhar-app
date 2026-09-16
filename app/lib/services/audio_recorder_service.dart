import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

/// Envolve o pacote `record` para gravar áudio em WAV/PCM16, salvando o
/// arquivo no diretório privado de documentos do app.
///
/// O "estetoscópio digital" aqui é um sensor eletrônico que sai como
/// entrada de microfone USB-C padrão — não há SDK/protocolo proprietário,
/// então a captura é gravação de áudio comum via `record`.
class AudioRecorderService {
  AudioRecorderService() : _recorder = AudioRecorder();

  final AudioRecorder _recorder;
  static const _uuid = Uuid();

  /// Verifica (e solicita, se necessário) a permissão de microfone.
  Future<bool> temPermissao() => _recorder.hasPermission();

  Future<bool> isGravando() => _recorder.isRecording();

  /// Amplitude atual/máxima em dBFS, a cada [intervalo] — usada como
  /// aproximação de nível de sinal em tempo real (não é SNR acústico real,
  /// que exigiria estimativa de piso de ruído/análise espectral).
  Stream<Amplitude> streamAmplitude({Duration intervalo = const Duration(milliseconds: 100)}) {
    return _recorder.onAmplitudeChanged(intervalo);
  }

  Future<String> iniciarGravacao({String? prefixoArquivo}) async {
    final permitido = await _recorder.hasPermission();
    if (!permitido) {
      throw const AudioRecorderPermissionException();
    }

    final dir = await getApplicationDocumentsDirectory();
    final capturasDir = Directory(p.join(dir.path, 'capturas'));
    if (!await capturasDir.exists()) {
      await capturasDir.create(recursive: true);
    }
    final prefixo = prefixoArquivo != null ? '${prefixoArquivo}_' : '';
    final nomeArquivo = '$prefixo${_uuid.v4()}.wav';
    final caminho = p.join(capturasDir.path, nomeArquivo);

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.wav),
      path: caminho,
    );

    return caminho;
  }

  /// Retorna o caminho do arquivo gravado, ou null se nada estava gravando.
  Future<String?> pararGravacao() => _recorder.stop();

  /// Descarta uma gravação (refazer / interrupção manual): para o gravador
  /// e apaga o arquivo parcial, se algum tiver sido criado.
  Future<void> descartarGravacao() async {
    final caminho = await _recorder.stop();
    if (caminho == null) return;
    final arquivo = File(caminho);
    if (await arquivo.exists()) {
      await arquivo.delete();
    }
  }

  void dispose() {
    _recorder.dispose();
  }
}

class AudioRecorderPermissionException implements Exception {
  const AudioRecorderPermissionException();

  @override
  String toString() => 'Permissão de microfone negada';
}
