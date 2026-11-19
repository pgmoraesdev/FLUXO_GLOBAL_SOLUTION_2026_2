class EventItem {
  final String title;
  final DateTime date;
  final String time;
  final List<int> lines;
  final String warning;

  EventItem(
    this.title,
    this.date,
    this.time,
    this.lines, {
    this.warning = 'possível superlotação',
  });

  String get when =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} às $time';
}

final List<EventItem> upcomingEvents = [
  EventItem(
    'Réveillon na Avenida Paulista',
    DateTime(2026, 12, 31),
    '20h00-02h00',
    [2, 4],
  ),
  EventItem('Show no Allianz Parque', DateTime(2027, 1, 16), '19h00-23h00', [
    3,
    7,
    8,
  ]),
  EventItem(
    'Desfile de Carnaval no Anhembi',
    DateTime(2027, 2, 6),
    '20h00-04h00',
    [1],
  ),
  EventItem(
    'Manutenção programada na Linha 9',
    DateTime(2027, 2, 21),
    '22h00-05h00',
    [9],
    warning: 'intervalos maiores entre trens',
  ),
  EventItem('Jogo na Neo Química Arena', DateTime(2027, 3, 20), '16h00-19h00', [
    3,
    11,
  ]),
];
