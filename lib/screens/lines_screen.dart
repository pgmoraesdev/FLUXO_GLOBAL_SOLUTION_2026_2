import '../data/reinforcement_data.dart';
import 'reinforcement_screen.dart';
import 'actions_screen.dart';
import 'home_screen.dart';
import '../data/metro_data.dart';
export '../data/metro_data.dart';

import 'package:material_ui/material_ui.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import 'line_detail_screen.dart';
import 'events_screen.dart';
import 'notices_screen.dart';

// CORES
const black = Color(0xFF000000);
const teal = Color(0xFF33A5A5);
const tealDark = Color(0xFF1E7F80);
const muted = Color(0xFF5F6B85);
const danger = Color(0xFFE8736F);
const dangerText = Color(0xFFC2433F);
const softTeal = Color(0xFFF1FAFA);
const greyBorder = Color(0xFFA7B4B4);
const double radius = 4;

// Define quando a lotação é considerada crítica.
bool isCritical(int percent) => percent >= 85;

// Escolhe a cor da lotação de acordo com a porcentagem.
Color occupancyColor(int percent) => isCritical(percent) ? danger : teal;

// WIDGETS USADOS EM OUTRAS TELAS

// Logo do app
Widget fluxoLogo({double height = 28}) =>
    Image.asset('assets/images/simbolo_trama.png', height: height);

// Barra visual de porcentagem de ocupação
class OccupancyBar extends StatelessWidget {
  final int percent;
  final double height;

  const OccupancyBar({super.key, required this.percent, this.height = 14});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: black, width: 1.5),
        borderRadius: BorderRadius.circular(3),
      ),
      clipBehavior: Clip.antiAlias,
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: percent.clamp(0, 100) / 100,
          heightFactor: 1,
          child: ColoredBox(color: occupancyColor(percent)),
        ),
      ),
    );
  }
}

// Mostra a porcentagem e o texto "da capacidade".
class OccupancyLabel extends StatelessWidget {
  final int percent;
  final double size;

  const OccupancyLabel({super.key, required this.percent, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$percent%',
          style: TextStyle(
            color: black,
            fontWeight: FontWeight.bold,
            fontSize: size,
          ),
        ),
        const Text(
          'da capacidade',
          style: TextStyle(color: muted, fontSize: 10),
        ),
      ],
    );
  }
}

// BARRA DE NAVEGAÇÃO NAVBAR
Widget fluxoNavBar(int index, ValueChanged<int> onTap) {
  const icons = [
    LucideIcons.house,
    LucideIcons.trainFront,
    LucideIcons.zap,
    LucideIcons.calendar,
    LucideIcons.megaphone,
  ];

  const labels = ['Home', 'Linhas', 'Ações', 'Eventos', 'Comunicados'];

  return SafeArea(
    top: false,
    child: Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: black, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (int i = 0; i < labels.length; i++)
            Expanded(
              child: InkWell(
                onTap: () => onTap(i),
                borderRadius: BorderRadius.circular(radius),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 42,
                      height: 38,
                      decoration: BoxDecoration(
                        color: i == index ? teal : const Color(0xFFE9EDED),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icons[i],
                        size: 20,
                        color: i == index ? Colors.white : black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        labels[i],
                        style: TextStyle(
                          fontSize: 11,
                          color: i == index ? tealDark : black,
                          fontWeight: i == index
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

// Abre a tela correspondente à aba selecionada.
void goToTab(BuildContext context, int index) {
  late final Widget page;

  switch (index) {
    case 0:
      page = const HomeScreen();
      break;

    case 1:
      page = const LinesScreen();
      break;

    case 2:
      page = const ActionsScreen();
      break;

    case 3:
      page = const EventsScreen();
      break;

    case 4:
      page = const NoticesScreen();
      break;

    default:
      return;
  }

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => page),
    (route) => false,
  );
}

// Volta para a tela anterior.
void goBack(BuildContext context) {
  if (Navigator.canPop(context)) {
    Navigator.pop(context);
  } else {
    goToTab(context, 0);
  }
}

// AppBar padrão usada nas telas internas.
PreferredSizeWidget fluxoBackAppBar(BuildContext context) => AppBar(
  backgroundColor: Colors.white,
  elevation: 0,
  leading: IconButton(
    tooltip: 'Voltar',
    icon: const Icon(LucideIcons.arrowLeft, color: black),
    onPressed: () => goBack(context),
  ),
  actions: [
    Padding(padding: const EdgeInsets.only(right: 16), child: fluxoLogo()),
  ],
);

// PADRÕES DE CAMPO DE BUSCA

OutlineInputBorder _border(Color color, double width) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(radius),
  borderSide: BorderSide(color: color, width: width),
);

// PADRONIZANDO A DECORAÇÃO DO SEARCH
InputDecoration searchDecoration(String hint) => InputDecoration(
  hintText: hint,
  hintStyle: const TextStyle(color: Color(0xFF7C8499)),
  prefixIcon: const Icon(LucideIcons.search, color: greyBorder, size: 20),
  isDense: true,
  border: _border(greyBorder, 1.5),
  enabledBorder: _border(greyBorder, 1.5),
  focusedBorder: _border(greyBorder, 2),
);

// TÍTULO PADRÃO DE SEÇÃO
class ScreenTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const ScreenTitle({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: muted, fontSize: 12, height: 1.35),
        ),
      ],
    );
  }
}

// CHIP DE FILTRO
// É o botão usado para selecionar "Todas" ou uma linha específica.
class FluxoChip extends StatelessWidget {
  final String label;
  final bool active;
  final Color? dotColor;
  final VoidCallback onTap;

  const FluxoChip({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
    this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: active ? tealDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: active ? tealDark : greyBorder, width: 1.5),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (dotColor != null) ...[
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: dotColor,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                        color: active ? Colors.white : Colors.black26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                    color: active ? Colors.white : black,
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
}

// Organiza os filtros de linha em uma faixa horizontal.
class LineFilterBar extends StatelessWidget {
  final List<int> lines;
  final int? selected;
  final ValueChanged<int?> onChanged;

  const LineFilterBar({
    super.key,
    required this.lines,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FluxoChip(
            label: 'Todas',
            active: selected == null,
            onTap: () => onChanged(null),
          ),
          for (final number in lines)
            FluxoChip(
              label: 'Linha $number',
              dotColor: lineByNumber(number).color,
              active: selected == number,
              onTap: () => onChanged(selected == number ? null : number),
            ),
        ],
      ),
    );
  }
}

// IDENTIFICAÇÃO DA LINHA
// Ao tocar no badge, o usuário abre os detalhes daquela linha.
class LineBadge extends StatelessWidget {
  final MetroLine line;

  const LineBadge({super.key, required this.line});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Ver lotação da ${line.name}',
      child: Material(
        color: line.color,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LineDetailScreen(line: line)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${line.number} - ${line.colorName.toLowerCase()}',
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                    color: line.onColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(LucideIcons.chevronRight, size: 14, color: line.onColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Mostra quais linhas estão relacionadas a um evento ou comunicado.
class AffectedLines extends StatelessWidget {
  final List<int> lines;

  const AffectedLines({super.key, required this.lines});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Linhas afetadas:',
          style: TextStyle(color: muted, fontSize: 12),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final number in lines) LineBadge(line: lineByNumber(number)),
          ],
        ),
      ],
    );
  }
}

// CARD COMPARTILHADO DE EVENTOS E COMUNICADOS
// Os campos opcionais permitem usar o mesmo card em situações diferentes.
class InfoCard extends StatelessWidget {
  final String title;
  final String when;
  final List<int> lines;
  final String warning;
  final String? description;
  final Widget? trailing;
  final Widget? footer;
  final bool highlight;

  const InfoCard({
    super.key,
    required this.title,
    required this.when,
    required this.lines,
    required this.warning,
    this.description,
    this.trailing,
    this.footer,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight ? softTeal : Colors.white,
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
                child: Text(
                  title,
                  style: const TextStyle(
                    color: black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          ),
          if (description != null && description!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              description!,
              style: const TextStyle(color: muted, fontSize: 12),
            ),
          ],
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(LucideIcons.calendar, size: 14, color: muted),
              const SizedBox(width: 6),
              Text(when, style: const TextStyle(color: muted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          AffectedLines(lines: lines),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(LucideIcons.users, size: 14, color: dangerText),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  warning,
                  style: const TextStyle(
                    color: dangerText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (footer != null) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFE1E5E5)),
            const SizedBox(height: 8),
            footer!,
          ],
        ],
      ),
    );
  }
}

// TELA DE LINHAS
class LinesScreen extends StatefulWidget {
  const LinesScreen({super.key});

  @override
  State<LinesScreen> createState() => _LinesScreenState();
}

class _LinesScreenState extends State<LinesScreen> {
  // Guarda o texto digitado na busca.
  String query = '';

  // Filtra linhas pelo nome, tipo de transporte ou nome de estação.
  List<MetroLine> get filtered {
    final search = query.toLowerCase();

    return metroLines.where((line) {
      return line.name.toLowerCase().contains(search) ||
          line.type.toLowerCase().contains(search) ||
          line.stations.any(
            (station) => station.name.toLowerCase().contains(search),
          );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = filtered;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            fluxoLogo(),
            const SizedBox(width: 8),
            const Text(
              'Fluxo',
              style: TextStyle(
                color: black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 4, 0, 12),
              child: Text(
                'MONITORAMENTO DE LINHAS',
                style: TextStyle(
                  color: black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            TextField(
              onChanged: (value) => setState(() => query = value),
              decoration: searchDecoration('Pesquisar linha ou estação'),
            ),
            const SizedBox(height: 14),

            // A lista ocupa o espaço restante da tela e permite rolagem.
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('Nenhuma linha encontrada'))
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, index) => _lineCard(items[index]),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: fluxoNavBar(1, (index) {
        if (index != 1) goToTab(context, index);
      }),
    );
  }

  // Monta o card de cada linha com sua lotação e ações.
  Widget _lineCard(MetroLine line) {
    final percent = line.occupancy;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: black, width: 1.5),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    line.name,
                    style: const TextStyle(
                      color: black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    line.type,
                    style: const TextStyle(color: muted, fontSize: 12),
                  ),
                ],
              ),
              OccupancyLabel(percent: percent),
            ],
          ),
          const SizedBox(height: 10),
          OccupancyBar(percent: percent),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: line.color,
                      borderRadius: BorderRadius.circular(radius),
                    ),
                    child: Icon(
                      LucideIcons.trainFront,
                      size: 17,
                      color: line.onColor,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _link(
                    'Ver detalhes →',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LineDetailScreen(line: line),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _link(
                    'Tomar ações →',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReinforcementScreen(
                          requests: ReinforcementRequests.instance,
                          initialLine: line,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Estilo compartilhado dos links dentro dos cards.
  Widget _link(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: const TextStyle(
          color: tealDark,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
