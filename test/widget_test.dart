import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gs2026/main.dart';
import 'package:gs2026/screens/home_screen.dart';
import 'package:gs2026/screens/line_detail_screen.dart';
import 'package:gs2026/screens/lines_screen.dart';
import 'package:gs2026/screens/events_screen.dart';
import 'package:gs2026/screens/notices_screen.dart';

void main() {
  Future<void> openHome(
    WidgetTester tester, {
    Size size = const Size(402, 874),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
  }

  testWidgets('Home abre com dados compartilhados e três linhas em destaque', (
    tester,
  ) async {
    await openHome(tester);
    expect(find.text('Visão geral'), findsOneWidget);
    expect(find.text('Simulação', findRichText: true), findsNothing);
    expect(find.text('● Simulação'), findsOneWidget);
    expect(find.text('${metroLines.length}'), findsOneWidget);
    expect(find.text('${metroLines.length} linhas'), findsOneWidget);
    expect(find.text('Azul'), findsOneWidget);
    expect(find.text('Verde'), findsOneWidget);
    expect(find.text('Vermelha'), findsOneWidget);
    final stations = metroLines.expand((line) => line.stations).toList();
    final average =
        (stations.fold<int>(0, (sum, station) => sum + station.occupancy) /
                stations.length)
            .round();
    expect(find.text('$average%'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Busca encontra estação fora das linhas em destaque e abre detalhes filtrados',
    (tester) async {
      await openHome(tester);
      await tester.enterText(find.byType(TextField), 'Guarulhos');
      await tester.pumpAndSettle();
      expect(find.text('Jade'), findsOneWidget);
      expect(find.text('Azul'), findsNothing);
      await tester.tap(find.text('Jade'));
      await tester.pumpAndSettle();
      expect(find.byType(LineDetailScreen), findsOneWidget);
      expect(find.text('2 estações'), findsOneWidget);
      expect(find.text('Guarulhos-Cecap'), findsOneWidget);
      expect(find.text('Aeroporto-Guarulhos'), findsOneWidget);
      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Jade'), findsOneWidget);
    },
  );

  testWidgets('Busca por linha e estado vazio funcionam', (tester) async {
    await openHome(tester);
    await tester.enterText(find.byType(TextField), '  Linha 13  ');
    await tester.pumpAndSettle();
    expect(find.text('Jade'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'inexistente');
    await tester.pumpAndSettle();
    expect(find.text('Nenhuma linha ou estação encontrada.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();
    expect(find.text('Azul'), findsOneWidget);
  });

  testWidgets('Navegação abre linhas e permite voltar para home', (
    tester,
  ) async {
    await openHome(tester);
    await tester.tap(find.text('Linhas'));
    await tester.pumpAndSettle();
    expect(find.byType(LinesScreen), findsOneWidget);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    await tester.tap(find.byTooltip('Ver comunicados'));
    await tester.pumpAndSettle();
    expect(find.byType(NoticesScreen), findsOneWidget);
  });

  testWidgets('Alerta utiliza o próximo evento e abre eventos', (tester) async {
    await openHome(tester);
    final today = DateUtils.dateOnly(DateTime.now());
    final events =
        upcomingEvents.where((event) => !event.date.isBefore(today)).toList()
          ..sort((a, b) => a.date.compareTo(b.date));
    if (events.isEmpty) {
      expect(find.text('Atenção à demanda'), findsNothing);
      return;
    }
    final alert = find.text('Atenção à demanda');
    await tester.scrollUntilVisible(
      alert,
      150,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.text('${events.first.title} · ${events.first.when}'),
      findsOneWidget,
    );
    await tester.tap(alert);
    await tester.pumpAndSettle();
    expect(find.byType(EventsScreen), findsOneWidget);
  });

  for (final size in [
    const Size(320, 568),
    const Size(402, 874),
    const Size(1024, 768),
  ]) {
    testWidgets('Home sem overflow em ${size.width} x ${size.height}', (
      tester,
    ) async {
      await openHome(tester, size: size);
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(ListView).first, const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
