import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:gs2026/screens/notices_screen.dart';

void main() {
  testWidgets(
    'Comunicados novos atualizam lista, contagem e filtro de não lidos',
    (tester) async {
      final store = NoticesStore(
        initial: [
          const NoticeItem(
            'Aviso anterior',
            'Descrição anterior',
            '19/11 às 10:00',
            [1],
          ),
        ],
      );
      addTearDown(store.dispose);
      tester.view.physicalSize = const Size(402, 874);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(home: NoticesScreen(store: store)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Marcar todos como lidos'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Não lidos (0)'));
      await tester.pumpAndSettle();
      expect(find.text('Tudo em dia'), findsOneWidget);
      store.add(
        const NoticeItem(
          'REF-001 · Reforço solicitado',
          '1 composição solicitada',
          '19/11 às 10:30',
          [3],
          warning: 'solicitação de reforço simulada',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Todos (2)'), findsOneWidget);
      expect(find.text('Não lidos (1)'), findsOneWidget);
      expect(find.text('REF-001 · Reforço solicitado'), findsOneWidget);
      expect(find.text('Aviso anterior'), findsNothing);
      expect(find.text('NOVO'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
