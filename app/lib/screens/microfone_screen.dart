import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../state/tela.dart';
import '../theme/tokens.dart';
import '../widgets/app_button.dart';
import '../widgets/info_banner.dart';
import '../widgets/screen_header.dart';

class MicrofoneScreen extends StatelessWidget {
  const MicrofoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final testado = state.micTestado;
    final testando = state.micTestando;
    final micBg = testado ? AppColors.okBg : AppColors.chip;
    final micCor = testado ? AppColors.okTxt : AppColors.acc;
    final micTitCor = testado ? AppColors.okTxt : AppColors.ink;
    final micTitulo = testado ? 'Microfone pronto' : 'Conecte o microfone USB-C';
    final micTexto = testado
        ? 'Sinal recebido pela entrada USB-C. Mantenha o cabo livre durante toda a coleta.'
        : 'Conecte diretamente ao Android, mantenha o cabo livre e faça a coleta em ambiente silencioso.';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              onBack: () => state.ir(Tela.hoje),
              title: 'Prepare o microfone',
              subtitle: state.pacienteNomeAtual,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
                    decoration: BoxDecoration(color: micBg, borderRadius: BorderRadius.circular(18)),
                    child: Column(
                      children: [
                        Container(
                          width: 104,
                          height: 104,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.72),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.mic_none_rounded, size: 52, color: micCor),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          micTitulo,
                          textAlign: TextAlign.center,
                          style: AppText.ps(19, weight: FontWeight.w700, letterSpacing: -0.01 * 19, color: micTitCor),
                        ),
                        const SizedBox(height: 8),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 280),
                          child: Text(
                            micTexto,
                            textAlign: TextAlign.center,
                            style: AppText.ps(13.5, height: 1.45, color: AppColors.mut),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (state.erroMicrofone != null) ...[
                    DotBanner(
                      bg: AppColors.badBg,
                      dotColor: AppColors.bad,
                      textColor: AppColors.bad,
                      fontSize: 12.5,
                      text: state.erroMicrofone!,
                    ),
                    const SizedBox(height: 12),
                  ],
                  const DotBanner(
                    bg: AppColors.warnBg,
                    dotColor: AppColors.warnTxt,
                    textColor: AppColors.warnTxt,
                    fontSize: 12.5,
                    text: 'A compatibilidade USB Audio precisa ser confirmada no dev build e no '
                        'microfone homologado.',
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              decoration: const BoxDecoration(
                color: AppColors.surf,
                border: Border(top: BorderSide(color: AppColors.line)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PrimaryButton(
                    label: testando ? 'Testando…' : (testado ? 'Testar novamente' : 'Testar microfone'),
                    onPressed: testando ? null : state.testarMicrofone,
                  ),
                  if (testado) ...[
                    const SizedBox(height: 9),
                    SecondaryButton(label: 'Continuar', onPressed: state.irContexto),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
