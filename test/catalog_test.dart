import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:gs2026/data/catalog_data.dart';
import 'package:gs2026/screens/actions_screen.dart';
import 'package:gs2026/screens/catalog_screen.dart';
import 'package:gs2026/screens/catalog_form_screen.dart';

void main() {
  CatalogStore emptyStore() {
    final store = CatalogStore(seed: false);
    addTearDown(store.dispose);
    return store;
  }

  void createLine(CatalogStore store, {int number = 20}) => store.saveLine(
    number: number,
    name: 'Teste',
    origin: 'Origem',
    destination: 'Destino',
    type: 'metrô',
  );

  test(
    'CRUD mantém vínculos e recalcula a capacidade sem duplicar registros',
    () {
      final store = emptyStore();
      createLine(store);
      final lineId = store.lines.single.id;
      store.saveTrain(code: 'm-020', lineId: lineId, status: 'Em reserva');
      final trainId = store.trains.single.id;
      store.saveCarriage(
        trainId: trainId,
        number: 1,
        capacity: 200,
        occupancy: 50,
      );
      final carId = store.carriages.single.id;
      expect(store.trains.single.code, 'M-020');
      expect(store.carriages.single.people, 100);
      expect(store.capacityFor(trainId), 200);
      store.saveLine(
        id: lineId,
        number: 21,
        name: 'Nova',
        origin: 'A',
        destination: 'B',
        type: 'trem',
      );
      store.saveTrain(
        id: trainId,
        code: 'M-021',
        lineId: lineId,
        status: 'Em circulação',
      );
      store.saveCarriage(
        id: carId,
        trainId: trainId,
        number: 2,
        capacity: 300,
        occupancy: 80,
      );
      expect(store.line(store.train(trainId).lineId).number, 21);
      expect(store.lines, hasLength(1));
      expect(store.trains, hasLength(1));
      expect(store.carriages, hasLength(1));
      expect(store.capacityFor(trainId), 300);
      expect(store.carriages.single.people, 240);
      expect(() => store.delete(CatalogKind.line, lineId), throwsStateError);
      expect(() => store.delete(CatalogKind.train, trainId), throwsStateError);
      store.delete(CatalogKind.carriage, carId);
      store.delete(CatalogKind.train, trainId);
      store.delete(CatalogKind.line, lineId);
      expect(store.carriages, isEmpty);
      expect(store.trains, isEmpty);
      expect(store.lines, isEmpty);
    },
  );

  test('Valida duplicidades, referências e limites de ocupação', () {
    final store = emptyStore();
    createLine(store);
    final lineId = store.lines.single.id;
    expect(() => createLine(store), throwsStateError);
    expect(
      () => store.saveTrain(code: 'M-1', lineId: -1, status: 'Em reserva'),
      throwsStateError,
    );
    store.saveTrain(code: 'M-1', lineId: lineId, status: 'Em reserva');
    final trainId = store.trains.single.id;
    expect(
      () => store.saveTrain(code: 'm-1', lineId: lineId, status: 'Em reserva'),
      throwsStateError,
    );
    for (final occupancy in [-1, 101]) {
      expect(
        () => store.saveCarriage(
          trainId: trainId,
          number: 1,
          capacity: 200,
          occupancy: occupancy,
        ),
        throwsStateError,
      );
    }
    store.saveCarriage(
      trainId: trainId,
      number: 1,
      capacity: 200,
      occupancy: 100,
    );
    expect(
      () => store.saveCarriage(
        trainId: trainId,
        number: 1,
        capacity: 200,
        occupancy: 0,
      ),
      throwsStateError,
    );
    expect(store.carriages, hasLength(1));
    createLine(store, number: 22);
    store.saveTrain(
      id: trainId,
      code: 'M-1',
      lineId: store.lines.last.id,
      status: 'Em reserva',
    );
    store.delete(CatalogKind.line, lineId);
    expect(store.lines.single.number, 22);
  });

  Future<void> open(
    WidgetTester tester,
    Widget page, {
    double width = 402,
  }) async {
    tester.view.physicalSize = Size(width, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(home: page));
    await tester.pumpAndSettle();
  }

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  Future<void> save(WidgetTester tester) async {
    final button = find.text('Salvar cadastro');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  testWidgets('Ações abre cadastros pelo novo menu', (tester) async {
    await open(tester, const ActionsScreen());
    await tester.tap(find.text('Cadastros (CRUD)'));
    await tester.pumpAndSettle();
    expect(find.byType(CatalogScreen), findsOneWidget);
    expect(find.text('Cadastrar linha'), findsOneWidget);
  });

  testWidgets('Form de linha valida, salva, edita e exclui com feedback', (
    tester,
  ) async {
    final store = emptyStore();
    await open(tester, CatalogScreen(store: store));
    await tester.tap(find.text('Cadastrar linha'));
    await tester.pumpAndSettle();
    expect(find.byType(Form), findsOneWidget);
    await save(tester);
    expect(find.text('Preencha este campo.'), findsNWidgets(4));
    expect(store.lines, isEmpty);
    await tester.enterText(field('Número da linha'), '20');
    await tester.enterText(field('Nome da linha'), 'Teste');
    await tester.enterText(field('Estação de origem'), 'A');
    await tester.enterText(field('Estação de destino'), 'A');
    await save(tester);
    expect(find.text('Origem e destino devem ser diferentes.'), findsOneWidget);
    await tester.enterText(field('Estação de destino'), 'B');
    await save(tester);
    expect(store.lines.single.name, 'Teste');
    expect(find.text('Cadastro salvo com sucesso.'), findsOneWidget);
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();
    await tester.enterText(field('Nome da linha'), 'Atualizada');
    await save(tester);
    expect(store.lines.single.name, 'Atualizada');
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(store.lines, hasLength(1));
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Excluir').last);
    await tester.pumpAndSettle();
    expect(store.lines, isEmpty);
    expect(find.text('Cadastro excluído com sucesso.'), findsOneWidget);
  });

  testWidgets('Form de metrô exige linha e permite cancelar sem salvar', (
    tester,
  ) async {
    final store = emptyStore();
    createLine(store);
    await open(tester, CatalogScreen(store: store));
    await tester.tap(find.text('Metrôs'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cadastrar metrô'));
    await tester.pumpAndSettle();
    await tester.enterText(field('Identificação do metrô'), 'M-200');
    await save(tester);
    expect(find.text('Selecione uma opção.'), findsOneWidget);
    expect(store.trains, isEmpty);
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(store.lines.single.label).last);
    await tester.pumpAndSettle();
    await save(tester);
    expect(store.trains.single.lineId, store.lines.single.id);
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();
    await tester.enterText(field('Identificação do metrô'), 'IGNORAR');
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(store.trains.single.code, 'M-200');
  });

  testWidgets('Form de vagão valida capacidade e ocupação antes de salvar', (
    tester,
  ) async {
    final store = emptyStore();
    createLine(store);
    store.saveTrain(
      code: 'M-200',
      lineId: store.lines.single.id,
      status: 'Em reserva',
    );
    await open(tester, CatalogScreen(store: store));
    await tester.tap(find.text('Vagões'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cadastrar vagão'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('M-200').last);
    await tester.pumpAndSettle();
    await tester.enterText(field('Número do vagão'), '1');
    await tester.enterText(field('Capacidade de pessoas'), '0');
    await tester.enterText(field('Ocupação estimada (%)'), '101');
    await save(tester);
    expect(store.carriages, isEmpty);
    expect(find.text('Informe um inteiro entre 0 e 100.'), findsOneWidget);
    await tester.enterText(field('Capacidade de pessoas'), '200');
    await tester.enterText(field('Ocupação estimada (%)'), '50');
    await save(tester);
    expect(store.capacityFor(store.trains.single.id), 200);
    expect(store.carriages.single.people, 100);
  });

  for (final width in [320.0, 402.0, 1024.0]) {
    testWidgets('Cadastros e formulários sem overflow em $width', (
      tester,
    ) async {
      final store = emptyStore();
      await open(tester, CatalogScreen(store: store), width: width);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Cadastrar linha'));
      await tester.pumpAndSettle();
      expect(find.byType(CatalogFormScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(ListView).first, const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
