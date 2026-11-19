import '../data/train_data.dart';
import 'train_detail_screen.dart';

import 'package:material_ui/material_ui.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import 'lines_screen.dart';

// Tela com os detalhes de uma linha e suas estações.
class LineDetailScreen extends StatefulWidget {
  final MetroLine line;
  final String initialQuery;

  const LineDetailScreen({
    super.key,
    required this.line,
    this.initialQuery = '',
  });

  @override
  State<LineDetailScreen> createState() => _LineDetailScreenState();
}

class _LineDetailScreenState extends State<LineDetailScreen> {
  // Guarda o texto digitado na busca.
  late String query = widget.initialQuery;
  late final TextEditingController searchController = TextEditingController(
    text: widget.initialQuery,
  );

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final line = widget.line;
    final percent = line.occupancy;

    // Mostra somente as estações que correspondem à busca.
    final stations = line.stations.where((station) {
      return station.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: fluxoBackAppBar(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumo da linha e sua ocupação média.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: black, width: 1.5),
                borderRadius: BorderRadius.circular(radius),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    line.name,
                    style: const TextStyle(
                      color: black,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  OccupancyLabel(percent: percent),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Indicador visual da situação da linha.
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: occupancyColor(percent),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('operação normal', style: TextStyle(color: black)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'lotação: ${isCritical(percent) ? 'próxima do limite' : 'dentro da capacidade'}',
              style: const TextStyle(color: muted),
            ),
            const SizedBox(height: 10),

            // Exibe a estação com maior ocupação.
            const Text('Estação mais lotada:', style: TextStyle(color: black)),
            Text(
              '${line.busiest.name} ${line.busiest.occupancy}%',
              style: const TextStyle(color: black, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),

            // Campo para pesquisar uma estação pelo nome.
            TextField(
              controller: searchController,
              onChanged: (value) => setState(() => query = value),
              decoration: searchDecoration('Pesquisar estações'),
            ),
            const SizedBox(height: 8),

            // Quantidade de estações encontradas na busca.
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${stations.length} estações',
                style: const TextStyle(color: muted, fontSize: 12),
              ),
            ),
            const SizedBox(height: 6),

            // Faixa colorida da linha ao lado da lista de estações.
            Expanded(
              child: stations.isEmpty
                  ? const Center(child: Text('Nenhuma estação encontrada'))
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          width: 6,
                          decoration: BoxDecoration(
                            color: line.color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ListView.separated(
                            itemCount: stations.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (_, index) => _StationCard(
                              key: ValueKey(stations[index].name),
                              station: stations[index],
                              line: line,
                              initiallyExpanded: index == 0,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: fluxoNavBar(1, (index) => goToTab(context, index)),
    );
  }
}

// CARD DE ESTAÇÃO
// Cada card pode ser expandido para mostrar mais informações.
class _StationCard extends StatefulWidget {
  final Station station;
  final MetroLine line;
  final bool initiallyExpanded;

  const _StationCard({
    super.key,
    required this.station,
    required this.line,
    this.initiallyExpanded = false,
  });

  @override
  State<_StationCard> createState() => _StationCardState();
}

class _StationCardState extends State<_StationCard> {
  // Controla se as informações adicionais estão aparecendo.
  late bool expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final station = widget.station;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: black, width: 1.5),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      station.name,
                      style: const TextStyle(
                        color: black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      widget.line.type,
                      style: const TextStyle(color: muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OccupancyLabel(percent: station.occupancy, size: 15),
            ],
          ),
          const SizedBox(height: 8),
          OccupancyBar(percent: station.occupancy, height: 12),
          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TrainDetailScreen(
                    train: MetroTrain.simulated(widget.line, station),
                  ),
                ),
              ),
              icon: const Icon(
                LucideIcons.trainFront,
                size: 16,
                color: tealDark,
              ),
              label: const Text(
                'Ver metrô e vagões',
                style: TextStyle(color: tealDark),
              ),
            ),
          ),

          // Informações extras aparecem quando o card é expandido.
          if (expanded)
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'capacidade máxima: ${station.capacity}\n'
                  'capacidade atual: ${station.currentPeople}',
                  style: const TextStyle(
                    color: muted,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Ações para ${station.name} em breve'),
                        ),
                      ),
                      child: const Text(
                        'Tomar ações →',
                        style: TextStyle(
                          color: tealDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _toggle('ver menos', LucideIcons.chevronUp),
                  ],
                ),
              ],
            )
          else
            Align(
              alignment: Alignment.centerRight,
              child: _toggle('ver mais', LucideIcons.chevronDown),
            ),
        ],
      ),
    );
  }

  // Alterna entre mostrar e esconder as informações extras.
  Widget _toggle(String text, IconData icon) {
    return InkWell(
      onTap: () => setState(() => expanded = !expanded),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: const TextStyle(color: muted, fontSize: 11)),
          const SizedBox(width: 2),
          Icon(icon, size: 14, color: muted),
        ],
      ),
    );
  }
}
