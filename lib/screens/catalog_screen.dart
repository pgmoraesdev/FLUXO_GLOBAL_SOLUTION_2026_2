import 'package:material_ui/material_ui.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../data/catalog_data.dart';
import 'lines_screen.dart';
import 'catalog_form_screen.dart';

class CatalogScreen extends StatefulWidget {
  final CatalogStore? store;
  const CatalogScreen({super.key, this.store});
  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  CatalogKind kind = CatalogKind.line;
  CatalogStore get store => widget.store ?? CatalogStore.instance;

  String get singular => switch (kind) {
    CatalogKind.line => 'linha',
    CatalogKind.train => 'metrô',
    CatalogKind.carriage => 'vagão',
  };

  Future<void> _edit([int? id]) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CatalogFormScreen(store: store, kind: kind, recordId: id),
      ),
    );
    if (saved == true && mounted) _feedback('Cadastro salvo com sucesso.');
  }

  void _feedback(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

  Future<void> _delete(int id, String label) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: black, width: 1.5),
        ),
        title: Text('Excluir $singular?'),
        content: Text(
          'Deseja excluir $label? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: dangerText)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      store.delete(kind, id);
      _feedback('Cadastro excluído com sucesso.');
    } on StateError catch (error) {
      _feedback(error.message);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: fluxoBackAppBar(context),
    body: ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final canCreate = switch (kind) {
          CatalogKind.line => true,
          CatalogKind.train => store.lines.isNotEmpty,
          CatalogKind.carriage => store.trains.isNotEmpty,
        };
        final records = switch (kind) {
          CatalogKind.line => [
            for (final line in store.lines)
              (
                id: line.id,
                title: line.label,
                detail: '${line.origin} ↔ ${line.destination}\n${line.type}',
              ),
          ],
          CatalogKind.train => [
            for (final train in store.trains)
              (
                id: train.id,
                title: 'Metrô ${train.code}',
                detail:
                    '${store.line(train.lineId).label} · ${train.status}\n${store.carsFor(train.id).length} vagões · capacidade: ${store.capacityFor(train.id)} pessoas',
              ),
          ],
          CatalogKind.carriage => [
            for (final car in store.carriages)
              (
                id: car.id,
                title:
                    'Vagão ${car.number.toString().padLeft(2, '0')} · ${store.train(car.trainId).code}',
                detail:
                    'Capacidade: ${car.capacity} pessoas · ocupação: ${car.occupancy}%\n${car.people} pessoas estimadas',
              ),
          ],
        };
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            const ScreenTitle(
              title: 'Cadastros',
              subtitle:
                  'Cadastre, consulte, edite e exclua linhas, metrôs e vagões.',
            ),
            const SizedBox(height: 12),
            const Text(
              'Cadastros de demonstração, mantidos apenas durante esta execução. O monitoramento e a frota continuam simulados.',
              style: TextStyle(color: muted, fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 14),
            Wrap(
              runSpacing: 8,
              children: [
                for (final item in CatalogKind.values)
                  FluxoChip(
                    label: switch (item) {
                      CatalogKind.line => 'Linhas',
                      CatalogKind.train => 'Metrôs',
                      CatalogKind.carriage => 'Vagões',
                    },
                    active: kind == item,
                    onTap: () => setState(() => kind = item),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: canCreate ? () => _edit() : null,
              style: FilledButton.styleFrom(
                backgroundColor: tealDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius),
                ),
              ),
              icon: const Icon(LucideIcons.plus, size: 18),
              label: Text('Cadastrar $singular'),
            ),
            if (!canCreate)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  kind == CatalogKind.train
                      ? 'Cadastre uma linha antes de cadastrar um metrô.'
                      : 'Cadastre um metrô antes de cadastrar um vagão.',
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
              ),
            const SizedBox(height: 12),
            Text(
              '${records.length} registros',
              style: const TextStyle(color: muted, fontSize: 12),
            ),
            const SizedBox(height: 10),
            if (records.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Nenhum cadastro encontrado.',
                  style: TextStyle(color: muted),
                ),
              ),
            for (final record in records) ...[
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
                      record.title,
                      style: const TextStyle(
                        color: black,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      record.detail,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      children: [
                        TextButton.icon(
                          onPressed: () => _edit(record.id),
                          icon: const Icon(
                            LucideIcons.pencil,
                            size: 16,
                            color: tealDark,
                          ),
                          label: Text(
                            'Editar',
                            semanticsLabel: 'Editar ${record.title}',
                            style: const TextStyle(color: tealDark),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _delete(record.id, record.title),
                          icon: const Icon(
                            LucideIcons.trash2,
                            size: 16,
                            color: dangerText,
                          ),
                          label: Text(
                            'Excluir',
                            semanticsLabel: 'Excluir ${record.title}',
                            style: const TextStyle(color: dangerText),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    ),
    bottomNavigationBar: fluxoNavBar(2, (index) => goToTab(context, index)),
  );
}
