import 'metro_data.dart';

class TrainCarriage {
  final int number;
  final int occupancy;
  final int capacity;

  const TrainCarriage(this.number, this.occupancy, {this.capacity = 200});

  String get label => number.toString().padLeft(2, '0');
  int get people => (capacity * occupancy / 100).round();
}

/// Composição simulada vinculada à linha e à estação selecionadas.
/// A lotação da estação é independente da lotação do trem.
class MetroTrain {
  final String code;
  final MetroLine line;
  final Station station;
  final Station nextStation;
  final String destination;
  final List<TrainCarriage> carriages;

  const MetroTrain({
    required this.code,
    required this.line,
    required this.station,
    required this.nextStation,
    required this.destination,
    required this.carriages,
  });

  factory MetroTrain.simulated(MetroLine line, Station station) {
    final index = line.stations.indexOf(station);
    if (index < 0 || line.stations.length < 2) {
      throw ArgumentError(
        'A estação deve pertencer a uma linha com ao menos duas estações.',
      );
    }
    final reverse = index == line.stations.length - 1;
    return MetroTrain(
      code: 'M-${(line.number * 100 + index + 1).toString().padLeft(3, '0')}',
      line: line,
      station: station,
      nextStation: line.stations[index + (reverse ? -1 : 1)],
      destination: reverse ? line.stations.first.name : line.stations.last.name,
      carriages: const [
        TrainCarriage(1, 88),
        TrainCarriage(2, 82),
        TrainCarriage(3, 75),
        TrainCarriage(4, 66),
        TrainCarriage(5, 58),
        TrainCarriage(6, 63),
      ],
    );
  }

  int get capacity => carriages.fold(0, (total, car) => total + car.capacity);
  int get people => carriages.fold(0, (total, car) => total + car.people);
  int get occupancy => capacity == 0 ? 0 : (people * 100 / capacity).round();
  TrainCarriage get recommended => carriages.reduce(
    (best, car) => car.occupancy < best.occupancy ? car : best,
  );
}
