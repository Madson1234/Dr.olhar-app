import 'package:flutter_test/flutter_test.dart';

import 'package:app_agente_comunitario/main.dart';

void main() {
  testWidgets('Login screen shows the Dr. Olhar brand and login button', (WidgetTester tester) async {
    await tester.pumpWidget(const AppAgenteComunitario());

    expect(find.text('Dr. Olhar'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });

  testWidgets('Entrar navigates to the Pacientes screen', (WidgetTester tester) async {
    await tester.pumpWidget(const AppAgenteComunitario());

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('Pacientes'), findsOneWidget);
  });
}
