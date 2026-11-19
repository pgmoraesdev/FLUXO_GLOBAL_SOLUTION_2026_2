import 'package:flutter/foundation.dart';

import 'metro_data.dart';

class ReinforcementRequest {
  final int number;
  final MetroLine line;
  final int trainCount;
  final DateTime createdAt;

  const ReinforcementRequest({
    required this.number,
    required this.line,
    required this.trainCount,
    required this.createdAt,
  });

  String get code => 'REF-${number.toString().padLeft(3, '0')}';
}

/// Solicitações simuladas, mantidas apenas durante a execução do aplicativo.
/// Nenhum comando é enviado à operação ou a uma frota real.
class ReinforcementRequests extends ChangeNotifier {
  static final instance = ReinforcementRequests();
  final List<ReinforcementRequest> _requests = [];

  List<ReinforcementRequest> get requests =>
      List.unmodifiable(_requests.reversed);

  bool hasRequestFor(MetroLine line) =>
      _requests.any((request) => request.line.number == line.number);

  ReinforcementRequest submit(MetroLine line, int trainCount) {
    if (trainCount < 1 || trainCount > 3) {
      throw ArgumentError.value(
        trainCount,
        'trainCount',
        'Selecione de 1 a 3 composições.',
      );
    }
    if (hasRequestFor(line)) {
      throw StateError('Esta linha já possui uma solicitação nesta sessão.');
    }
    final request = ReinforcementRequest(
      number: _requests.length + 1,
      line: line,
      trainCount: trainCount,
      createdAt: DateTime.now(),
    );
    _requests.add(request);
    notifyListeners();
    return request;
  }
}
