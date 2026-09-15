import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/paciente.dart';
import '../state/app_state.dart';
import '../state/tela.dart';
import '../theme/tokens.dart';
import '../widgets/app_button.dart';
import '../widgets/dialog_overlay.dart';
import '../widgets/info_banner.dart';

class PacientesScreen extends StatelessWidget {
  const PacientesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _Header(state: state),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    children: [
                      for (var i = 0; i < state.pacientes.length; i++) ...[
                        _PacienteRow(paciente: state.pacientes[i], index: i, online: state.online),
                        const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 6),
                      const LabelBanner(
                        bg: Colors.transparent,
                        labelColor: AppColors.mut,
                        textColor: AppColors.mut,
                        label: 'UX-05',
                        text: 'O ícone à direita mostra o envio de cada visita: nuvem sincronizado, '
                            'flecha em envio, rede cortada sem conexão.',
                        border: Border.fromBorderSide(BorderSide(color: AppColors.line)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (state.excluindoIndex != null)
              DialogOverlay(child: _ExcluirDialog(state: state)),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final AppState state;
  const _Header({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.surf,
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Segunda, 16 nov', style: AppText.ps(13, color: AppColors.mut)),
                    const SizedBox(height: 3),
                    Text('Pacientes', style: AppText.ps(24, weight: FontWeight.w700, letterSpacing: -0.02 * 24)),
                  ],
                ),
              ),
              Row(
                children: [
                  _ConexaoChip(online: state.online),
                  const SizedBox(width: 9),
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: Material(
                      color: AppColors.acc,
                      borderRadius: BorderRadius.circular(AppRadii.chipRound),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppRadii.chipRound),
                        onTap: () => context.read<AppState>().ir(Tela.cadastro),
                        child: const Center(
                          child: Icon(Icons.add_rounded, size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StatCard(numero: '${state.totalVisitas}', rotulo: 'agendadas'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(numero: '${state.concluidas}', rotulo: 'concluídas', numeroCor: AppColors.okTxt),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConexaoChip extends StatelessWidget {
  final bool online;
  const _ConexaoChip({required this.online});

  @override
  Widget build(BuildContext context) {
    final cor = online ? AppColors.okTxt : AppColors.warnTxt;
    final bg = online ? AppColors.okBg : AppColors.warnBg;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadii.pill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 7, height: 7, decoration: BoxDecoration(color: cor, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(online ? 'Online' : 'Offline', style: AppText.mono(11, weight: FontWeight.w600, color: cor)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String numero;
  final String rotulo;
  final Color numeroCor;
  const _StatCard({required this.numero, required this.rotulo, this.numeroCor = AppColors.ink});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(color: AppColors.surf2, borderRadius: BorderRadius.circular(11)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(numero, style: AppText.ps(20, weight: FontWeight.w700, color: numeroCor)),
          const SizedBox(height: 5),
          Text(rotulo, style: AppText.ps(11.5, color: AppColors.mut)),
        ],
      ),
    );
  }
}

class _PacienteRow extends StatelessWidget {
  final Paciente paciente;
  final int index;
  final bool online;
  const _PacienteRow({required this.paciente, required this.index, required this.online});

  @override
  Widget build(BuildContext context) {
    final ehNuvem = paciente.sync == SyncBase.nuvem;
    final ehEnviando = !ehNuvem && online;
    final Color syncCor;
    final Color syncBg;
    final IconData syncIcon;
    if (ehNuvem) {
      syncCor = AppColors.okTxt;
      syncBg = AppColors.okBg;
      syncIcon = Icons.cloud_outlined;
    } else if (ehEnviando) {
      syncCor = AppColors.acc;
      syncBg = AppColors.chip;
      syncIcon = Icons.arrow_upward_rounded;
    } else {
      syncCor = AppColors.warnTxt;
      syncBg = AppColors.warnBg;
      syncIcon = Icons.wifi_off_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surf,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(13),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: AppColors.acc),
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.read<AppState>().abrirPaciente(paciente),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 15, 4, 15),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(paciente.nome, style: AppText.ps(16.5, weight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(paciente.detalhe, style: AppText.ps(13, color: AppColors.mut)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(paciente.hora, style: AppText.mono(12.5, color: AppColors.mut)),
                            const SizedBox(height: 8),
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(color: syncBg, borderRadius: BorderRadius.circular(8)),
                              child: Icon(syncIcon, size: 15, color: syncCor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 36,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.read<AppState>().pedirExcluir(index),
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(left: BorderSide(color: AppColors.line)),
                    ),
                    child: const Center(
                      child: Icon(Icons.delete_outline_rounded, size: 21, color: AppColors.mut),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExcluirDialog extends StatelessWidget {
  final AppState state;
  const _ExcluirDialog({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(color: AppColors.badBg, shape: BoxShape.circle),
                child: const Icon(Icons.delete_outline_rounded, size: 30, color: AppColors.bad),
              ),
              const SizedBox(height: 14),
              Text('Excluir paciente', textAlign: TextAlign.center, style: AppText.ps(19, weight: FontWeight.w700, letterSpacing: -0.01 * 19)),
              const SizedBox(height: 8),
              Text(
                state.excluirTexto,
                textAlign: TextAlign.center,
                style: AppText.ps(13.5, height: 1.45, color: AppColors.mut),
              ),
            ],
          ),
          const SizedBox(height: 18),
          PrimaryButton(label: 'Excluir', onPressed: state.confirmarExcluir, height: 54, fontSize: 16, bg: AppColors.bad),
          const SizedBox(height: 9),
          SecondaryButton(label: 'Cancelar', onPressed: state.cancelarExcluir, height: 52),
        ],
      ),
    );
  }
}
