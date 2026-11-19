import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:gs2026/data/train_data.dart';
import 'package:gs2026/screens/line_detail_screen.dart';
import 'package:gs2026/screens/lines_screen.dart';
import 'package:gs2026/screens/train_detail_screen.dart';

void main() {
  final line = lineByNumber(3);
  final station = line.stations.first;
  final train = MetroTrain.simulated(line, station);

  test('Totais da composição correspondem à soma dos vagões', () {
    expect(train.capacity, 1200);
    expect(train.people, 864);
    expect(train.occupancy, 72);
    expect(train.recommended.number, 5);
    expect(train.recommended.people, 116);
    expect(train.nextStation, line.stations[1]);
    expect(train.destination, line.stations.last.name);
  });

  test('No terminal final o trem segue no sentido inverso', () {
    final reverse = MetroTrain.simulated(line, line.stations.last);
    expect(reverse.destination, station.name);
    expect(reverse.nextStation, line.stations[line.stations.length - 2]);
    expect(reverse.code, isNot(train.code));
  });

  testWidgets('Estação abre composição vinculada e permite retornar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: LineDetailScreen(line: line, initialQuery: station.name),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver metrô e vagões'));
    await tester.pumpAndSettle();
    expect(find.byType(TrainDetailScreen), findsOneWidget);
    expect(find.text('Na estação ${station.name}'), findsOneWidget);
    expect(find.text('72%'), findsOneWidget);
    expect(find.text('Dados simulados'), findsOneWidget);
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    expect(find.byType(LineDetailScreen), findsOneWidget);
  });

  for (final width in [320.0, 402.0, 1024.0]) {
    testWidgets('Vagões e seleção funcionam com largura $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(home: TrainDetailScreen(train: train)),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Prefira o vagão 05'), findsOneWidget);
      await tester.tap(find.text('01'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Vagão 01 · muito alta'));
      expect(find.text('Vagão 01 · muito alta'), findsOneWidget);
      expect(
        find.text('176 pessoas · 24 lugares até a capacidade'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
