import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/strings.dart';
import '../../../core/providers.dart';
import '../../../data/models/chat_model.dart';
import '../../../data/repositories/mock_repository.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../shared/widgets/lawyer_card.dart';
import '../widgets/chat_bubbles.dart';
import '../widgets/typing_indicator.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String? initial;
  const ChatScreen({super.key, this.initial});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  void _init() {
    final msgs = ref.read(chatProvider);
    if (msgs.isEmpty) {
      if (widget.initial == null) {
        ref.read(chatProvider.notifier).setMessages([
          ChatMessage(
            text: 'I reported workplace harassment a week before I was fired. '
                'Show me the best available lawyer.',
            isUser: true,
          ),
          ChatMessage(
            text: AppStrings.aiReply,
            isUser: false,
            hasLawyers: true,
          ),
        ]);
      } else {
        ref.read(chatProvider.notifier).addMessage(
              ChatMessage(text: widget.initial!, isUser: true),
            );
        ref.read(typingProvider.notifier).state = true;
        _scheduleReply();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scheduleReply() {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      ref.read(typingProvider.notifier).state = false;
      ref.read(chatProvider.notifier).addMessage(ChatMessage(
            text: AppStrings.aiReply,
            isUser: false,
            hasLawyers: true,
          ));
      _toBottom();
    });
  }

  void _send(String text) {
    final t = text.trim();
    if (t.isEmpty) return;
    ref
        .read(chatProvider.notifier)
        .addMessage(ChatMessage(text: t, isUser: true));
    ref.read(typingProvider.notifier).state = true;
    _ctrl.clear();
    _scheduleReply();
    _toBottom();
  }

  void _toBottom() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scroll.hasClients) return;
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      });

  @override
  Widget build(BuildContext context) {
    final msgs = ref.watch(chatProvider);
    final typing = ref.watch(typingProvider);
    final saved = ref.watch(chatSavedProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          HukumAppBar(
            title: AppStrings.legalAI,
            onBack: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.goNamed('home');
              }
            },
            action: Semantics(
              label: saved ? 'Unsave chat' : 'Save chat',
              button: true,
              child: CircleBtn(
                icon: saved
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                onTap: () =>
                    ref.read(chatSavedProvider.notifier).state = !saved,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scroll,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final m in msgs) ...[
                      m.isUser
                          ? UserBubble(text: m.text)
                          : AiBubble(
                              text: m.text,
                              onQuickReply: (reply) {
                                _send(reply);
                              },
                            ),
                      if (m.hasLawyers) ...[
                        const SizedBox(height: 14),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final l in kLawyers) ...[
                                LawyerCard(lawyer: l),
                                const SizedBox(width: 12),
                              ],
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                    ],
                    if (typing) const TypingIndicator(),
                  ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Composer(
              controller: _ctrl,
              hint: AppStrings.whatsNext,
              onSend: _send,
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
      builder: (_) => _VoiceBottomSheet(
        onTranscribed: (text) {
          _ctrl.text = text;
        },
      ),
    );
  }
}

class _VoiceBottomSheet extends StatefulWidget {
  final ValueChanged<String> onTranscribed;
  const _VoiceBottomSheet({required this.onTranscribed});

  @override
  State<_VoiceBottomSheet> createState() => _VoiceBottomSheetState();
}

class _VoiceBottomSheetState extends State<_VoiceBottomSheet>
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
      widget.onTranscribed(AppStrings.voiceSample);
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
                  final v = (_ring.value + i * 0.33) % 1.0;
                  final scale = 0.5 + v * 0.5;
                  final opacity = 1.0 - v;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: C.ink.withAlpha((opacity * 60).round()),
                      ),
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
          _done ? 'Processing…' : AppStrings.listening,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: C.ink,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          AppStrings.voiceSubtitle,
          style: TextStyle(fontSize: 13, color: C.gray),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            AppStrings.cancel,
            style: TextStyle(color: C.gray, fontSize: 15),
          ),
        ),
      ]),
    );
  }
}
