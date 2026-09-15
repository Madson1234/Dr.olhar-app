import '../models/paciente.dart';

/// Mock agenda for the day — stands in for the real patient/visit API.
const List<Paciente> pacientesMock = [
  Paciente(id: 1, nome: 'Raimunda Alves', detalhe: '74 anos · Sítio Boa Vista', hora: '08:20', sync: SyncBase.nuvem),
  Paciente(id: 2, nome: 'José Nogueira', detalhe: '68 anos · Vila do Riacho', hora: '10:00', sync: SyncBase.enviando),
  Paciente(id: 3, nome: 'Antônia Ferreira', detalhe: '81 anos · Assentamento Novo', hora: '13:30', sync: SyncBase.enviando),
  Paciente(id: 4, nome: 'Sebastião Lima', detalhe: '59 anos · Sítio Boa Vista', hora: '15:45', sync: SyncBase.enviando),
];
