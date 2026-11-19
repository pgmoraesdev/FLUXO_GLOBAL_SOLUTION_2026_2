import 'package:flutter/foundation.dart';

class NoticeItem {
  final String title;
  final String description;
  final String when;
  final List<int> lines;
  final String warning;

  const NoticeItem(
    this.title,
    this.description,
    this.when,
    this.lines, {
    this.warning = 'possível superlotação',
  });
}

const List<NoticeItem> initialNotices = [
  NoticeItem(
    'Linha 15 - Lentidão',
    'incidente na estção Jardim Planalto',
    '14/11 às 07h00-09h00',
    [15, 2],
  ),
  NoticeItem(
    'Linha 2 - operação parcial',
    'estação Trianon-Masp inoperante no momento.',
    '23/11 às 15h00-18h00',
    [2, 1],
  ),
];

/// Comunicados locais, incluindo solicitações simuladas de reforço.
class NoticesStore extends ChangeNotifier {
  static final instance = NoticesStore();
  final List<NoticeItem> _items;

  NoticesStore({List<NoticeItem> initial = initialNotices})
    : _items = List.of(initial);

  List<NoticeItem> get items => List.unmodifiable(_items);

  void add(NoticeItem notice) {
    _items.insert(0, notice);
    notifyListeners();
  }
}

List<NoticeItem> get notices => NoticesStore.instance.items;
