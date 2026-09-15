import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ponto.dart';
import '../state/app_state.dart';
import '../state/tela.dart';
import '../theme/tokens.dart';
import '../widgets/app_button.dart';
import '../widgets/screen_header.dart';

IconData _iconeGrupo(GrupoPonto g) => switch (g) {
      GrupoPonto.pulmonar => Icons.air_rounded,
      GrupoPonto.cardiaco => Icons.monitor_heart_rounded,
      GrupoPonto.intestinal => Icons.self_improvement_rounded,
    };

class InstrucoesScreen extends StatelessWidget {
  const InstrucoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final alvo = state.alvo;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              onBack: () => state.ir(Tela.mapa),
              title: alvo?.titulo ?? 'Ponto',
              subtitle: 'Orientações antes da captura',
              trailing: Text('2/3', style: AppText.mono(11, weight: FontWeight.w600, color: AppColors.mut)),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 24, 18, 18),
                children: [
                  if (alvo != null) ...[
                    Column(
                      children: [
                        Container(
                          width: 132,
                          height: 132,
                          decoration: BoxDecoration(color: alvo.grupo.accentBg, shape: BoxShape.circle),
                          child: Icon(_iconeGrupo(alvo.grupo), size: 70, color: alvo.grupo.accent),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          alvo.titulo,
                          textAlign: TextAlign.center,
                          style: AppText.ps(23, weight: FontWeight.w700, letterSpacing: -0.015 * 23),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          alvo.grupo.label.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: AppText.mono(11, weight: FontWeight.w600, letterSpacing: 0.12 * 11, color: alvo.grupo.accentText),
                        ),
                        const SizedBox(height: 8),
                        Text(alvo.local, textAlign: TextAlign.center, style: AppText.ps(13, height: 1.4, color: AppColors.mut)),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Column(
                      children: [
                        for (final texto in alvo.grupo.instrucoes) ...[
                          _InstrucaoItem(texto: texto, bg: alvo.grupo.accentBg, cor: alvo.grupo.accent),
                          const SizedBox(height: 9),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              decoration: const BoxDecoration(
                color: AppColors.surf,
                border: Border(top: BorderSide(color: AppColors.line)),
              ),
              child: PrimaryButton(label: 'Tudo pronto, continuar', onPressed: state.irGravacao),
            ),
          ],
        ),
      ),
    );
  }
}

class _InstrucaoItem extends StatelessWidget {
  final String texto;
  final Color bg;
  final Color cor;
  const _InstrucaoItem({required this.texto, required this.bg, required this.cor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surf,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(AppRadii.cardSmall),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(Icons.check_rounded, size: 13, color: cor),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(texto, style: AppText.ps(14.5, height: 1.4))),
        ],
      ),
    );
  }
}
