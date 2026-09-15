import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../state/tela.dart';
import '../theme/tokens.dart';
import '../widgets/app_button.dart';
import '../widgets/screen_header.dart';

class ContextoScreen extends StatefulWidget {
  const ContextoScreen({super.key});

  @override
  State<ContextoScreen> createState() => _ContextoScreenState();
}

class _ContextoScreenState extends State<ContextoScreen> {
  final _sintomas = TextEditingController();
  final _ruido = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    _sintomas.text = state.ctxSintomas;
    _ruido.text = state.ctxRuido;
  }

  @override
  void dispose() {
    _sintomas.dispose();
    _ruido.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              onBack: () => state.ir(Tela.microfone),
              title: 'Contexto da coleta',
              subtitle: state.pacienteNomeAtual,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('Sintomas observáveis', style: AppText.ps(12, weight: FontWeight.w600, color: AppColors.mut)),
                  const SizedBox(height: 7),
                  SizedBox(
                    height: 56,
                    child: TextField(
                      controller: _sintomas,
                      onChanged: state.setCtxSintomas,
                      style: AppText.ps(16, weight: FontWeight.w500),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: AppColors.surf,
                        hintText: 'Não informado',
                        hintStyle: AppText.ps(16, weight: FontWeight.w500, color: AppColors.mut),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.field),
                          borderSide: const BorderSide(color: AppColors.line, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.field),
                          borderSide: const BorderSide(color: AppColors.line, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.field),
                          borderSide: const BorderSide(color: AppColors.acc, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: AppColors.surf,
                      border: Border.all(color: AppColors.line),
                      borderRadius: BorderRadius.circular(AppRadii.cardSmall),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Paciente usa oxigênio', style: AppText.ps(15, weight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text('Registre a condição observada agora.', style: AppText.ps(12.5, height: 1.35, color: AppColors.mut)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        _OxigenioToggle(value: state.ctxOxigenio, onChanged: (_) => state.alternarOxigenio()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Ruído e observações do ambiente', style: AppText.ps(12, weight: FontWeight.w600, color: AppColors.mut)),
                  const SizedBox(height: 7),
                  TextField(
                    controller: _ruido,
                    onChanged: state.setCtxRuido,
                    maxLines: 4,
                    style: AppText.ps(15, height: 1.45),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surf,
                      hintText: 'Ex.: televisão ligada na sala ao lado',
                      hintStyle: AppText.ps(15, height: 1.45, color: AppColors.mut),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.field),
                        borderSide: const BorderSide(color: AppColors.line, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.field),
                        borderSide: const BorderSide(color: AppColors.line, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.field),
                        borderSide: const BorderSide(color: AppColors.acc, width: 1.5),
                      ),
                    ),
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
              child: PrimaryButton(label: 'Continuar', onPressed: () => state.ir(Tela.mapa)),
            ),
          ],
        ),
      ),
    );
  }
}

class _OxigenioToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _OxigenioToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: value,
      label: 'Paciente usa oxigênio',
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 52,
          height: 30,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: value ? AppColors.acc : AppColors.legendPending,
            borderRadius: BorderRadius.circular(15),
          ),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Color(0x470F1720), blurRadius: 4, offset: Offset(0, 1))],
            ),
          ),
        ),
      ),
    );
  }
}
