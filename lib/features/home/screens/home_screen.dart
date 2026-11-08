import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/strings.dart';
import '../../../core/providers.dart';
import '../../../data/repositories/mock_repository.dart';
import '../../../data/models/lawyer_model.dart';
import '../../../shared/widgets/widgets.dart';
import '../widgets/topic_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _openChat([String? text]) {
    final t = text?.trim();
    context.goNamed(
      'chat',
      extra: {'initial': (t == null || t.isEmpty) ? null : t},
    );
    _ctrl.clear();
  }

  void _openDocument(TopicModel topic) {
    context.goNamed(
      'chat',
      extra: {
        'initial':
            'Saya butuh bantuan hukum untuk kasus ${topic.title}. ${topic.sub}'
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final unread = ref.watch(notificationsProvider.notifier).unreadCount;

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: C.ink,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.balance_rounded,
                          color: C.white, size: 22),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HukumIn',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: C.ink,
                            ),
                          ),
                          Text(
                            'Bantuan hukum cepat',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: C.gray),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleBtn(
                      icon: Icons.notifications_none_rounded,
                      dot: unread > 0,
                      semanticsLabel: 'Notifications',
                      onTap: () => context.pushNamed('notifications'),
                    ),
                  ]),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [C.ink, Color(0xFF30303C)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x240A0A0F),
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ceritakan kasusmu,\nAI bantu langkah awal',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: C.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Penipuan, penggelapan, pencurian, penganiayaan, hingga pencemaran nama baik.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xD9FFFFFF),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 14),
                        GestureDetector(
                          onTap: () => context.goNamed('chat'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: C.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.auto_awesome_rounded,
                                    size: 18, color: C.ink),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Mulai Chatbot',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: C.ink,
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
                  const SizedBox(height: 20),
                  Row(children: [
                    const Expanded(
                      child: Text(
                        AppStrings.suggestedTopics,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: C.ink,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.goNamed('consultation'),
                      child: const Text(
                        'Konsultasi',
                        style: TextStyle(
                          color: C.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  for (final topic in kTopics) ...[
                    TopicCard(
                      topic: topic,
                      onTap: () => _openDocument(topic),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Composer(
              controller: _ctrl,
              hint: AppStrings.describeIssue,
              onSend: _openChat,
              onSpeak: () => _showVoiceSheet(context),
            ),
          ),
        ]),
      ),
    );
  }

  void _showVoiceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _VoiceSheetProxy(
        onTranscribed: (text) {
          _ctrl.text = text;
        },
      ),
    );
  }
}

// Lightweight proxy to avoid circular imports
class _VoiceSheetProxy extends StatefulWidget {
  final ValueChanged<String> onTranscribed;
  const _VoiceSheetProxy({required this.onTranscribed});

  @override
  State<_VoiceSheetProxy> createState() => _VoiceSheetProxyState();
}

class _VoiceSheetProxyState extends State<_VoiceSheetProxy>
    with SingleTickerProviderStateMixin {
  late AnimationController _ring;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _ring = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _done = true);
      widget.onTranscribed(
          'I need help with a wrongful termination case. I was fired after reporting workplace harassment.');
      Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _ring.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: C.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: C.line,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        AnimatedBuilder(
          animation: _ring,
          builder: (_, child) {
            return SizedBox(
              width: 120,
              height: 120,
              child: Stack(alignment: Alignment.center, children: [
                ...List.generate(3, (i) {
                  final scale = 0.5 + ((_ring.value + i * 0.33) % 1.0) * 0.5;
                  final opacity = 1.0 - ((_ring.value + i * 0.33) % 1.0);
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: C.ink.withAlpha((opacity * 60).round()),
                      ),
                      width: 120,
                      height: 120,
                    ),
                  );
                }),
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: C.ink,
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.mic_rounded, color: C.white, size: 28),
                ),
              ]),
            );
          },
        ),
        const SizedBox(height: 20),
        Text(
          _done ? 'Processing…' : 'Listening…',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: C.ink,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Speak your legal issue clearly',
          style: TextStyle(fontSize: 13, color: C.gray),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel',
              style: TextStyle(color: C.gray, fontSize: 15)),
        ),
      ]),
    );
  }
}
