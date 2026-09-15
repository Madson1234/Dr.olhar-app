import 'dart:math' as math;

/// Generates a pseudo-random breathing-envelope waveform of [n] bars, in the
/// 0..1 range. [amp] scales the envelope (use a low value for an idle/quiet
/// look), [semente] shifts the phase so consecutive calls can look "live".
List<double> onda(int n, double amp, double semente) {
  final a = <double>[];
  for (var i = 0; i < n; i++) {
    final t = i / n;
    final resp = math.sin(t * math.pi * 2.6 + semente).abs();
    final gran = (math.sin(i * 12.9898 + semente * 78.233) * 43758.5453 % 1).abs();
    final v = resp * 0.78 * amp + gran * 0.3 * amp;
    a.add(v.clamp(0.06, 1.0));
  }
  return a;
}
