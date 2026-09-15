import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../state/tela.dart';
import '../theme/tokens.dart';
import '../utils/formatters.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/info_banner.dart';
import '../widgets/screen_header.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _nome = TextEditingController();
  final _cpf = TextEditingController();
  final _rg = TextEditingController();
  final _nasc = TextEditingController();

  @override
  void dispose() {
    _nome.dispose();
    _cpf.dispose();
    _rg.dispose();
    _nasc.dispose();
    super.dispose();
  }

  void _salvar(AppState state) {
    final erros = state.errosForm;
    state.salvarPaciente();
    if (erros.isEmpty) {
      _nome.clear();
      _cpf.clear();
      _rg.clear();
      _nasc.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final erros = state.tentouSalvar ? state.errosForm : const <String, String>{};

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              onBack: () => state.ir(Tela.hoje),
              title: 'Cadastrar paciente',
              subtitle: 'Dados de identificação',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  AppTextField(
                    label: 'Nome completo',
                    controller: _nome,
                    onChanged: state.setFormNome,
                    hint: 'Maria Aparecida da Silva',
                    errorText: erros['nome'],
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'CPF',
                    controller: _cpf,
                    onChanged: state.setFormCpf,
                    hint: '000.000.000-00',
                    keyboardType: TextInputType.number,
                    inputFormatters: [CpfInputFormatter()],
                    monospace: true,
                    errorText: erros['cpf'],
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'RG',
                    controller: _rg,
                    onChanged: state.setFormRg,
                    hint: '00.000.000-0',
                    inputFormatters: [RgInputFormatter()],
                    monospace: true,
                    errorText: erros['rg'],
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'Data de nascimento',
                    controller: _nasc,
                    onChanged: state.setFormNasc,
                    hint: 'DD/MM/AAAA',
                    keyboardType: TextInputType.number,
                    inputFormatters: [NascInputFormatter()],
                    monospace: true,
                    errorText: erros['nasc'],
                  ),
                  const SizedBox(height: 14),
                  const LabelBanner(
                    bg: AppColors.chip,
                    labelColor: AppColors.acc,
                    textColor: AppColors.chipTxt,
                    label: 'LGPD',
                    text: 'Dados gravados criptografados no aparelho e vinculados ao prontuário '
                        'no próximo envio.',
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              decoration: const BoxDecoration(
                color: AppColors.surf,
                border: Border(top: BorderSide(color: AppColors.line)),
              ),
              child: PrimaryButton(label: 'Salvar paciente', onPressed: () => _salvar(state)),
            ),
          ],
        ),
      ),
    );
  }
}
