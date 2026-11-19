import 'package:flutter/foundation.dart';

import 'metro_data.dart';
import 'train_data.dart';

class CatalogLine {
  final int id;
  final int number;
  final String name;
  final String origin;
  final String destination;
  final String type;
  const CatalogLine({
    required this.id,
    required this.number,
    required this.name,
    required this.origin,
    required this.destination,
    required this.type,
  });
  String get label => 'Linha $number - $name';
}

class CatalogTrain {
  final int id;
  final String code;
  final int lineId;
  final String status;
  const CatalogTrain({
    required this.id,
    required this.code,
    required this.lineId,
    required this.status,
  });
}

class CatalogCarriage {
  final int id;
  final int trainId;
  final int number;
  final int capacity;
  final int occupancy;
  const CatalogCarriage({
    required this.id,
    required this.trainId,
    required this.number,
    required this.capacity,
    required this.occupancy,
  });
  int get people => (capacity * occupancy / 100).round();
}

enum CatalogKind { line, train, carriage }

/// Cadastros de demonstração em memória, mantidos durante a execução do app.
class CatalogStore extends ChangeNotifier {
  static final instance = CatalogStore();
  final List<CatalogLine> _lines = [];
  final List<CatalogTrain> _trains = [];
  final List<CatalogCarriage> _carriages = [];
  int _nextLine = 1;
  int _nextTrain = 1;
  int _nextCarriage = 1;

  CatalogStore({bool seed = true}) {
    if (!seed) return;
    for (final line in metroLines) {
      _lines.add(
        CatalogLine(
          id: _nextLine++,
          number: line.number,
          name: line.colorName,
          origin: line.stations.first.name,
          destination: line.stations.last.name,
          type: line.type,
        ),
      );
    }
    final source = metroLines.firstWhere((line) => line.number == 3);
    final train = MetroTrain.simulated(source, source.stations.first);
    final trainId = _nextTrain++;
    _trains.add(
      CatalogTrain(
        id: trainId,
        code: train.code,
        lineId: _lines.firstWhere((line) => line.number == 3).id,
        status: 'Em circulação',
      ),
    );
    for (final car in train.carriages) {
      _carriages.add(
        CatalogCarriage(
          id: _nextCarriage++,
          trainId: trainId,
          number: car.number,
          capacity: car.capacity,
          occupancy: car.occupancy,
        ),
      );
    }
  }

  List<CatalogLine> get lines => List.unmodifiable(_lines);
  List<CatalogTrain> get trains => List.unmodifiable(_trains);
  List<CatalogCarriage> get carriages => List.unmodifiable(_carriages);
  CatalogLine line(int id) => _lines.firstWhere((line) => line.id == id);
  CatalogTrain train(int id) => _trains.firstWhere((train) => train.id == id);
  List<CatalogCarriage> carsFor(int trainId) =>
      _carriages.where((car) => car.trainId == trainId).toList()
        ..sort((a, b) => a.number.compareTo(b.number));
  int capacityFor(int trainId) =>
      carsFor(trainId).fold(0, (total, car) => total + car.capacity);

  static const statuses = ['Em circulação', 'Em reserva', 'Em manutenção'];
  static const types = ['metrô', 'trem', 'monotrilho'];

  void saveLine({
    int? id,
    required int number,
    required String name,
    required String origin,
    required String destination,
    required String type,
  }) {
    if (number <= 0 ||
        name.trim().isEmpty ||
        origin.trim().isEmpty ||
        destination.trim().isEmpty) {
      throw StateError('Preencha os dados da linha com valores válidos.');
    }
    if (!types.contains(type)) {
      throw StateError('Selecione um tipo de transporte válido.');
    }
    if (origin.trim().toLowerCase() == destination.trim().toLowerCase()) {
      throw StateError('Origem e destino devem ser diferentes.');
    }
    if (_lines.any((line) => line.id != id && line.number == number)) {
      throw StateError('Já existe uma linha com este número.');
    }
    if (id != null && !_lines.any((line) => line.id == id)) {
      throw StateError('Linha não encontrada.');
    }
    final value = CatalogLine(
      id: id ?? _nextLine++,
      number: number,
      name: name.trim(),
      origin: origin.trim(),
      destination: destination.trim(),
      type: type,
    );
    if (id == null) {
      _lines.add(value);
    } else {
      _lines[_lines.indexWhere((line) => line.id == id)] = value;
    }
    notifyListeners();
  }

  void saveTrain({
    int? id,
    required String code,
    required int lineId,
    required String status,
  }) {
    if (code.trim().isEmpty) {
      throw StateError('Informe a identificação do metrô.');
    }
    if (!_lines.any((line) => line.id == lineId)) {
      throw StateError('Selecione uma linha cadastrada.');
    }
    if (!statuses.contains(status)) {
      throw StateError('Selecione um status válido.');
    }
    final normalized = code.trim().toUpperCase();
    if (_trains.any((train) => train.id != id && train.code == normalized)) {
      throw StateError('Já existe um metrô com esta identificação.');
    }
    if (id != null && !_trains.any((train) => train.id == id)) {
      throw StateError('Metrô não encontrado.');
    }
    final value = CatalogTrain(
      id: id ?? _nextTrain++,
      code: normalized,
      lineId: lineId,
      status: status,
    );
    if (id == null) {
      _trains.add(value);
    } else {
      _trains[_trains.indexWhere((train) => train.id == id)] = value;
    }
    notifyListeners();
  }

  void saveCarriage({
    int? id,
    required int trainId,
    required int number,
    required int capacity,
    required int occupancy,
  }) {
    if (!_trains.any((train) => train.id == trainId)) {
      throw StateError('Selecione um metrô cadastrado.');
    }
    if (number <= 0 || capacity <= 0 || occupancy < 0 || occupancy > 100) {
      throw StateError(
        'Número e capacidade devem ser positivos; ocupação deve estar entre 0 e 100.',
      );
    }
    if (_carriages.any(
      (car) => car.id != id && car.trainId == trainId && car.number == number,
    )) {
      throw StateError('Este metrô já possui um vagão com este número.');
    }
    if (id != null && !_carriages.any((car) => car.id == id)) {
      throw StateError('Vagão não encontrado.');
    }
    final value = CatalogCarriage(
      id: id ?? _nextCarriage++,
      trainId: trainId,
      number: number,
      capacity: capacity,
      occupancy: occupancy,
    );
    if (id == null) {
      _carriages.add(value);
    } else {
      _carriages[_carriages.indexWhere((car) => car.id == id)] = value;
    }
    notifyListeners();
  }

  void delete(CatalogKind kind, int id) {
    switch (kind) {
      case CatalogKind.line:
        if (_trains.any((train) => train.lineId == id)) {
          throw StateError(
            'Remova ou transfira os metrôs desta linha antes de excluí-la.',
          );
        }
        _lines.removeWhere((line) => line.id == id);
      case CatalogKind.train:
        if (_carriages.any((car) => car.trainId == id)) {
          throw StateError(
            'Remova ou transfira os vagões deste metrô antes de excluí-lo.',
          );
        }
        _trains.removeWhere((train) => train.id == id);
      case CatalogKind.carriage:
        _carriages.removeWhere((car) => car.id == id);
    }
    notifyListeners();
  }
}
