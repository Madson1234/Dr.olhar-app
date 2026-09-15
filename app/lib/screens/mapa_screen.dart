import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/pontos_ausculta.dart';
import '../models/ponto.dart';
import '../state/app_state.dart';
import '../state/tela.dart';
import '../theme/tokens.dart';
import '../widgets/app_button.dart';
import '../widgets/dialog_overlay.dart';
import '../widgets/screen_header.dart';

const double _panelW = 344;
const double _panelH = 267;

class MapaScreen extends StatelessWidget {
  const MapaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final feitos = state.coletados.length;
    final pontoAtual = state.pontoAtual;
    final alvo = state.alvo;
    final mapaCompleto = state.mapaCompleto;
    final mostrarPopup = mapaCompleto && !state.popupVisto;

    final dica = mapaCompleto
        ? 'Todos os pontos validados.'
        : pontoAtual != null
            ? 'Ponto em foco: ${pontoAtual.nome}'
            : 'Toque em um ponto para iniciar a gravação.';
    final botaoTexto = mapaCompleto
        ? 'Exame concluído'
        : pontoAtual != null
            ? 'Gravar ${pontoAtual.nome}'
            : 'Gravar próximo ponto';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                ScreenHeader(
                  onBack: () => state.ir(Tela.contexto),
                  title: 'Mapa de ausculta',
                  subtitle: '$feitos de ${pontosAusculta.length} pontos coletados',
                  trailing: Text('1/3', style: AppText.mono(11, weight: FontWeight.w600, color: AppColors.mut)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: state.progressoPct,
                      minHeight: 6,
                      backgroundColor: AppColors.line,
                      valueColor: const AlwaysStoppedAnimation(AppColors.ok),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Row(
                    children: [
                      Expanded(child: _AbaButton(label: 'Anterior', ativo: state.face == Face.anterior, onTap: () => state.verFace(Face.anterior))),
                      const SizedBox(width: 6),
                      Expanded(child: _AbaButton(label: 'Posterior', ativo: state.face == Face.posterior, onTap: () => state.verFace(Face.posterior))),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    children: [
                      _CorpoPanel(face: state.face, pontoId: state.pontoId, coletados: state.coletados),
                      if (alvo != null) ...[
                        const SizedBox(height: 12),
                        _CartaoReferencia(alvo: alvo, coletado: state.coletados.contains(alvo.id)),
                      ],
                      const SizedBox(height: 12),
                      const _Legenda(),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                  decoration: const BoxDecoration(
                    color: AppColors.surf,
                    border: Border(top: BorderSide(color: AppColors.line)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(dica, textAlign: TextAlign.center, style: AppText.ps(13, height: 1.35, color: AppColors.mut)),
                      const SizedBox(height: 10),
                      PrimaryButton(label: botaoTexto, onPressed: state.acaoMapa),
                    ],
                  ),
                ),
              ],
            ),
            if (mostrarPopup) DialogOverlay(child: _PopupConcluido(state: state)),
          ],
        ),
      ),
    );
  }
}

class _AbaButton extends StatelessWidget {
  final String label;
  final bool ativo;
  final VoidCallback onTap;
  const _AbaButton({required this.label, required this.ativo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: Material(
        color: ativo ? AppColors.ink : AppColors.surf,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child: Text(label, style: AppText.ps(14, weight: FontWeight.w600, color: ativo ? Colors.white : AppColors.mut)),
          ),
        ),
      ),
    );
  }
}

class _CorpoPanel extends StatelessWidget {
  final Face face;
  final String? pontoId;
  final Set<String> coletados;
  const _CorpoPanel({required this.face, required this.pontoId, required this.coletados});

  @override
  Widget build(BuildContext context) {
    final pontos = pontosAusculta.where((p) => p.face == face).toList();
    Ponto? foco;
    for (final p in pontos) {
      if (p.id == pontoId) {
        foco = p;
        break;
      }
    }
    final anterior = face == Face.anterior;
    final asset = anterior ? 'assets/images/torso-frente.png' : 'assets/images/torso-dorso.png';
    final d = anterior ? 32.0 : 42.0;
    final fs = anterior ? 14.0 : 16.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surf,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        children: [
          Text(
            anterior ? 'TÓRAX ANTERIOR' : 'TÓRAX POSTERIOR',
            textAlign: TextAlign.center,
            style: AppText.mono(11, weight: FontWeight.w600, letterSpacing: 0.1 * 11, color: AppColors.mut),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: _panelW,
            height: _panelH,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(child: Image.asset(asset, fit: BoxFit.contain)),
                for (final p in pontos)
                  _PontoMarcador(
                    ponto: p,
                    d: d,
                    fs: fs,
                    ativo: p.id == pontoId,
                    coletado: coletados.contains(p.id),
                  ),
                if (foco != null) _PulseRing(x: foco.x, y: foco.y),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PontoMarcador extends StatelessWidget {
  final Ponto ponto;
  final double d;
  final double fs;
  final bool ativo;
  final bool coletado;

  const _PontoMarcador({required this.ponto, required this.d, required this.fs, required this.ativo, required this.coletado});

  @override
  Widget build(BuildContext context) {
    final Color borda;
    final Color fundo;
    final Color texto;
    final List<BoxShadow> sombra;
    if (coletado) {
      borda = AppColors.ok;
      fundo = AppColors.ok;
      texto = Colors.white;
      sombra = AppShadows.pointNormal;
    } else if (ativo) {
      borda = AppColors.acc;
      fundo = AppColors.acc;
      texto = Colors.white;
      sombra = AppShadows.pointFocus;
    } else {
      borda = AppColors.pointPendingBorder;
      fundo = AppColors.pointPendingFill;
      texto = AppColors.pointPendingTxt;
      sombra = AppShadows.pointNormal;
    }

    return Positioned(
      left: _panelW * ponto.x / 100 - d / 2,
      top: _panelH * ponto.y / 100 - d / 2,
      width: d,
      height: d,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => context.read<AppState>().tocarPonto(ponto),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fundo,
              border: Border.all(color: borda, width: 2),
              boxShadow: sombra,
            ),
            child: Center(
              child: coletado
                  ? Icon(Icons.check_rounded, size: fs, color: texto)
                  : Text(ponto.letra, style: AppText.ps(fs, weight: FontWeight.w700, color: texto)),
            ),
          ),
        ),
      ),
    );
  }
}

class _PulseRing extends StatefulWidget {
  final double x;
  final double y;
  const _PulseRing({required this.x, required this.y});

  @override
  State<_PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<_PulseRing> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const ringSize = 36.0;
    return Positioned(
      left: _panelW * widget.x / 100 - ringSize / 2,
      top: _panelH * widget.y / 100 - ringSize / 2,
      width: ringSize,
      height: ringSize,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, child) {
            // Mirrors the `pulso` keyframes: scale 1→2.6 & fade over the
            // first 70% of the cycle, then hold invisible until it loops.
            final t = _c.value;
            final phase = (t / 0.7).clamp(0.0, 1.0);
            final scale = 1 + phase * 1.6;
            final opacity = 0.9 * (1 - phase);
            return Opacity(
              opacity: opacity.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  decoration: const BoxDecoration(color: AppColors.pulseRing, shape: BoxShape.circle),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CartaoReferencia extends StatelessWidget {
  final Ponto alvo;
  final bool coletado;
  const _CartaoReferencia({required this.alvo, required this.coletado});

  @override
  Widget build(BuildContext context) {
    final cor = coletado ? AppColors.ok : AppColors.acc;
    final bg = coletado ? AppColors.okBg : AppColors.chip;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.surf,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(AppRadii.cardSmall),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(alvo.letra, style: AppText.ps(17, weight: FontWeight.w700, color: cor))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(alvo.nome, style: AppText.ps(14.5, weight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Text(alvo.grupo.label.toUpperCase(), style: AppText.mono(10, weight: FontWeight.w600, letterSpacing: 0.08 * 10, color: AppColors.mut)),
                  ],
                ),
                const SizedBox(height: 5),
                Text(alvo.local, style: AppText.mono(11.5, weight: FontWeight.w500, color: cor)),
                const SizedBox(height: 5),
                Text(alvo.desc, style: AppText.ps(12.5, height: 1.4, color: AppColors.mut)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Legenda extends StatelessWidget {
  const _Legenda();

  @override
  Widget build(BuildContext context) {
    Widget item(String label, {Color? fill, Color? border}) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fill,
              border: border != null ? Border.all(color: border, width: 2) : null,
            ),
          ),
          const SizedBox(width: 6),
          Text(label, style: AppText.ps(11.5, color: AppColors.mut)),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        item('Pendente', border: AppColors.legendPending),
        const SizedBox(width: 14),
        item('Em foco', fill: AppColors.acc),
        const SizedBox(width: 14),
        item('Coletado', fill: AppColors.ok),
      ],
    );
  }
}

class _PopupConcluido extends StatelessWidget {
  final AppState state;
  const _PopupConcluido({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(color: AppColors.okBg, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, size: 38, color: AppColors.ok),
              ),
              const SizedBox(height: 16),
              Text('Exame concluído', textAlign: TextAlign.center, style: AppText.ps(21, weight: FontWeight.w700, letterSpacing: -0.01 * 21)),
              const SizedBox(height: 8),
              Text(
                'Os 9 pontos do protocolo foram auscultados e validados nesta visita.',
                textAlign: TextAlign.center,
                style: AppText.ps(13.5, height: 1.45, color: AppColors.mut),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PrimaryButton(label: 'Concluir visita', onPressed: state.fecharPopup, height: 54, fontSize: 16),
        ],
      ),
    );
  }
}
