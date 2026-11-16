import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'lines_screen.dart';

class EventItem {
  final String title;
  final DateTime date;
  final String time;
  final List<int> lines;
  final String warning;

  EventItem(this.title, this.date, this.time, this.lines,
      {this.warning = 'possível superlotação'});

  String get when =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} às $time';
}

final List<EventItem> upcomingEvents = [
  EventItem('Réveillon na Avenida Paulista', DateTime(2026, 12, 31), '20h00-02h00', [2, 4]),
  EventItem('Show no Allianz Parque', DateTime(2027, 1, 16), '19h00-23h00', [3, 7, 8]),
  EventItem('Desfile de Carnaval no Anhembi', DateTime(2027, 2, 6), '20h00-04h00', [1]),
  EventItem('Manutenção programada na Linha 9', DateTime(2027, 2, 21), '22h00-05h00', [9], warning: 'intervalos maiores entre trens'),
  EventItem('Jogo na Neo Química Arena', DateTime(2027, 3, 20), '16h00-19h00', [3, 11]),
];

const List<String> months = [
  'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
  'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
];

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  int? lineFilter;

  List<int> get lineNumbers {
    final numbers = upcomingEvents.expand((event) => event.lines).toSet().toList();
    numbers.sort();
    return numbers;
  }

  List<EventItem> get filtered {
    if (lineFilter == null) return upcomingEvents;
    return upcomingEvents
        .where((event) => event.lines.contains(lineFilter))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = filtered;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: fluxoBackAppBar(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ScreenTitle(
              title: 'Eventos próximos',
              subtitle: 'Eventos que podem lotar estações. Toque em uma linha para ver a lotação.',
            ),
            const SizedBox(height: 14),
            LineFilterBar(
              lines: lineNumbers,
              selected: lineFilter,
              onChanged: (value) => setState(() => lineFilter = value),
            ),
            const SizedBox(height: 10),
            Text('${items.length} de ${upcomingEvents.length} eventos',
                style: const TextStyle(color: muted, fontSize: 12)),
            const SizedBox(height: 8),
            Expanded(
              child: items.isEmpty
                  ? _emptyState()
                  : ListView(children: _buildGroupedList(items)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: fluxoNavBar(3, (index) {
        if (index != 3) goToTab(context, index);
      }),
    );
  }

  List<Widget> _buildGroupedList(List<EventItem> items) {
    final widgets = <Widget>[];
    int? lastMonth;

    for (final event in items) {
      final month = event.date.year * 100 + event.date.month;

      if (month != lastMonth) {
        final count = items.where((item) =>
            item.date.year == event.date.year &&
            item.date.month == event.date.month).length;

        widgets.add(_monthHeader(event.date, count, lastMonth == null));
        lastMonth = month;
      }

      widgets.add(_eventCard(event));
      widgets.add(const SizedBox(height: 12));
    }

    return widgets;
  }

  Widget _monthHeader(DateTime date, int count, bool first) {
    return Padding(
      padding: EdgeInsets.only(top: first ? 0 : 10, bottom: 10),
      child: Row(
        children: [
          Text(
            '${months[date.month - 1]} ${date.year}'.toUpperCase(),
            style: const TextStyle(
              color: black, fontSize: 13,
              fontWeight: FontWeight.w700, letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(child: Divider(height: 1, color: greyBorder)),
          const SizedBox(width: 10),
          Text('$count ${count == 1 ? 'evento' : 'eventos'}', style: const TextStyle(color: muted, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _eventCard(EventItem event) {
    return InfoCard(
      title: event.title,
      when: event.when,
      lines: event.lines,
      warning: event.warning,
      footer: const ReminderControl(),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.calendar, size: 40, color: greyBorder),
          const SizedBox(height: 10),
          const Text('Nenhum evento para esta linha',
              style: TextStyle(color: black, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Tente outra linha ou veja todos os eventos.',
              style: TextStyle(color: muted, fontSize: 12)),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => setState(() => lineFilter = null),
            child: const Text('Limpar filtro',
                style: TextStyle(color: tealDark, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// Este botão muda apenas de aparência. Não cria uma notificação real.
class ReminderControl extends StatefulWidget {
  const ReminderControl({super.key});

  @override
  State<ReminderControl> createState() => _ReminderControlState();
}

class _ReminderControlState extends State<ReminderControl> {
  bool active = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            active ? 'Aviso ativado' : 'Quer ser avisado antes?',
            style: const TextStyle(color: muted, fontSize: 12),
          ),
        ),
        Material(
          color: active ? tealDark : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: BorderSide(color: active ? tealDark : greyBorder, width: 1.5),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(radius),
            onTap: () => setState(() => active = !active),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(active ? LucideIcons.check : LucideIcons.bell,
                      size: 14, color: active ? Colors.white : black),
                  const SizedBox(width: 5),
                  Text(active ? 'Avisando' : 'Avisar-me',
                      style: TextStyle(
                        color: active ? Colors.white : black,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
