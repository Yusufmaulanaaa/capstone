import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/colors.dart';
import '../../../core/strings.dart';
import '../../../core/providers.dart';
import '../../../data/models/chat_model.dart';
import '../../../shared/widgets/widgets.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifs = ref.watch(notificationsProvider);
    final notifier = ref.read(notificationsProvider.notifier);
    final hasUnread = notifs.any((n) => !n.isRead);

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
            child: Row(children: [
              CircleBtn(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.of(context).maybePop(),
                semanticsLabel: 'Back',
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  AppStrings.notifications,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: C.ink,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (hasUnread)
                Flexible(
                  child: GestureDetector(
                    onTap: notifier.markAllRead,
                    child: const Text(
                      AppStrings.markAllRead,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: C.gray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(width: 46),
            ]),
          ),
          Expanded(
            child: notifs.isEmpty
                ? const Center(
                    child: Text('No notifications',
                        style: TextStyle(color: C.gray)))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: notifs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _NotifTile(notif: notifs[i]),
                  ),
          ),
        ]),
      ),
    );
  }
}

class _NotifTile extends ConsumerWidget {
  final NotificationModel notif;
  const _NotifTile({required this.notif});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(notificationsProvider.notifier).markRead(notif.id),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.isRead ? C.card : C.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: notif.isRead ? C.line : C.line),
        ),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: notif.isRead ? C.card : C.ink.withAlpha(10),
              shape: BoxShape.circle,
              border: Border.all(color: C.line),
            ),
            child: Icon(
              _icon(notif.title),
              size: 20,
              color: notif.isRead ? C.gray : C.ink,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                notif.title,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: notif.isRead ? FontWeight.w400 : FontWeight.w600,
                  color: C.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                notif.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 12.5, color: C.gray, height: 1.4),
              ),
            ]),
          ),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(
              notif.time,
              style: const TextStyle(fontSize: 11, color: C.gray),
            ),
            if (!notif.isRead) ...[
              const SizedBox(height: 6),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: C.red,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ]),
        ]),
      ),
    );
  }

  IconData _icon(String title) {
    if (title.toLowerCase().contains('consult')) {
      return Icons.calendar_today_outlined;
    }
    if (title.toLowerCase().contains('lawyer')) {
      return Icons.person_outline_rounded;
    }
    if (title.toLowerCase().contains('document')) {
      return Icons.description_outlined;
    }
    if (title.toLowerCase().contains('reminder')) {
      return Icons.alarm_rounded;
    }
    return Icons.notifications_none_rounded;
  }
}
