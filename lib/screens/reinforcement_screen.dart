import 'package:material_ui/material_ui.dart';

import '../data/reinforcement_data.dart';
import 'lines_screen.dart';
import 'notices_screen.dart';

class ReinforcementScreen extends StatefulWidget {
  final ReinforcementRequests requests;
  final MetroLine? initialLine;
  const ReinforcementScreen({
    super.key,
    required this.requests,
    this.initialLine,
  });

  @override
  State<ReinforcementScreen> createState() => _ReinforcementScreenState();
}

class _ReinforcementScreenState extends State<ReinforcementScreen> {
  late MetroLine? selected = widget.initialLine;
  int trainCount = 1;
  bool confirming = false;

  Future<void> _submit() async {
    final line = selected;
    if (line == null || confirming || widget.requests.hasRequestFor(line)) {
      return;
    }
    setState(() => confirming = true);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: black, width: 1.5),
        ),
        title: const Text('Confirmar reforço simulado'),
        content: Text(
          '${line.name}\n$trainCount ${trainCount == 1 ? 'composição adicional' : 'composições adicionais'}.\n\nEste registro não aciona uma frota real.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar', style: TextStyle(color: tealDark)),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (confirmed == true && !widget.requests.hasRequestFor(line)) {
      widget.requests.submit(line, trainCount);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => NoticesScreen(store: widget.requests.notices),
        ),
        (route) => false,
      );
      return;
    }
    setState(() => confirming = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: fluxoBackAppBar(context),
    body: ListenableBuilder(
      listenable: widget.requests,
      builder: (context, _) {
        final line = selected;
        final alreadyRequested =
            line != null && widget.requests.hasRequestFor(line);
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            const ScreenTitle(
              title: 'Chamar reforço de frota',
              subtitle:
                  'Selecione uma linha para solicitar composições adicionais.',
            ),
            const SizedBox(height: 14),
            FluxoCard(
              color: softTeal,
              child: const Text(
                'Simulação: nenhum comando será enviado à frota. As solicitações ficam disponíveis apenas durante esta execução do app.',
                style: TextStyle(color: muted, fontSize: 12, height: 1.4),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<MetroLine>(
              initialValue: selected,
              isExpanded: true,
              decoration: _decoration('Linha selecionada'),
              hint: const Text('Selecione uma linha'),
              items: [
                for (final item in metroLines)
                  DropdownMenuItem(
                    value: item,
                    child: Text(item.name, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: confirming
                  ? null
                  : (value) => setState(() => selected = value),
            ),
            const SizedBox(height: 14),
            if (line != null) ...[
              FluxoCard(
                color: Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LineBadge(line: line),
                    const SizedBox(height: 10),
                    Text(
                      '${line.stations.length} estações · ${line.occupancy}% de ocupação média',
                      style: const TextStyle(color: muted, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    OccupancyBar(percent: line.occupancy, height: 12),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
            DropdownButtonFormField<int>(
              initialValue: trainCount,
              decoration: _decoration('Quantidade de composições'),
              items: [
                for (final count in [1, 2, 3])
                  DropdownMenuItem(
                    value: count,
                    child: Text(
                      '$count ${count == 1 ? 'composição' : 'composições'}',
                    ),
                  ),
              ],
              onChanged: confirming || alreadyRequested
                  ? null
                  : (value) => setState(() => trainCount = value ?? 1),
            ),
            const SizedBox(height: 16),
            if (alreadyRequested) ...[
              const Text(
                'Esta linha já possui uma solicitação simulada registrada. Selecione outra linha para solicitar novo reforço.',
                style: TextStyle(color: tealDark, fontSize: 12),
              ),
              const SizedBox(height: 12),
            ],
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: tealDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius),
                ),
              ),
              onPressed: line == null || alreadyRequested || confirming
                  ? null
                  : _submit,
              child: const Text('Solicitar reforço'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: confirming ? null : () => goBack(context),
              child: const Text('Voltar', style: TextStyle(color: tealDark)),
            ),
          ],
        );
      },
    ),
    bottomNavigationBar: fluxoNavBar(2, (index) => goToTab(context, index)),
  );

  InputDecoration _decoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: muted, fontSize: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: const BorderSide(color: greyBorder, width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: const BorderSide(color: greyBorder, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: const BorderSide(color: tealDark, width: 2),
    ),
  );
}
