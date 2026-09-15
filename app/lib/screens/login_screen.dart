import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/app_button.dart';
import '../widgets/info_banner.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    return Scaffold(
      backgroundColor: AppColors.surf,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _Marca(),
                      const SizedBox(height: 28),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: const [
                          _CampoEstatico(rotulo: 'CPF do agente', valor: '821.443.190-05', fontSize: 18),
                          SizedBox(height: 12),
                          _CampoEstatico(rotulo: 'Senha', valor: '••••••', fontSize: 20, letterSpacing: 0.3 * 20),
                        ],
                      ),
                      const SizedBox(height: 28),
                      PrimaryButton(label: 'Entrar', onPressed: state.entrar),
                      const SizedBox(height: 28),
                      const DotBanner(
                        bg: AppColors.chip,
                        dotColor: AppColors.acc,
                        textColor: AppColors.chipTxt,
                        text: 'Login válido por 12 h em modo offline. Os dados coletados ficam '
                            'criptografados no aparelho até haver rede.',
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'v A.01 · RDC 751 · LGPD',
                  textAlign: TextAlign.center,
                  style: AppText.mono(11.5, color: AppColors.mut),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Marca extends StatelessWidget {
  const _Marca();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 46,
          height: 46,
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(color: AppColors.acc, borderRadius: BorderRadius.circular(13)),
          child: Center(
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
            ),
          ),
        ),
        Text(
          'Dr. Olhar',
          style: AppText.ps(30, weight: FontWeight.w700, height: 1.1, letterSpacing: -0.025 * 30),
        ),
      ],
    );
  }
}

/// A non-editable field display used on the login mock (no real auth
/// backend to wire up in this UI-only build).
class _CampoEstatico extends StatelessWidget {
  final String rotulo;
  final String valor;
  final double fontSize;
  final double? letterSpacing;

  const _CampoEstatico({
    required this.rotulo,
    required this.valor,
    required this.fontSize,
    this.letterSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(rotulo, style: AppText.ps(12, weight: FontWeight.w600, color: AppColors.mut)),
        const SizedBox(height: 7),
        Container(
          height: 56,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surf2,
            borderRadius: BorderRadius.circular(AppRadii.field),
            border: Border.all(color: AppColors.line, width: 1.5),
          ),
          child: Text(
            valor,
            style: AppText.mono(fontSize, weight: FontWeight.w500, letterSpacing: letterSpacing),
          ),
        ),
      ],
    );
  }
}
