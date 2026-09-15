import 'package:flutter/material.dart';

import '../theme/tokens.dart';

enum Face { anterior, posterior }

/// The three auscultation point groups. Order and Portuguese names are
/// fixed by the project's protocol (see PONTOS-DE-AUSCULTA.md) — never
/// rename or reorder.
enum GrupoPonto { cardiaco, pulmonar, intestinal }

extension GrupoPontoX on GrupoPonto {
  String get label => switch (this) {
        GrupoPonto.cardiaco => 'Cardíaco',
        GrupoPonto.pulmonar => 'Pulmonar',
        GrupoPonto.intestinal => 'Intestinal',
      };

  /// Decorative accent (icon strokes, focused checkmarks).
  Color get accent => switch (this) {
        GrupoPonto.pulmonar => AppColors.acc,
        GrupoPonto.cardiaco => AppColors.bad,
        GrupoPonto.intestinal => AppColors.okTxt,
      };

  /// Accessible-contrast text color for the group label.
  Color get accentText => switch (this) {
        GrupoPonto.pulmonar => AppColors.accD,
        GrupoPonto.cardiaco => AppColors.bad,
        GrupoPonto.intestinal => AppColors.okTxt,
      };

  Color get accentBg => switch (this) {
        GrupoPonto.pulmonar => AppColors.chip,
        GrupoPonto.cardiaco => AppColors.badBg,
        GrupoPonto.intestinal => AppColors.okBg,
      };

  List<String> get instrucoes => switch (this) {
        GrupoPonto.pulmonar => const [
            'Respire mais fundo e mais devagar que o normal',
            'Respire pela boca, não pelo nariz',
            'Mantenha o tórax despido na região do ponto',
            'Se sentir necessidade, tussa uma vez antes de começarmos',
          ],
        GrupoPonto.cardiaco => const [
            'Respire normalmente, sem forçar',
            'Fique em ambiente silencioso',
            'Quando indicado no app, prenda a respiração por alguns segundos',
            'Evite falar durante a captura',
          ],
        GrupoPonto.intestinal => const [
            'Relaxe a musculatura abdominal',
            'Respire normalmente',
            'Evite falar durante a captura',
            'Fique parado, sem se mexer',
          ],
      };
}

/// One of the 9 fixed auscultation points of the protocol. Do not add,
/// remove, rename or reorder — see PONTOS-DE-AUSCULTA.md.
class Ponto {
  final String id;
  final String letra;
  final GrupoPonto grupo;
  final Face face;
  final String nome;
  final String local;
  final String desc;
  final double x;
  final double y;

  const Ponto({
    required this.id,
    required this.letra,
    required this.grupo,
    required this.face,
    required this.nome,
    required this.local,
    required this.desc,
    required this.x,
    required this.y,
  });

  /// Cardiac points are shown as "Foco {nome}" in titles; others use the
  /// plain name.
  String get titulo => grupo == GrupoPonto.cardiaco ? 'Foco $nome' : nome;
}
