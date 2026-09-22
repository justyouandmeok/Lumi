import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/main.dart';
import 'package:nexo/state/app_state.dart';

void main() {
  testWidgets('Lumi muestra Inicio', (tester) async {
    await tester.pumpWidget(NexoApp(store: AppState()));
    expect(find.text('Lumi'), findsOneWidget);
  });
}
