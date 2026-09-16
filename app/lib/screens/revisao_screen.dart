import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart' show PlayerState;
import 'package:provider/provider.dart';

import '../services/waveform_decoder.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/app_button.dart';
import '../widgets/info_banner.dart';
import '../widgets/screen_header.dart';

class RevisaoScreen extends StatefulWidget {
  const RevisaoScreen({super.key});

  @override
  State<RevisaoScreen> createState() => _RevisaoScreenState();
}

class _RevisaoScreenState extends State<RevisaoScreen> {
  static const _decoder = WaveformDecoder();

  String? _caminhoCarregado;
  Future<WaveformData>? _futuroOnda;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _carregarSeNecessario();
  }

  void _carregarSeNecessario() {
    final caminho = context.read<AppState>().caminhoGravado;
    if (caminho == null || caminho == _caminhoCarregado) return;
    _caminhoCarregado = caminho;
    _futuroOnda = _decoder.decodificarArquivo(caminho);
    context.read<AppState>().playerService.carregar(caminho);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    _carregarSeNecessario();

    final alvo = state.alvo;
    final snrOk = state.snrOk;
    final cor = snrOk ? AppColors.okTxt : AppColors.bad;
    final qualidade = snrOk ? 'Boa' : 'Ruim';
    final avisoBg = snrOk ? AppColors.okBg : AppColors.badBg;
    final aviso = snrOk
        ? 'Som limpo, pode aceitar o ponto.'
        : 'Muito ruído na gravação. Refaça com o sensor mais firme sobre o ponto.';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              onBack: null,
              title: 'Revisar captura',
              subtitle: '${alvo?.titulo ?? 'Ponto'} · 10 s',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surf,
                      border: Border.all(color: AppColors.line),
                      borderRadius: BorderRadius.circular(AppRadii.card),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 104,
                          child: _futuroOnda == null
                              ? const Center(
                                  child: Text('Sem gravação', style: TextStyle(color: AppColors.mut)),
                                )
                              : FutureBuilder<WaveformData>(
                                  future: _futuroOnda,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState != ConnectionState.done) {
                                      return const Center(
                                        child: SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      );
                                    }
                                    if (snapshot.hasError || snapshot.data!.amostras.isEmpty) {
                                      return const Center(
                                        child: Text('Não foi possível ler o áudio', style: TextStyle(color: AppColors.mut)),
                                      );
                                    }
                                    final amostras = snapshot.data!.amostras;
                                    return Row(
                                      children: [
                                        for (var i = 0; i < amostras.length; i++) ...[
                                          Expanded(
                                            child: Container(
                                              height: 6 + amostras[i] * 92,
                                              decoration: BoxDecoration(
                                                color: AppColors.waveStatic,
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                            ),
                                          ),
                                          if (i != amostras.length - 1) const SizedBox(width: 2.5),
                                        ],
                                      ],
                                    );
                                  },
                                ),
                        ),
                        const SizedBox(height: 14),
                        _Player(state: state),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surf,
                      border: Border.all(color: AppColors.line),
                      borderRadius: BorderRadius.circular(AppRadii.cardSmall),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Qualidade da captura', style: AppText.ps(13.5, weight: FontWeight.w500, color: AppColors.mut)),
                        Text(qualidade, style: AppText.ps(16, weight: FontWeight.w600, color: cor)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  DotBanner(bg: avisoBg, dotColor: cor, textColor: cor, text: aviso),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              decoration: const BoxDecoration(
                color: AppColors.surf,
                border: Border(top: BorderSide(color: AppColors.line)),
              ),
              child: Row(
                children: [
                  Expanded(flex: 5, child: SecondaryButton(label: 'Refazer', onPressed: state.refazer, height: 60)),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 7,
                    child: PrimaryButton(label: 'Aceitar ponto', onPressed: state.aceitar, bg: AppColors.ok),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Player extends StatelessWidget {
  final AppState state;
  const _Player({required this.state});

  String _formatar(Duration d) {
    final s = d.inSeconds.clamp(0, 99);
    return '0:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final player = state.playerService;

    return StreamBuilder<PlayerState>(
      stream: player.estadoStream,
      builder: (context, estadoSnap) {
        final tocando = estadoSnap.data?.playing ?? false;
        // Reavaliado a cada mudança de estado do player, então capta a
        // duração assim que o arquivo termina de carregar.
        final duracao = player.duracao ?? const Duration(seconds: 10);
        return Row(
          children: [
            GestureDetector(
              onTap: () => tocando ? player.pausar() : player.tocar(),
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(color: AppColors.acc, shape: BoxShape.circle),
                child: Icon(
                  tocando ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StreamBuilder<Duration>(
                    stream: player.posicaoStream,
                    builder: (context, posSnap) {
                      final pos = posSnap.data ?? Duration.zero;
                      final pct = duracao.inMilliseconds == 0
                          ? 0.0
                          : (pos.inMilliseconds / duracao.inMilliseconds).clamp(0.0, 1.0);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 4,
                              backgroundColor: AppColors.line,
                              valueColor: const AlwaysStoppedAnimation(AppColors.acc),
                            ),
                          ),
                          const SizedBox(height: 7),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatar(pos), style: AppText.mono(11, color: AppColors.mut)),
                              Text(_formatar(duracao), style: AppText.mono(11, color: AppColors.mut)),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
