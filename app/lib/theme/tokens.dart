import 'package:flutter/material.dart';

/// Design tokens transcribed from `App do Agente.dc.html` (Claude Design
/// handoff for the Dr. Olhar community-agent app). Keep values in sync with
/// that source of truth rather than inventing new ones.
class AppColors {
  AppColors._();

  static const acc = Color(0xFF1B6FE3);
  static const accD = Color(0xFF0E4FAE);
  static const bg = Color(0xFFEEF1F4);
  static const surf = Color(0xFFFFFFFF);
  static const surf2 = Color(0xFFF5F7F9);
  static const ink = Color(0xFF0F1720);
  static const mut = Color(0xFF57646F);
  static const line = Color(0xFFE1E6EB);
  static const chip = Color(0xFFEDF3FD);
  static const chipTxt = Color(0xFF2A4A72);
  static const ok = Color(0xFF1B8C5A);
  static const okTxt = Color(0xFF0F6B45);
  static const okBg = Color(0xFFE6F4EC);
  static const warn = Color(0xFFC9821B);
  static const warnTxt = Color(0xFF8A5A0B);
  static const warnBg = Color(0xFFFAF3E3);
  static const bad = Color(0xFFC33B2E);
  static const badBg = Color(0xFFFBECEA);
  static const badHover = Color(0xFFA62E23);

  static const timerRest = Color(0xFF6B7885);
  static const waveStatic = Color(0xFFB9CBE4);
  static const waveRest = Color(0xFFCBD5DE);
  static const pointPendingTxt = Color(0xFF4A5B69);
  static const hoverBorder = Color(0xFFC8D2DB);
  static const legendPending = Color(0xFFC2CBD4);

  static const pointPendingBorder = Color(0x380F1720); // rgba(15,23,32,.22)
  static const pointPendingFill = Color(0xEBFFFFFF); // rgba(255,255,255,.92)
  static const pulseRing = Color(0x591B6FE3); // rgba(27,111,227,.35)
  static const overlay = Color(0x8C0F1720); // rgba(15,23,32,.55)

  /// Group accent colors (pulmonar / cardíaco / intestinal).
  static const pulmonar = acc;
  static const pulmonarTxt = accD;
  static const pulmonarBg = chip;
  static const cardiaco = bad;
  static const cardiacoBg = badBg;
  static const intestinal = okTxt;
  static const intestinalBg = okBg;
}

class AppRadii {
  AppRadii._();
  static const field = 12.0;
  static const card = 16.0;
  static const cardSmall = 13.0;
  static const button = 14.0;
  static const dialog = 20.0;
  static const pill = 20.0;
  static const chipRound = 9.0;
}

class AppShadows {
  AppShadows._();

  static const dialog = [
    BoxShadow(color: Color(0x4D0F1720), blurRadius: 48, offset: Offset(0, 18)),
  ];
  static const pointFocus = [
    BoxShadow(color: Color(0x731B6FE3), blurRadius: 14, offset: Offset(0, 4)),
  ];
  static const pointNormal = [
    BoxShadow(color: Color(0x290F1720), blurRadius: 4, offset: Offset(0, 1)),
  ];
}

/// Text style helpers matching the prototype's inline `font:` shorthand.
/// `ps` = Public Sans, `mono` = IBM Plex Mono.
class AppText {
  AppText._();

  static TextStyle ps(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.ink,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: 'Public Sans',
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle mono(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.ink,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: 'IBM Plex Mono',
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }
}
