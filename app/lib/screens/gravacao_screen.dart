import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ponto.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../utils/onda.dart';
import '../widgets/info_banner.dart';
import '../widgets/screen_header.dart';

class GravacaoScreen extends StatelessWidget {
  const GravacaoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final alvo = state.alvo;
    final gravando = state.gravando;
    final snrOk = state.snrOk;
    final snr = state.snr;

    final timerCor = !gravando ? AppColors.timerRest : (snrOk ? AppColors.ink : AppColors.bad);
    final timerTexto = gravando ? '${state.restante.toStringAsFixed(1).replaceAll('.', ',')}s' : '10,0s';
    final timerRotulo = gravando ? 'restantes — mantenha a posição' : 'duração da captura';

    // Formato das barras é decorativo (não é a forma de onda real amostra a
    // amostra), mas a amplitude reage ao nível de entrada real do microfone.
    final nivelNormalizado = (snr / 40).clamp(0.0, 1.0);
    final amp = gravando ? (0.25 + nivelNormalizado * 0.75) : 0.16;
    final barras = onda(34, amp, state.quadro * 0.4);
    final shakeX = gravando && !snrOk ? (state.quadro.isEven ? -2.0 : 2.0) : 0.0;

    final avisoBg = snrOk ? AppColors.okBg : AppColors.badBg;
    final avisoTexto = snrOk ? 'Sinal bom — pode gravar' : 'Ruído excessivo · reposicionar sensor';
    final snrCor = snrOk ? AppColors.okTxt : AppColors.bad;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              onBack: state.cancelarGravacao,
              title: alvo?.titulo ?? 'Ponto',
              subtitle: alvo == null ? '—' : 'Ponto ${alvo.letra} · ${alvo.grupo.label} · 44.1 kHz · OPUS',
              trailing: Text('3/3', style: AppText.mono(11, weight: FontWeight.w600, color: AppColors.mut)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (state.erroGravacao != null) ...[
                      DotBanner(
                        bg: AppColors.badBg,
                        dotColor: AppColors.bad,
                        textColor: AppColors.bad,
                        text: state.erroGravacao!,
                      ),
                      const SizedBox(height: 16),
                    ],
                    Text(timerTexto, style: AppText.mono(72, weight: FontWeight.w600, letterSpacing: -0.03 * 72, color: timerCor)),
                    const SizedBox(height: 10),
                    Text(timerRotulo, style: AppText.ps(14, weight: FontWeight.w500, color: AppColors.mut)),
                    const SizedBox(height: 26),
                    Transform.translate(
                      offset: Offset(shakeX, 0),
                      child: Container(
                        height: 132,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surf,
                          border: Border.all(color: AppColors.line),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            for (var i = 0; i < barras.length; i++) ...[
                              Expanded(
                                child: Container(
                                  height: 8 + barras[i] * 108,
                                  decoration: BoxDecoration(
                                    color: !gravando ? AppColors.waveRest : (snrOk ? AppColors.ok : AppColors.bad),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              if (i != barras.length - 1) const SizedBox(width: 3),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Qualidade do sinal (SNR)', style: AppText.ps(12.5, weight: FontWeight.w500, color: AppColors.mut)),
                            Text('${snr.round()} dB', style: AppText.mono(13, weight: FontWeight.w600, color: snrCor)),
                          ],
                        ),
                        const SizedBox(height: 9),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (snr / 40).clamp(0.0, 1.0),
                            minHeight: 8,
                            backgroundColor: AppColors.line,
                            valueColor: AlwaysStoppedAnimation(snrCor),
                          ),
                        ),
                        const SizedBox(height: 9),
                        DotBanner(bg: avisoBg, dotColor: snrCor, textColor: snrCor, text: avisoTexto, fontSize: 13),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              decoration: const BoxDecoration(
                color: AppColors.surf,
                border: Border(top: BorderSide(color: AppColors.line)),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: gravando ? state.pararGravacao : state.iniciarGravacao,
                    child: Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: gravando ? AppColors.bad : AppColors.acc,
                        border: Border.all(color: AppColors.line, width: 4),
                      ),
                      child: Center(
                        child: gravando
                            ? Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                              )
                            : Container(
                                width: 38,
                                height: 38,
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    gravando ? 'Toque para interromper' : 'Toque para gravar 10 s',
                    style: AppText.ps(12.5, color: AppColors.mut),
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
