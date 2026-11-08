import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/colors.dart';
import '../../../core/providers.dart';
import '../../../data/services/api_client.dart';
import '../../../shared/widgets/widgets.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});
  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _loading = true;
  String? _error;
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try { await ref.read(notificationsProvider.notifier).refresh(); }
    on ApiException catch (e) { _error = e.statusCode == 401 ? 'Masuk terlebih dahulu untuk melihat notifikasi.' : e.message; }
    catch (_) { _error = 'Gagal memuat notifikasi.'; }
    finally { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final notifs = ref.watch(notificationsProvider);
    final hasUnread = notifs.any((n) => !n.isRead);
    return Scaffold(body: SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(20, 14, 20, 8), child: Row(children: [
        CircleBtn(icon: Icons.arrow_back_ios_new_rounded, onTap: () => Navigator.of(context).maybePop(), semanticsLabel: 'Back'),
        const SizedBox(width: 8),
        const Expanded(child: Text('Notifikasi', textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: C.ink))),
        if (hasUnread) GestureDetector(onTap: () => ref.read(notificationsProvider.notifier).markAllRead(), child: const Text('Tandai dibaca', style: TextStyle(fontSize: 12, color: C.gray, fontWeight: FontWeight.w500))) else const SizedBox(width: 46),
      ])),
      Expanded(child: _loading ? const Center(child: CircularProgressIndicator(color: C.ink)) : _error != null ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.notifications_off_outlined, size: 48, color: C.line), const SizedBox(height: 12), Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: C.gray)), const SizedBox(height: 14), SizedBox(width: 170, child: BlackButton(label: 'Coba lagi', onTap: _load))]))) : notifs.isEmpty ? const Center(child: Text('Belum ada notifikasi.', style: TextStyle(color: C.gray))) : RefreshIndicator(color: C.ink, onRefresh: _load, child: ListView.separated(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), itemCount: notifs.length, separatorBuilder: (_, __) => const SizedBox(height: 8), itemBuilder: (_, i) {
        final n = notifs[i];
        return GestureDetector(onTap: () => ref.read(notificationsProvider.notifier).markRead(n.id), child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: n.isRead ? C.card : C.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: C.line)), child: Row(children: [Container(width: 44, height: 44, decoration: BoxDecoration(color: n.isRead ? C.card : C.ink.withAlpha(10), shape: BoxShape.circle, border: Border.all(color: C.line)), child: Icon(Icons.notifications_none_rounded, size: 20, color: n.isRead ? C.gray : C.ink)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(n.title, style: TextStyle(fontSize: 14.5, fontWeight: n.isRead ? FontWeight.w400 : FontWeight.w600, color: C.ink)), const SizedBox(height: 2), Text(n.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, color: C.gray, height: 1.4))])), const SizedBox(width: 8), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(n.time, style: const TextStyle(fontSize: 11, color: C.gray)), if (!n.isRead) ...[const SizedBox(height: 6), Container(width: 8, height: 8, decoration: const BoxDecoration(color: C.red, shape: BoxShape.circle))]])])));
      }))),
    ])));
  }
}
