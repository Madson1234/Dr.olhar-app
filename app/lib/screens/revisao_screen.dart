import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../utils/onda.dart';
import '../widgets/app_button.dart';
import '../widgets/info_banner.dart';
import '../widgets/screen_header.dart';

class RevisaoScreen extends StatelessWidget {
  const RevisaoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final alvo = state.alvo;
    final snrOk = state.snrOk;
    final cor = snrOk ? AppColors.okTxt : AppColors.bad;
    final qualidade = snrOk ? 'Boa' : 'Ruim';
    final avisoBg = snrOk ? AppColors.okBg : AppColors.badBg;
    final aviso = snrOk
        ? 'Som limpo, pode aceitar o ponto.'
        : 'Muito ruído na gravação. Refaça com o sensor mais firme sobre o ponto.';
    final barras = onda(46, 1, 3.2);

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
                          child: Row(
                            children: [
                              for (var i = 0; i < barras.length; i++) ...[
                                Expanded(
                                  child: Container(
                                    height: 6 + barras[i] * 92,
                                    decoration: BoxDecoration(
                                      color: AppColors.waveStatic,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                                if (i != barras.length - 1) const SizedBox(width: 2.5),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(color: AppColors.acc, shape: BoxShape.circle),
                              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 26),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(2),
                                    child: const LinearProgressIndicator(
                                      value: 0,
                                      minHeight: 4,
                                      backgroundColor: AppColors.line,
                                      valueColor: AlwaysStoppedAnimation(AppColors.acc),
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('0:00', style: AppText.mono(11, color: AppColors.mut)),
                                      Text('0:10', style: AppText.mono(11, color: AppColors.mut)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
