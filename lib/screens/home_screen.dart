import 'package:material_ui/material_ui.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../data/events_data.dart';
import 'lines_screen.dart';
import 'line_detail_screen.dart';
import 'notices_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final search = query.trim().toLowerCase();
    final matches = metroLines
        .where(
          (line) =>
              line.name.toLowerCase().contains(search) ||
              line.stations.any(
                (station) => station.name.toLowerCase().contains(search),
              ),
        )
        .toList();
    final visible = search.isEmpty ? matches.take(3).toList() : matches;
    final stations = metroLines.expand((line) => line.stations).toList();
    final average = stations.isEmpty
        ? 0
        : (stations.fold<int>(0, (sum, station) => sum + station.occupancy) /
                  stations.length)
              .round();
    final today = DateUtils.dateOnly(DateTime.now());
    final events =
        upcomingEvents.where((event) => !event.date.isBefore(today)).toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Visão geral',
                            style: TextStyle(
                              color: black,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Acompanhe sua rede em um só lugar.',
                            style: TextStyle(color: muted, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.outlined(
                      tooltip: 'Ver comunicados',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NoticesScreen(),
                        ),
                      ),
                      icon: Badge(
                        isLabelVisible: notices.isNotEmpty,
                        backgroundColor: danger,
                        child: const Icon(
                          LucideIcons.bell,
                          color: black,
                          size: 21,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                TextField(
                  onChanged: (value) => setState(() => query = value),
                  decoration: searchDecoration('Pesquisar estação ou linha'),
                ),
                const SizedBox(height: 16),
                _NetworkPulse(lineCount: metroLines.length, average: average),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        search.isEmpty
                            ? 'Linhas em operação'
                            : 'Resultados da busca',
                        style: const TextStyle(
                          color: black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${matches.length} linhas',
                      style: const TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (visible.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Nenhuma linha ou estação encontrada.',
                      style: TextStyle(color: muted),
                    ),
                  ),
                for (final line in visible) ...[
                  _HomeLineCard(line: line, stationQuery: query.trim()),
                  const SizedBox(height: 10),
                ],
                if (search.isEmpty) ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => goToTab(context, 1),
                      child: const Text(
                        'Ver todas as linhas →',
                        style: TextStyle(color: tealDark),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (events.isNotEmpty) _DemandAlert(event: events.first),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: fluxoNavBar(0, (index) {
        if (index != 0) goToTab(context, index);
      }),
    );
  }
}

class _NetworkPulse extends StatelessWidget {
  const _NetworkPulse({required this.lineCount, required this.average});
  final int lineCount;
  final int average;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tealDark,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PULSO DA REDE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: .6,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: softTeal,
                  borderRadius: BorderRadius.circular(radius),
                ),
                child: const Text(
                  '● Simulação',
                  style: TextStyle(
                    color: tealDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Uma visão. Toda a operação.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(child: _metric('$lineCount', 'linhas monitoradas')),
                const VerticalDivider(color: Colors.white38, width: 30),
                Expanded(child: _metric('$average%', 'ocupação média')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(String value, String label) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
    ],
  );
}

class _HomeLineCard extends StatelessWidget {
  const _HomeLineCard({required this.line, required this.stationQuery});
  final MetroLine line;
  final String stationQuery;

  @override
  Widget build(BuildContext context) {
    final matchesStation =
        stationQuery.isNotEmpty &&
        line.stations.any(
          (station) =>
              station.name.toLowerCase().contains(stationQuery.toLowerCase()),
        );
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: const BorderSide(color: greyBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LineDetailScreen(
              line: line,
              initialQuery: matchesStation ? stationQuery : '',
            ),
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 4, color: line.color),
              const SizedBox(width: 12),
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: line.color,
                  borderRadius: BorderRadius.circular(radius),
                ),
                child: Text(
                  '${line.number}',
                  style: TextStyle(
                    color: line.onColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              line.colorName,
                              style: const TextStyle(
                                color: black,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Text(
                            '${line.occupancy}%',
                            style: const TextStyle(
                              color: black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        line.stations.isEmpty
                            ? 'Sem estações cadastradas'
                            : '${line.stations.first.name} ↔ ${line.stations.last.name}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: muted, fontSize: 12),
                      ),
                      const SizedBox(height: 9),
                      OccupancyBar(percent: line.occupancy, height: 7),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemandAlert extends StatelessWidget {
  const _DemandAlert({required this.event});
  final EventItem event;

  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFFFFF3D6),
    borderRadius: BorderRadius.circular(radius),
    child: InkWell(
      borderRadius: BorderRadius.circular(radius),
      onTap: () => goToTab(context, 3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Atenção à demanda',
              style: TextStyle(
                color: Color(0xFF795410),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '${event.title} · ${event.when}',
              style: const TextStyle(color: Color(0xFF795410), fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              '${event.warning} · Linhas ${event.lines.join(', ')}. Ver evento →',
              style: const TextStyle(color: Color(0xFF795410), fontSize: 12),
            ),
          ],
        ),
      ),
    ),
  );
}
