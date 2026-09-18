import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:record/record.dart' show Amplitude;

import '../data/pacientes_mock.dart';
import '../data/pontos_ausculta.dart';
import '../models/paciente.dart';
import '../models/ponto.dart';
import '../services/audio_player_service.dart';
import '../services/audio_recorder_service.dart';
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
  bool micTestando = false;
  String? erroMicrofone;
  String ctxSintomas = '';
  bool ctxOxigenio = false;
  String ctxRuido = '';

  // Gravação — captura real via microfone (o estetoscópio digital sai como
  // entrada de áudio USB-C padrão, sem SDK proprietário).
  final AudioRecorderService _recorderService = AudioRecorderService();
  final AudioPlayerService playerService = AudioPlayerService();
  StreamSubscription<Amplitude>? _ampSub;
  bool gravando = false;
  double restante = 10;
  int quadro = 0;
  double _snrAtual = 27;
  String? erroGravacao;
  Timer? _timer;

  /// Caminho do arquivo WAV da captura em revisão (nulo fora da tela 07).
  String? caminhoGravado;

  // Sessão offline de 12h (ver aviso LGPD da tela de login).
  DateTime? _sessaoIniciadaEm;

  @override
  void dispose() {
    _timer?.cancel();
    _ampSub?.cancel();
    _recorderService.dispose();
    playerService.dispose();
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
  void entrar() {
    _sessaoIniciadaEm = DateTime.now();
    ir(Tela.hoje);
  }

  void sair() {
    _sessaoIniciadaEm = null;
    reiniciar();
  }

  /// Tempo restante da sessão offline de 12h, formatado "Xh Ymin".
  String get sessaoExpiraEm {
    final inicio = _sessaoIniciadaEm;
    if (inicio == null) return '—';
    final restante = inicio.add(const Duration(hours: 12)).difference(DateTime.now());
    if (restante.isNegative) return 'expirada';
    return '${restante.inHours} h ${restante.inMinutes % 60} min';
  }

  // ── Pacientes ────────────────────────────────────────────────────────
  int get totalVisitas => pacientes.length;
  int get concluidas => coletados.isEmpty ? 0 : 1; // demo counter, matches prototype's fixed "1"

  /// Visitas ainda não sincronizadas (ícone de nuvem/enviando/offline na
  /// lista) — o que fica "guardado no aparelho" ao sair da conta.
  int get visitasNaFila => pacientes.where((p) => p.sync != SyncBase.nuvem).length;

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
  /// Pede permissão de microfone e abre/fecha uma captura de ~400ms para
  /// confirmar que o pipeline de áudio (inclusive o sensor USB-C) responde
  /// de ponta a ponta — não é uma checagem acústica de qualidade do sinal,
  /// só de que o dispositivo de entrada está acessível.
  Future<void> testarMicrofone() async {
    micTestando = true;
    erroMicrofone = null;
    notifyListeners();

    try {
      final permitido = await _recorderService.temPermissao();
      if (!permitido) {
        erroMicrofone = 'Permissão de microfone negada.';
        micTestado = false;
      } else {
        await _recorderService.iniciarGravacao(prefixoArquivo: 'teste');
        await Future.delayed(const Duration(milliseconds: 400));
        await _recorderService.descartarGravacao();
        micTestado = true;
      }
    } catch (_) {
      erroMicrofone = 'Não foi possível acessar o microfone.';
      micTestado = false;
    }

    micTestando = false;
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
    erroGravacao = null;
    ir(Tela.gravacao);
  }

  // ── Gravação ────────────────────────────────────────────────────────
  /// Aproxima um "nível de sinal" 0–40 a partir da amplitude em dBFS do
  /// microfone. Isto NÃO é SNR acústico real (precisaria de estimativa de
  /// piso de ruído / análise espectral) — é só o nível do que está entrando
  /// no microfone, reaproveitando a escala e o limiar (20) já desenhados.
  double _nivelDeAmplitude(double dbfs) {
    const chao = -50.0;
    const teto = 0.0;
    final normalizado = (dbfs.clamp(chao, teto) - chao) / (teto - chao);
    return normalizado * 40;
  }

  double get snr => _snrAtual;
  bool get snrOk => snr >= 20;

  Future<void> iniciarGravacao() async {
    _timer?.cancel();
    await _ampSub?.cancel();
    erroGravacao = null;

    try {
      await _recorderService.iniciarGravacao(prefixoArquivo: pontoId);
    } on AudioRecorderPermissionException {
      erroGravacao = 'Permissão de microfone negada.';
      notifyListeners();
      return;
    } catch (_) {
      erroGravacao = 'Não foi possível iniciar a gravação.';
      notifyListeners();
      return;
    }

    gravando = true;
    restante = 10;
    quadro = 0;
    notifyListeners();

    _ampSub = _recorderService.streamAmplitude().listen((amp) {
      _snrAtual = _nivelDeAmplitude(amp.current);
      notifyListeners();
    });

    _timer = Timer.periodic(const Duration(milliseconds: 100), (t) async {
      final r = double.parse((restante - 0.1).clamp(0, 10).toStringAsFixed(1));
      quadro++;
      if (r <= 0) {
        t.cancel();
        restante = 0;
        await _finalizarGravacao();
      } else {
        restante = r;
        notifyListeners();
      }
    });
  }

  Future<void> _finalizarGravacao() async {
    await _ampSub?.cancel();
    _ampSub = null;
    gravando = false;
    caminhoGravado = await _recorderService.pararGravacao();
    tela = Tela.revisao;
    notifyListeners();
  }

  /// Toque manual no botão enquanto grava: interrompe e descarta a captura
  /// parcial (o usuário toca de novo para começar uma gravação nova do
  /// zero) — não navega para a revisão, igual ao comportamento original.
  Future<void> pararGravacao() async {
    _timer?.cancel();
    await _ampSub?.cancel();
    _ampSub = null;
    gravando = false;
    await _recorderService.descartarGravacao();
    notifyListeners();
  }

  Future<void> cancelarGravacao() async {
    if (gravando) {
      _timer?.cancel();
      await _ampSub?.cancel();
      _ampSub = null;
      gravando = false;
      await _recorderService.descartarGravacao();
    }
    ir(Tela.mapa);
  }

  // ── Revisão ─────────────────────────────────────────────────────────
  Future<void> refazer() async {
    final caminho = caminhoGravado;
    caminhoGravado = null;
    if (caminho != null) {
      final arquivo = File(caminho);
      if (await arquivo.exists()) await arquivo.delete();
    }
    restante = 10;
    gravando = false;
    ir(Tela.gravacao);
  }

  void aceitar() {
    if (pontoId != null) coletados.add(pontoId!);
    pontoId = null;
    caminhoGravado = null;
    ir(Tela.mapa);
  }
}
