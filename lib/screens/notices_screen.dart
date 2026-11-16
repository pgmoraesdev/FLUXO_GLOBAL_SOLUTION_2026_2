import 'package:material_ui/material_ui.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'lines_screen.dart';

class NoticeItem {
  final String title;
  final String description;
  final String when;
  final List<int> lines;

  const NoticeItem(this.title, this.description, this.when, this.lines);
}

const List<NoticeItem> notices = [
  NoticeItem('Linha 15 - Lentidão', 'incidente na estção Jardim Planalto',
      '14/11 às 07h00-09h00', [15, 2]),
  NoticeItem('Linha 2 - operação parcial',
      'estação Trianon-Masp inoperante no momento.',
      '23/11 às 15h00-18h00', [2, 1]),
];

class NoticesScreen extends StatefulWidget {
  const NoticesScreen({super.key});

  @override
  State<NoticesScreen> createState() => _NoticesScreenState();
}

class _NoticesScreenState extends State<NoticesScreen> {
  final Set<String> read = {};
  bool onlyUnread = false;

  int get unreadCount =>
      notices.where((notice) => !read.contains(notice.title)).length;

  List<NoticeItem> get visible {
    if (!onlyUnread) return notices;
    return notices.where((notice) => !read.contains(notice.title)).toList();
  }

  void _setRead(NoticeItem notice, bool value) {
    setState(() {
      if (value) {
        read.add(notice.title);
      } else {
        read.remove(notice.title);
      }
    });
  }

  void _markAllRead() {
    setState(() {
      read.addAll(notices.map((notice) => notice.title));
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = visible;
    final unread = unreadCount;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: fluxoBackAppBar(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ScreenTitle(
              title: 'Comunicados',
              subtitle: 'Avisos lançados pela operação sobre as linhas.',
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                FluxoChip(
                  label: 'Todos (${notices.length})',
                  active: !onlyUnread,
                  onTap: () => setState(() => onlyUnread = false),
                ),
                FluxoChip(
                  label: 'Não lidos ($unread)',
                  active: onlyUnread,
                  onTap: () => setState(() => onlyUnread = true),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${notices.length} comunicados · '
                    '$unread ${unread == 1 ? 'não lido' : 'não lidos'}',
                    style: const TextStyle(color: muted, fontSize: 12),
                  ),
                ),
                if (unread > 0)
                  InkWell(
                    onTap: _markAllRead,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        'Marcar todos como lidos',
                        style: TextStyle(
                          color: tealDark, fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Expanded(
              child: items.isEmpty
                  ? _emptyState()
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, index) => _noticeCard(items[index]),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: fluxoNavBar(4, (index) {
        if (index != 4) goToTab(context, index);
      }),
    );
  }

  Widget _noticeCard(NoticeItem notice) {
    final isRead = read.contains(notice.title);

    return InfoCard(
      title: notice.title,
      description: notice.description,
      when: notice.when,
      lines: notice.lines,
      warning: 'possível superlotação',
      highlight: !isRead,
      trailing: isRead
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: tealDark,
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Text(
                'NOVO',
                style: TextStyle(
                  color: Colors.white, fontSize: 10,
                  fontWeight: FontWeight.bold, letterSpacing: 0.5,
                ),
              ),
            ),
      footer: Align(
        alignment: Alignment.centerRight,
        child: InkWell(
          onTap: () => _setRead(notice, !isRead),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.check, size: 16, color: isRead ? muted : tealDark),
                const SizedBox(width: 4),
                Text(
                  isRead ? 'Lido · marcar como não lido' : 'Marcar como lido',
                  style: TextStyle(
                    color: isRead ? muted : tealDark,
                    fontSize: 12,
                    fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.check, size: 40, color: greyBorder),
          const SizedBox(height: 10),
          const Text('Tudo em dia',
              style: TextStyle(color: black, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Você leu todos os comunicados.',
              style: TextStyle(color: muted, fontSize: 12)),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => setState(() => onlyUnread = false),
            child: const Text('Ver todos',
                style: TextStyle(color: tealDark, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
