import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/providers.dart';
import '../../../core/strings.dart';
import '../../../data/repositories/mock_repository.dart';
import '../../../shared/widgets/widgets.dart';
import '../widgets/topic_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _openChat(BuildContext context, [String? text]) {
    final t = text?.trim();
    context.goNamed('chat', extra: {'initial': (t == null || t.isEmpty) ? null : t});
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final unread = ref.watch(unreadCountProvider);
    final ctrl = TextEditingController();
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 44, height: 44, decoration: BoxDecoration(color: C.ink, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.balance_rounded, color: C.white, size: 22)),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(user == null ? 'HukumIn' : 'Halo, ${user.name.split(' ').first}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: C.ink)),
                    Text(user == null ? 'Masuk untuk sinkron data' : 'Backend terhubung', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: C.gray)),
                  ])),
                  const SizedBox(width: 8),
                  CircleBtn(icon: Icons.notifications_none_rounded, dot: unread > 0, semanticsLabel: 'Notifications', onTap: () => context.pushNamed('notifications')),
                ]),
                const SizedBox(height: 18),
                Container(width: double.infinity, padding: const EdgeInsets.all(18), decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [C.ink, Color(0xFF30303C)]), borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Color(0x240A0A0F), blurRadius: 18, offset: Offset(0, 8))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Ceritakan kasusmu,\nAI bantu langkah awal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: C.white, height: 1.2)),
                  const SizedBox(height: 8),
                  const Text('Chat, rekomendasi pengacara, booking, dan notifikasi terhubung ke backend HukumIn.', style: TextStyle(fontSize: 13, color: Color(0xD9FFFFFF), height: 1.4)),
                  const SizedBox(height: 14),
                  GestureDetector(onTap: () => context.goNamed('chat'), child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(color: C.white, borderRadius: BorderRadius.circular(14)), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.auto_awesome_rounded, size: 18, color: C.ink), SizedBox(width: 8), Flexible(child: Text('Mulai Chatbot', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: C.ink)))]))),
                ])),
                const SizedBox(height: 20),
                Row(children: [const Expanded(child: Text(AppStrings.suggestedTopics, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: C.ink))), GestureDetector(onTap: () => context.goNamed('consultation'), child: const Text('Konsultasi', style: TextStyle(color: C.ink, fontSize: 13, fontWeight: FontWeight.w600)))]),
                const SizedBox(height: 12),
                for (final topic in kTopics) ...[
                  TopicCard(topic: topic, onTap: () => _openChat(context, 'Saya butuh bantuan hukum untuk kasus ${topic.title}. ${topic.sub}')),
                  const SizedBox(height: 10),
                ],
              ]),
            ),
          ),
          Padding(padding: const EdgeInsets.fromLTRB(20, 4, 20, 12), child: Composer(controller: ctrl, hint: AppStrings.describeIssue, onSend: (t) => _openChat(context, t))),
        ]),
      ),
    );
  }
}
