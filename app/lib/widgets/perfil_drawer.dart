import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/tokens.dart';
import 'app_button.dart';
import 'info_banner.dart';

/// Painel de sessão do agente — identidade, unidade, fila de sincronização
/// e logout. Aberto pelo ícone de menu no cabeçalho de Pacientes.
class PerfilDrawer extends StatelessWidget {
  const PerfilDrawer({super.key});

  static const _nome = 'Marina Sousa';
  static const _iniciais = 'MS';
  static const _cargo = 'Agente comunitária de saúde';
  static const _cns = '704 8091 5523 0017';
  static const _unidade = 'UBS Boa Vista · Equipe 3';
  static const _microarea = '04 · Sítio Boa Vista e Vila do Riacho';
  // Sem backend de sincronização real ainda — placeholder honesto até
  // termos um horário de sync de verdade para mostrar aqui.
  static const _ultimaSincronizacao = '07:48';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Drawer(
      width: 320,
      backgroundColor: AppColors.surf,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
              color: AppColors.acc,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(_iniciais, style: AppText.ps(18, weight: FontWeight.w700, color: Colors.white)),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: Material(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => Navigator.of(context).pop(),
                            child: const Icon(Icons.close_rounded, size: 15, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(_nome, style: AppText.ps(21, weight: FontWeight.w700, color: Colors.white, letterSpacing: -0.01 * 21)),
                  const SizedBox(height: 3),
                  Text(_cargo, style: AppText.ps(13, color: Colors.white.withValues(alpha: 0.85))),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                children: [
                  _Campo(rotulo: 'CNS', valor: _cns, mono: true),
                  const SizedBox(height: 16),
                  _Campo(rotulo: 'Unidade', valor: _unidade),
                  const SizedBox(height: 16),
                  _Campo(rotulo: 'Microárea', valor: _microarea),
                  const SizedBox(height: 18),
                  const Divider(color: AppColors.line, height: 1),
                  const SizedBox(height: 14),
                  _LinhaInfo(
                    rotulo: 'Situação da rede',
                    valor: state.online ? 'Online' : 'Offline',
                    cor: state.online ? AppColors.okTxt : AppColors.warnTxt,
                  ),
                  const SizedBox(height: 10),
                  _LinhaInfo(rotulo: 'Visitas na fila', valor: '${state.visitasNaFila}'),
                  const SizedBox(height: 10),
                  const _LinhaInfo(rotulo: 'Última sincronização', valor: _ultimaSincronizacao),
                  const SizedBox(height: 10),
                  _LinhaInfo(rotulo: 'Sessão expira em', valor: state.sessaoExpiraEm),
                  const SizedBox(height: 18),
                  const DotBanner(
                    bg: AppColors.chip,
                    dotColor: AppColors.acc,
                    textColor: AppColors.chipTxt,
                    text: 'Ao sair, as visitas ainda na fila continuam guardadas no aparelho e '
                        'sobem no próximo login com rede.',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SecondaryButton(
                label: 'Sair da conta',
                icon: Icons.logout_rounded,
                borderColor: AppColors.bad,
                textColor: AppColors.bad,
                onPressed: () {
                  Navigator.of(context).pop();
                  state.sair();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'v A.01 · RDC 751 · LGPD',
                textAlign: TextAlign.center,
                style: AppText.mono(11.5, color: AppColors.mut),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Campo extends StatelessWidget {
  final String rotulo;
  final String valor;
  final bool mono;
  const _Campo({required this.rotulo, required this.valor, this.mono = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rotulo.toUpperCase(),
          style: AppText.mono(10.5, weight: FontWeight.w600, letterSpacing: 0.08 * 10.5, color: AppColors.mut),
        ),
        const SizedBox(height: 5),
        Text(
          valor,
          style: mono ? AppText.mono(15, weight: FontWeight.w500) : AppText.ps(15, weight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _LinhaInfo extends StatelessWidget {
  final String rotulo;
  final String valor;
  final Color cor;
  const _LinhaInfo({required this.rotulo, required this.valor, this.cor = AppColors.ink});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(rotulo, style: AppText.ps(13.5, color: AppColors.mut)),
        Text(valor, style: AppText.ps(14.5, weight: FontWeight.w600, color: cor)),
      ],
    );
  }
}
