import 'package:material_ui/material_ui.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'lines_screen.dart';
import 'line_detail_screen.dart';

/// Visão geral com os mesmos dados simulados usados no monitoramento.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openLine(BuildContext context, MetroLine line) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => LineDetailScreen(line: line)));
  }

  @override
  Widget build(BuildContext context) {
    final stations = metroLines.expand((line) => line.stations).toList();
    final critical = stations.where((s) => isCritical(s.occupancy)).length;
    final capacity = stations.fold<int>(0, (sum, s) => sum + s.capacity);
    final people = stations.fold<int>(0, (sum, s) => sum + s.currentPeople);
    final occupancy = (people / capacity * 100).round();
    final alerts = [
      for (final line in metroLines)
        for (final station in line.stations)
          if (isCritical(station.occupancy)) (line: line, station: station),
    ]..sort((a, b) => b.station.occupancy.compareTo(a.station.occupancy));
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, centerTitle: false,
        title: Row(children: [
          fluxoLogo(), const SizedBox(width: 8),
          const Text('Fluxo', style: TextStyle(color: black, fontSize: 22,
            fontWeight: FontWeight.bold)),
        ]),
        actions: [Padding(padding: const EdgeInsets.only(right: 16),
          child: Center(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: softTeal,
              borderRadius: BorderRadius.circular(4)),
            child: const Text('DEMONSTRAÇÃO', style: TextStyle(
              color: tealDark, fontSize: 10, fontWeight: FontWeight.bold,
              letterSpacing: 1)),
          )))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1160),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: double.infinity, padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: softTeal,
                border: Border.all(color: tealDark, width: 1.5),
                borderRadius: BorderRadius.circular(radius)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('CENTRO DE MONITORAMENTO', style: TextStyle(
                  color: tealDark, fontSize: 11, fontWeight: FontWeight.bold,
                  letterSpacing: 1.5)),
                const SizedBox(height: 12),
                const Text('Uma visão clara.\nUma cidade em movimento.',
                  style: TextStyle(color: black, fontSize: 30, height: 1.15,
                    fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text('Acompanhe a ocupação da rede, identifique pontos de atenção e antecipe a operação.',
                  style: TextStyle(color: muted, fontSize: 14, height: 1.5)),
                const SizedBox(height: 18),
                FilledButton.icon(onPressed: () => goToTab(context, 1),
                  style: FilledButton.styleFrom(backgroundColor: tealDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius))),
                  icon: const Icon(LucideIcons.trainFront, size: 18),
                  label: const Text('Explorar linhas')),
              ]),
            ),
            const SizedBox(height: 20),
            const ScreenTitle(title: 'Panorama da rede',
              subtitle: 'Cenário simulado • ocupação calculada a partir das estações do projeto'),
            const SizedBox(height: 12),
            LayoutBuilder(builder: (context, box) {
              final columns = box.maxWidth >= 850 ? 4 : 2;
              final width = (box.maxWidth - (columns - 1) * 12) / columns;
              return Wrap(spacing: 12, runSpacing: 12, children: [
                _metric(width, LucideIcons.trainFront, '${metroLines.length}', 'Linhas monitoradas', 'Metrô, trem e monotrilho'),
                _metric(width, LucideIcons.users, '$occupancy%', 'Ocupação da rede', 'Ponderada pela capacidade'),
                _metric(width, LucideIcons.mapPin, '${stations.length}', 'Registros de estações', 'Inclui conexões entre linhas'),
                _metric(width, LucideIcons.triangleAlert, '$critical', 'Pontos de atenção', 'Estações com lotação ≥ 85%', warning: true),
              ]);
            }),
            const SizedBox(height: 24),
            Row(children: [
              const Expanded(child: ScreenTitle(title: 'Prioridades da operação',
                subtitle: 'As três estações com maior ocupação no cenário')),
              const SizedBox(width: 8),
              TextButton(onPressed: () => goToTab(context, 1),
                child: const Text('Ver todas →', style: TextStyle(color: tealDark))),
            ]),
            const SizedBox(height: 12),
            for (final alert in alerts.take(3)) Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: black, width: 1.5),
                  borderRadius: BorderRadius.circular(radius)),
                child: InkWell(onTap: () => _openLine(context, alert.line),
                  child: Padding(padding: const EdgeInsets.all(16),
                    child: Row(children: [
                      Container(width: 5, height: 52, color: alert.line.color),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(alert.station.name, style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(alert.line.name, style: const TextStyle(color: muted, fontSize: 12)),
                        const SizedBox(height: 6),
                        const Text('Reforçar orientação de embarque', style: TextStyle(
                          color: dangerText, fontSize: 11)),
                      ])),
                      const SizedBox(width: 8),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('${alert.station.occupancy}%', style: const TextStyle(
                          color: dangerText, fontSize: 24, fontWeight: FontWeight.bold)),
                        const Text('da capacidade', style: TextStyle(color: muted, fontSize: 10)),
                      ]),
                      const SizedBox(width: 8),
                      const Icon(LucideIcons.chevronRight, color: tealDark, size: 18),
                    ])),
                )),
            ),
            const SizedBox(height: 14),
            const ScreenTitle(title: 'Planeje os próximos movimentos',
              subtitle: 'Informações e ferramentas para apoiar a operação'),
            const SizedBox(height: 12),
            LayoutBuilder(builder: (context, box) {
              final width = box.maxWidth >= 700 ? (box.maxWidth - 12) / 2 : box.maxWidth;
              return Wrap(spacing: 12, runSpacing: 12, children: [
                _shortcut(context, width, LucideIcons.calendar, 'Agenda de eventos',
                  'Antecipe a demanda nas linhas próximas aos eventos da cidade.', 3),
                _shortcut(context, width, LucideIcons.megaphone, 'Comunicados da rede',
                  'Consulte avisos e mantenha a operação alinhada.', 4),
              ]);
            }),
            const SizedBox(height: 20),
            const Text('Ambiente de demonstração. Os indicadores e recomendações são simulados e não representam a operação real.',
              style: TextStyle(color: muted, fontSize: 11, height: 1.5)),
          ]),
        )),
      ),
      bottomNavigationBar: fluxoNavBar(0, (index) {
        if (index != 0) goToTab(context, index);
      }),
    );
  }

  Widget _metric(double width, IconData icon, String value, String label,
      String detail, {bool warning = false}) => Container(
    width: width, padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white,
      border: Border.all(color: black, width: 1.5),
      borderRadius: BorderRadius.circular(radius)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 20, color: warning ? dangerText : tealDark),
      const SizedBox(height: 14),
      Text(value, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,
        color: warning ? dangerText : black)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(height: 5),
      Text(detail, style: const TextStyle(color: muted, fontSize: 11)),
    ]),
  );

  Widget _shortcut(BuildContext context, double width, IconData icon,
      String title, String text, int tab) => SizedBox(
    width: width,
    child: Material(color: softTeal,
      shape: RoundedRectangleBorder(side: const BorderSide(color: greyBorder),
        borderRadius: BorderRadius.circular(radius)),
      child: InkWell(onTap: () => goToTab(context, tab),
        child: Padding(padding: const EdgeInsets.all(18),
          child: Row(children: [
            Icon(icon, size: 24, color: tealDark),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(text, style: const TextStyle(color: muted, fontSize: 12, height: 1.4)),
              ])),
            const SizedBox(width: 8),
            const Icon(LucideIcons.chevronRight, color: tealDark, size: 18),
          ])),
      )),
  );
}
