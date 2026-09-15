import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/pacientes_mock.dart';
import '../data/pontos_ausculta.dart';
import '../models/paciente.dart';
import '../models/ponto.dart';
import 'tela.dart';

/// Single source of truth for the whole clickable flow, mirroring the
/// Claude Design prototype's one-component state machine. Screens read from
/// this via Provider and call its methods instead of holding local state.
class AppState extends ChangeNotifier {
  Tela tela = Tela.login;
  Face face = Face.anterior;
  String? pontoId;
  final Set<String> coletados = {};

  // Connectivity is mocked as always-on here; the dev-only "Conexão"
  // simulation toggle from the prototype's sidebar chrome is scaffolding,
  // not part of the app. Wire this to a real connectivity signal later.
  final bool online = true;

  final List<Paciente> pacientes = List.of(pacientesMock);
  int _nextPacienteId = 1000;
  int? excluindoIndex;

  bool popupVisto = false;

  // Cadastro form.
  String formNome = '';
  String formCpf = '';
  String formRg = '';
  String formNasc = '';
  bool tentouSalvar = false;

  // Prepare o microfone / Contexto da coleta.
  String? pacienteSel;
  bool micTestado = false;
  String ctxSintomas = '';
  bool ctxOxigenio = false;
  String ctxRuido = '';

  // Gravação.
  bool gravando = false;
  double restante = 10;
  int quadro = 0;
  double _snrAtual = 27;
  Timer? _timer;

  final _rng = Random();

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ── Navegação genérica ──────────────────────────────────────────────
  void ir(Tela t) {
    _timer?.cancel();
    tela = t;
    gravando = false;
    notifyListeners();
  }

  void reiniciar() {
    _timer?.cancel();
    tela = Tela.login;
    face = Face.anterior;
    pontoId = null;
    coletados.clear();
    gravando = false;
    restante = 10;
    quadro = 0;
    popupVisto = false;
    excluindoIndex = null;
    micTestado = false;
    pacienteSel = null;
    ctxSintomas = '';
    ctxOxigenio = false;
    ctxRuido = '';
    notifyListeners();
  }

  // ── Login ────────────────────────────────────────────────────────────
  void entrar() => ir(Tela.hoje);

  // ── Pacientes ────────────────────────────────────────────────────────
  int get totalVisitas => pacientes.length;
  int get concluidas => coletados.isEmpty ? 0 : 1; // demo counter, matches prototype's fixed "1"

  void abrirPaciente(Paciente p) {
    pacienteSel = p.nome;
    micTestado = false;
    ctxSintomas = '';
    ctxOxigenio = false;
    ctxRuido = '';
    ir(Tela.microfone);
  }

  void pedirExcluir(int index) {
    excluindoIndex = index;
    notifyListeners();
  }

  void cancelarExcluir() {
    excluindoIndex = null;
    notifyListeners();
  }

  void confirmarExcluir() {
    if (excluindoIndex != null && excluindoIndex! < pacientes.length) {
      pacientes.removeAt(excluindoIndex!);
    }
    excluindoIndex = null;
    pacienteSel = null;
    notifyListeners();
  }

  String get excluirTexto {
    if (excluindoIndex == null || excluindoIndex! >= pacientes.length) return '';
    final nome = pacientes[excluindoIndex!].nome;
    return 'Remover $nome da agenda? As capturas já enviadas permanecem no prontuário.';
  }

  // ── Cadastrar paciente ──────────────────────────────────────────────
  void setFormNome(String v) {
    formNome = v;
    notifyListeners();
  }

  void setFormCpf(String v) {
    formCpf = v;
    notifyListeners();
  }

  void setFormRg(String v) {
    formRg = v;
    notifyListeners();
  }

  void setFormNasc(String v) {
    formNasc = v;
    notifyListeners();
  }

  Map<String, String> get errosForm {
    final e = <String, String>{};
    if (formNome.trim().length < 3) e['nome'] = 'Informe o nome completo.';
    if (formCpf.replaceAll(RegExp(r'\D'), '').length != 11) e['cpf'] = 'CPF deve ter 11 dígitos.';
    if (formRg.replaceAll(RegExp(r'[^\dxX]'), '').length < 5) e['rg'] = 'RG inválido.';
    final d = formNasc.replaceAll(RegExp(r'\D'), '');
    if (d.length != 8) {
      e['nasc'] = 'Use o formato DD/MM/AAAA.';
    } else {
      final dia = int.parse(d.substring(0, 2));
      final mes = int.parse(d.substring(2, 4));
      final ano = int.parse(d.substring(4, 8));
      final anoMax = DateTime.now().year;
      if (dia < 1 || dia > 31 || mes < 1 || mes > 12 || ano < 1900 || ano > anoMax) {
        e['nasc'] = 'Data fora do intervalo válido.';
      }
    }
    return e;
  }

  void salvarPaciente() {
    final e = errosForm;
    if (e.isNotEmpty) {
      tentouSalvar = true;
      notifyListeners();
      return;
    }
    final d = formNasc.replaceAll(RegExp(r'\D'), '');
    final idade = DateTime.now().year - int.parse(d.substring(4, 8));
    pacientes.add(Paciente(
      id: _nextPacienteId++,
      nome: formNome.trim(),
      detalhe: '$idade anos · cadastrado agora',
      hora: '—',
      sync: SyncBase.enviando,
    ));
    formNome = '';
    formCpf = '';
    formRg = '';
    formNasc = '';
    tentouSalvar = false;
    ir(Tela.hoje);
  }

  // ── Prepare o microfone ─────────────────────────────────────────────
  void testarMicrofone() {
    micTestado = true;
    notifyListeners();
  }

  void irContexto() => ir(Tela.contexto);

  String get pacienteNomeAtual =>
      pacienteSel ?? (pacientes.isNotEmpty ? pacientes.first.nome : 'Paciente');

  // ── Contexto da coleta ──────────────────────────────────────────────
  void setCtxSintomas(String v) {
    ctxSintomas = v;
    notifyListeners();
  }

  void setCtxRuido(String v) {
    ctxRuido = v;
    notifyListeners();
  }

  void alternarOxigenio() {
    ctxOxigenio = !ctxOxigenio;
    notifyListeners();
  }

  // ── Mapa corporal ───────────────────────────────────────────────────
  Ponto? get pontoAtual {
    if (pontoId == null) return null;
    for (final p in pontosAusculta) {
      if (p.id == pontoId) return p;
    }
    return null;
  }

  List<Ponto> get pendentes => pontosAusculta.where((p) => !coletados.contains(p.id)).toList();

  Ponto? get _proximoPendente {
    final naFace = pendentes.where((p) => p.face == face);
    if (naFace.isNotEmpty) return naFace.first;
    return pendentes.isNotEmpty ? pendentes.first : null;
  }

  /// The point shown in focus: the tapped point if any, otherwise the next
  /// pending point (preferring the currently visible body face).
  Ponto? get alvo => pontoAtual ?? _proximoPendente;

  bool get mapaCompleto => coletados.length == pontosAusculta.length;

  double get progressoPct => coletados.length / pontosAusculta.length;

  void tocarPonto(Ponto p) {
    pontoId = p.id;
    face = p.face;
    notifyListeners();
  }

  void verFace(Face f) {
    face = f;
    notifyListeners();
  }

  void acaoMapa() {
    if (mapaCompleto) {
      popupVisto = false;
      notifyListeners();
      return;
    }
    final p = alvo;
    if (p != null) {
      pontoId = p.id;
      face = p.face;
      restante = 10;
      gravando = false;
      ir(Tela.instrucoes);
    }
  }

  void fecharPopup() {
    popupVisto = true;
    coletados.clear();
    pontoId = null;
    ir(Tela.hoje);
  }

  // ── Instruções ──────────────────────────────────────────────────────
  void irGravacao() {
    restante = 10;
    gravando = false;
    _snrAtual = _rollSnr();
    ir(Tela.gravacao);
  }

  // ── Gravação ────────────────────────────────────────────────────────
  double _rollSnr() {
    // No real audio pipeline is wired up yet, so a session's signal quality
    // is simulated: mostly clean, occasionally noisy, so both UI states are
    // reachable without a dev-only toggle.
    final noisy = _rng.nextDouble() < 0.25;
    return noisy ? 10 + _rng.nextDouble() * 8 : 24 + _rng.nextDouble() * 12;
  }

  double get snr => _snrAtual;
  bool get snrOk => snr >= 20;

  void iniciarGravacao() {
    _timer?.cancel();
    gravando = true;
    restante = 10;
    quadro = 0;
    notifyListeners();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      final r = double.parse((restante - 0.1).clamp(0, 10).toStringAsFixed(1));
      if (r <= 0) {
        t.cancel();
        restante = 0;
        gravando = false;
        tela = Tela.revisao;
      } else {
        restante = r;
        quadro++;
      }
      notifyListeners();
    });
  }

  void pararGravacao() {
    _timer?.cancel();
    gravando = false;
    notifyListeners();
  }

  void cancelarGravacao() => ir(Tela.mapa);

  // ── Revisão ─────────────────────────────────────────────────────────
  void refazer() {
    restante = 10;
    gravando = false;
    ir(Tela.gravacao);
  }

  void aceitar() {
    if (pontoId != null) coletados.add(pontoId!);
    pontoId = null;
    ir(Tela.mapa);
  }
}
