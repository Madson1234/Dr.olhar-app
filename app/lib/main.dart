import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/cadastro_screen.dart';
import 'screens/contexto_screen.dart';
import 'screens/gravacao_screen.dart';
import 'screens/instrucoes_screen.dart';
import 'screens/login_screen.dart';
import 'screens/mapa_screen.dart';
import 'screens/microfone_screen.dart';
import 'screens/pacientes_screen.dart';
import 'screens/revisao_screen.dart';
import 'state/app_state.dart';
import 'state/tela.dart';
import 'theme/tokens.dart';

void main() {
  runApp(const AppAgenteComunitario());
}

class AppAgenteComunitario extends StatelessWidget {
  const AppAgenteComunitario({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'Dr. Olhar · Agente Comunitário',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.bg,
          fontFamily: 'Public Sans',
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.acc,
            primary: AppColors.acc,
          ),
        ),
        home: const _RootSwitcher(),
      ),
    );
  }
}

/// Swaps the visible screen based on [AppState.tela] — the flow is a single
/// state machine, not a Navigator stack, mirroring the design prototype.
class _RootSwitcher extends StatelessWidget {
  const _RootSwitcher();

  @override
  Widget build(BuildContext context) {
    final tela = context.select((AppState s) => s.tela);
    final Widget screen = switch (tela) {
      Tela.login => const LoginScreen(),
      Tela.hoje => const PacientesScreen(),
      Tela.cadastro => const CadastroScreen(),
      Tela.microfone => const MicrofoneScreen(),
      Tela.contexto => const ContextoScreen(),
      Tela.mapa => const MapaScreen(),
      Tela.instrucoes => const InstrucoesScreen(),
      Tela.gravacao => const GravacaoScreen(),
      Tela.revisao => const RevisaoScreen(),
    };
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: KeyedSubtree(key: ValueKey(tela), child: screen),
    );
  }
}
