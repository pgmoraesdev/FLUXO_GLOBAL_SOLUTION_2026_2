import 'package:material_ui/material_ui.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../data/reinforcement_data.dart';
import 'lines_screen.dart';
import 'reinforcement_screen.dart';
import 'catalog_screen.dart';

class ActionsScreen extends StatelessWidget {
  final ReinforcementRequests? requests;
  const ActionsScreen({super.key, this.requests});

  @override
  Widget build(BuildContext context) {
    final store = requests ?? ReinforcementRequests.instance;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: fluxoBackAppBar(context),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            const ScreenTitle(
              title: 'Ações',
              subtitle: 'Escolha uma ação para acompanhar e apoiar a operação.',
            ),
            const SizedBox(height: 14),
            _option(
              icon: LucideIcons.trainFront,
              title: 'Chamar reforço de frota',
              description:
                  'Selecione uma linha e solicite composições adicionais.',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReinforcementScreen(requests: store),
                ),
              ),
              highlight: true,
            ),
            const SizedBox(height: 12),
            _option(
              icon: LucideIcons.pencil,
              title: 'Cadastros',
              description: 'Gerencie linhas, metrôs e vagões.',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CatalogScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _option(
              icon: LucideIcons.search,
              title: 'Monitorar linhas e estações',
              description: 'Consulte a lotação e os detalhes dos vagões.',
              onTap: () => goToTab(context, 1),
            ),
            const SizedBox(height: 12),
            _option(
              icon: LucideIcons.calendar,
              title: 'Consultar eventos',
              description: 'Veja os eventos que podem aumentar a demanda.',
              onTap: () => goToTab(context, 3),
            ),
            const SizedBox(height: 12),
            _option(
              icon: LucideIcons.megaphone,
              title: 'Consultar comunicados',
              description: 'Acompanhe os avisos publicados pela operação.',
              onTap: () => goToTab(context, 4),
            ),
            const SizedBox(height: 20),
            const ScreenTitle(
              title: 'Solicitações de reforço',
              subtitle: 'Simulação local. Os registros duram apenas nesta execução do app.',
            ),
            const SizedBox(height: 12),
            if (store.requests.isEmpty)
              const Text(
                'Nenhuma solicitação registrada.',
                style: TextStyle(color: muted, fontSize: 12),
              ),
            for (final request in store.requests) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: black, width: 1.5),
                  borderRadius: BorderRadius.circular(radius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${request.code} · ${request.line.name}',
                      style: const TextStyle(
                        color: black,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${request.trainCount} ${request.trainCount == 1 ? 'composição solicitada' : 'composições solicitadas'} · registro simulado',
                      style: const TextStyle(color: tealDark, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Registrado em ${_date(request.createdAt)}',
                      style: const TextStyle(color: muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
      bottomNavigationBar: fluxoNavBar(2, (index) {
        if (index != 2) goToTab(context, index);
      }),
    );
  }

  String _date(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} '
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  Widget _option({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    bool highlight = false,
  }) => Material(
    color: highlight ? softTeal : Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: const BorderSide(color: black, width: 1.5),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: tealDark, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: black,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(color: muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(LucideIcons.chevronRight, color: tealDark, size: 18),
          ],
        ),
      ),
    ),
  );
}
