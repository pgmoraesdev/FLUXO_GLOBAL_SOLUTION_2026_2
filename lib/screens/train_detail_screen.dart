import 'package:material_ui/material_ui.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../data/train_data.dart';
import 'lines_screen.dart';

Color _carColor(int occupancy) => occupancy < 60
    ? tealDark
    : occupancy < 75
    ? const Color(0xFF2866C7)
    : occupancy < 85
    ? const Color(0xFF986609)
    : dangerText;

String _carLevel(int occupancy) => occupancy < 60
    ? 'Baixa'
    : occupancy < 75
    ? 'Moderada'
    : occupancy < 85
    ? 'Alta'
    : 'Muito alta';

class TrainDetailScreen extends StatefulWidget {
  final MetroTrain train;
  const TrainDetailScreen({super.key, required this.train});

  @override
  State<TrainDetailScreen> createState() => _TrainDetailScreenState();
}

class _TrainDetailScreenState extends State<TrainDetailScreen> {
  late TrainCarriage selected = widget.train.recommended;

  @override
  Widget build(BuildContext context) {
    final train = widget.train;
    final best = train.recommended;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          tooltip: 'Voltar',
          onPressed: () => goBack(context),
          icon: const Icon(LucideIcons.arrowLeft, color: black),
        ),
        title: Text(
          'Metrô ${train.code}',
          style: const TextStyle(
            color: black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            children: [
              Text(
                'Sentido ${train.destination}',
                style: const TextStyle(color: muted, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                'Na estação ${train.station.name}',
                style: const TextStyle(color: muted, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _tag(train.line.name, train.line.color, train.line.onColor),
                  _tag('● Em circulação', softTeal, tealDark),
                  _tag('Dados simulados', const Color(0xFFF0F2F4), muted),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: tealDark,
                  borderRadius: BorderRadius.circular(radius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'OCUPAÇÃO ESTIMADA',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 24,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          '${train.occupancy}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${train.people} pessoas a bordo',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Capacidade: ${train.capacity} pessoas',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    OccupancyBar(percent: train.occupancy, height: 8),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Escolha o melhor vagão',
                style: TextStyle(
                  color: black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Menor lotação, uma viagem mais tranquila.',
                style: TextStyle(color: muted, fontSize: 12),
              ),
              const SizedBox(height: 22),
              const Text(
                'FRENTE DO METRÔ →',
                style: TextStyle(color: muted, fontSize: 10),
              ),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  // Mantém os seis vagões visíveis; em telas estreitas permite rolagem.
                  final width = ((constraints.maxWidth - 5 * 8) / 6).clamp(
                    46.0,
                    90.0,
                  );
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final car in train.carriages)
                          Padding(
                            padding: EdgeInsets.only(
                              right: car == train.carriages.last ? 0 : 8,
                            ),
                            child: SizedBox(
                              width: width,
                              child: _carriage(car, best),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  for (final percent in [58, 66, 75, 88])
                    _tag(
                      _carLevel(percent),
                      _carColor(percent).withValues(alpha: .1),
                      _carColor(percent),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              _panel(
                color: softTeal,
                children: [
                  Text(
                    'Prefira o vagão ${best.label}',
                    style: const TextStyle(
                      color: tealDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '${best.occupancy}% de ocupação · ${best.people} de ${best.capacity} pessoas',
                    style: const TextStyle(color: tealDark, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _panel(
                children: [
                  Text(
                    'Vagão ${selected.label} · ${_carLevel(selected.occupancy).toLowerCase()}',
                    style: const TextStyle(
                      color: black,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${selected.people} pessoas · ${selected.capacity - selected.people} lugares até a capacidade',
                    style: const TextStyle(color: muted, fontSize: 12),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Capacidade total inclui passageiros em pé e sentados.',
                    style: TextStyle(color: muted, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _panel(
                children: [
                  Text(
                    '${train.carriages.length} vagões',
                    style: const TextStyle(
                      color: black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${train.carriages.first.capacity} pessoas por vagão',
                    style: const TextStyle(color: muted, fontSize: 12),
                  ),
                  const Divider(height: 24, color: greyBorder),
                  Text(
                    'Próxima parada: ${train.nextStation.name}',
                    style: const TextStyle(
                      color: black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Chegada estimada em 2 min · simulação',
                    style: TextStyle(color: muted, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: fluxoNavBar(1, (index) => goToTab(context, index)),
    );
  }

  Widget _carriage(TrainCarriage car, TrainCarriage best) {
    final color = _carColor(car.occupancy);
    final active = selected == car;
    return Semantics(
      label:
          'Vagão ${car.label}, ${car.occupancy}% de ocupação, ${_carLevel(car.occupancy)}${car == best ? ', recomendado' : ''}',
      selected: active,
      button: true,
      excludeSemantics: true,
      child: Material(
        color: car == best ? softTeal : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(
            color: active ? tealDark : greyBorder,
            width: active ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => setState(() => selected = car),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
            child: Column(
              children: [
                Container(
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(radius),
                  ),
                  child: Text(
                    car.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  '${car.occupancy}%',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tag(String text, Color background, Color foreground) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(radius),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: foreground,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _panel({required List<Widget> children, Color color = Colors.white}) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: greyBorder),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      );
}
