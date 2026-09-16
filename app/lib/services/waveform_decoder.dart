import 'dart:io';
import 'dart:typed_data';

/// Resultado da decodificação de um arquivo WAV PCM16 mono/estéreo.
class WaveformData {
  const WaveformData({
    required this.amostras,
    required this.sampleRate,
    required this.duracao,
  });

  /// Amplitudes normalizadas entre 0.0 e 1.0 (pico por bloco), já
  /// reduzidas (downsample) para um número de pontos adequado ao desenho.
  final List<double> amostras;
  final int sampleRate;
  final Duration duracao;
}

/// Lê um arquivo WAV (formato PCM linear, 16 bits) e extrai as amostras de
/// áudio para desenhar a forma de onda, sem depender de bibliotecas de DSP.
class WaveformDecoder {
  const WaveformDecoder({this.pontosAlvo = 46});

  /// Quantidade aproximada de pontos que a forma de onda final deve ter
  /// (46 casa com as barras da tela de revisão do design).
  final int pontosAlvo;

  Future<WaveformData> decodificarArquivo(String caminho) async {
    final bytes = await File(caminho).readAsBytes();
    return decodificarBytes(bytes);
  }

  WaveformData decodificarBytes(Uint8List bytes) {
    final byteData = ByteData.sublistView(bytes);
    if (bytes.length < 44 ||
        _tag(byteData, 0) != 'RIFF' ||
        _tag(byteData, 8) != 'WAVE') {
      throw const FormatException('Arquivo não é um WAV válido');
    }

    var sampleRate = 44100;
    var numChannels = 1;
    var bitsPerSample = 16;
    var offset = 12;
    int? dataOffset;
    int? dataLength;

    while (offset + 8 <= bytes.length) {
      final chunkId = _tag(byteData, offset);
      final chunkSize = byteData.getUint32(offset + 4, Endian.little);
      final chunkDataStart = offset + 8;

      if (chunkId == 'fmt ') {
        numChannels = byteData.getUint16(chunkDataStart + 2, Endian.little);
        sampleRate = byteData.getUint32(chunkDataStart + 4, Endian.little);
        bitsPerSample = byteData.getUint16(chunkDataStart + 14, Endian.little);
      } else if (chunkId == 'data') {
        dataOffset = chunkDataStart;
        dataLength = chunkSize;
      }

      offset = chunkDataStart + chunkSize + (chunkSize.isOdd ? 1 : 0);
    }

    if (dataOffset == null || dataLength == null || bitsPerSample != 16) {
      throw const FormatException('WAV sem chunk "data" PCM16 legível');
    }

    final dataEnd = (dataOffset + dataLength).clamp(0, bytes.length);
    final totalSamples = (dataEnd - dataOffset) ~/ (2 * numChannels);
    final duracao = Duration(
      microseconds: sampleRate == 0 ? 0 : (totalSamples * 1000000) ~/ sampleRate,
    );

    if (totalSamples <= 0) {
      return WaveformData(amostras: const [], sampleRate: sampleRate, duracao: duracao);
    }

    final blockSize = (totalSamples / pontosAlvo).ceil().clamp(1, totalSamples);
    final amostras = <double>[];

    var i = 0;
    while (i < totalSamples) {
      final fim = (i + blockSize).clamp(0, totalSamples);
      var pico = 0;
      for (var s = i; s < fim; s++) {
        final sampleOffset = dataOffset + s * numChannels * 2;
        final valor = byteData.getInt16(sampleOffset, Endian.little).abs();
        if (valor > pico) pico = valor;
      }
      amostras.add(pico / 32768.0);
      i = fim;
    }

    return WaveformData(amostras: amostras, sampleRate: sampleRate, duracao: duracao);
  }

  String _tag(ByteData data, int offset) {
    return String.fromCharCodes([
      data.getUint8(offset),
      data.getUint8(offset + 1),
      data.getUint8(offset + 2),
      data.getUint8(offset + 3),
    ]);
  }
}
