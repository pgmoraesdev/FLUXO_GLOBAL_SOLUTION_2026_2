import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:gs2026/data/reinforcement_data.dart';
import 'package:gs2026/screens/notices_screen.dart';
import 'package:gs2026/screens/actions_screen.dart';
import 'package:gs2026/screens/home_screen.dart';
import 'package:gs2026/screens/lines_screen.dart';
import 'package:gs2026/screens/reinforcement_screen.dart';

void main() {
  test('Solicitações preservam linha e quantidade e avisam os ouvintes', () {
    final notices = NoticesStore(initial: []);
    addTearDown(notices.dispose);
    final store = ReinforcementRequests(noticeStore: notices);
    addTearDown(store.dispose);
    var notifications = 0;
    store.addListener(() => notifications++);
    final first = store.submit(lineByNumber(3), 2);
    final second = store.submit(lineByNumber(1), 1);
    expect(first.code, 'REF-001');
    expect(first.line.number, 3);
    expect(first.trainCount, 2);
    expect(notices.items, hasLength(2));
    expect(notices.items.first.title, contains(second.code));
    expect(notices.items.last.title, contains(first.code));
    expect(notices.items.last.lines, [3]);
    expect(
      notices.items.last.description,
      contains('2 composições adicionais solicitadas'),
    );
    expect(notices.items.last.warning, 'solicitação de reforço simulada');
    expect(store.requests, [second, first]);
    expect(notifications, 2);
    expect(() => store.requests.clear(), throwsUnsupportedError);
  });

  test('Duplicidade e quantidade inválida não criam registros', () {
    final notices = NoticesStore(initial: []);
    addTearDown(notices.dispose);
    final store = ReinforcementRequests(noticeStore: notices);
    addTearDown(store.dispose);
    expect(() => store.submit(lineByNumber(1), 0), throwsArgumentError);
    expect(() => store.submit(lineByNumber(1), 4), throwsArgumentError);
    expect(store.requests, isEmpty);
    expect(notices.items, isEmpty);
    store.submit(lineByNumber(1), 1);
    expect(() => store.submit(lineByNumber(1), 2), throwsStateError);
    expect(store.requests, hasLength(1));
    expect(notices.items, hasLength(1));
  });

  Future<void> open(
    WidgetTester tester,
    Widget page, {
    double width = 402,
  }) async {
    tester.view.physicalSize = Size(width, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(home: page));
    await tester.pumpAndSettle();
  }

  testWidgets('Menu Ações abre hub antes do formulário de reforço', (
    tester,
  ) async {
    await open(tester, const HomeScreen());
    await tester.tap(find.text('Ações'));
    await tester.pumpAndSettle();
    expect(find.byType(ActionsScreen), findsOneWidget);
    expect(find.byType(ReinforcementScreen), findsNothing);
    expect(find.text('Monitorar linhas e estações'), findsOneWidget);
    await tester.tap(find.text('Chamar reforço de frota'));
    await tester.pumpAndSettle();
    expect(find.byType(ReinforcementScreen), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Solicitar reforço'),
    );
    expect(button.onPressed, isNull);
    await tester.tap(find.byType(DropdownButtonFormField<MetroLine>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(lineByNumber(1).name).last);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Solicitar reforço'),
          )
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('Cancelar não publica; confirmar cria comunicado e abre a tela', (
    tester,
  ) async {
    final notices = NoticesStore(initial: []);
    addTearDown(notices.dispose);
    final store = ReinforcementRequests(noticeStore: notices);
    addTearDown(store.dispose);
    await open(tester, ActionsScreen(requests: store));
    await tester.tap(find.text('Chamar reforço de frota'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<MetroLine>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(lineByNumber(1).name).last);
    await tester.pumpAndSettle();
    final submit = find.widgetWithText(FilledButton, 'Solicitar reforço');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(store.requests, isEmpty);
    expect(notices.items, isEmpty);
    await tester.tap(submit);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();
    expect(store.requests.single.line.number, 1);
    expect(notices.items, hasLength(1));
    expect(find.byType(NoticesScreen), findsOneWidget);
    expect(find.byType(ReinforcementScreen), findsNothing);
    expect(find.text(notices.items.single.title), findsOneWidget);
    expect(find.text('NOVO'), findsOneWidget);
    expect(find.text('solicitação de reforço simulada'), findsOneWidget);
    await tester.tap(find.text('Marcar como lido'));
    await tester.pumpAndSettle();
    expect(find.text('NOVO'), findsNothing);
  });

  for (final width in [320.0, 402.0, 1024.0]) {
    testWidgets('Ações e reforço sem overflow na largura $width', (
      tester,
    ) async {
      final notices = NoticesStore(initial: []);
      addTearDown(notices.dispose);
      final store = ReinforcementRequests(noticeStore: notices);
      addTearDown(store.dispose);
      await open(tester, ActionsScreen(requests: store), width: width);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Chamar reforço de frota'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(ListView).first, const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
