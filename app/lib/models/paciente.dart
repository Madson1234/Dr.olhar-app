/// Baseline upload state a patient visit starts in. The header chip and the
/// per-row icon layer connectivity on top of this (see AppState.online).
enum SyncBase { nuvem, enviando }

class Paciente {
  final int id;
  final String nome;
  final String detalhe;
  final String hora;
  final SyncBase sync;

  const Paciente({
    required this.id,
    required this.nome,
    required this.detalhe,
    required this.hora,
    required this.sync,
  });
}
