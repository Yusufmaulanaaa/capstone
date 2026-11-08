import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/providers.dart';
import '../../../core/strings.dart';
import '../../../data/models/chat_model.dart';
import '../../../data/models/lawyer_model.dart';
import '../../../data/repositories/mock_repository.dart';
import '../../../shared/widgets/lawyer_card.dart';
import '../../../shared/widgets/widgets.dart';
import '../widgets/chat_bubbles.dart';
import '../widgets/typing_indicator.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String? initial;
  const ChatScreen({super.key, this.initial});
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  bool _sentInitial = false;
  bool _datasetReady = false;
  String? _datasetError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    final chat = ref.read(chatProvider);
    if (chat.messages.isEmpty) {
      ref.read(chatProvider.notifier).setMessages([
        ChatMessage(
          text:
              'Halo! Saya asisten hukum HukumIn. Saya menjawab berdasarkan dataset lokal:\n'
              '• Indonesian Legal QA (543 baris)\n'
              '• Dataset klasifikasi kasus hukum (500 baris)\n\n'
              'Ceritakan masalah hukum Anda (penipuan, penggelapan, pencurian, penganiayaan, pencemaran nama baik, dll.), '
              'atau ajukan pertanyaan hukum. Jawaban diambil dari kemiripan pertanyaan/jawaban pada dataset (TF-IDF) dan klasifikasi kategori.',
          isUser: false,
        ),
      ]);
    }
    try {
      final qa = ref.read(legalQaProvider);
      await qa.ensureLoaded();
      if (mounted) {
        setState(() {
          _datasetReady = qa.isReady;
          _datasetError = qa.isReady ? null : 'Dataset belum termuat.';
        });
      }
    } catch (e) {
      if (mounted) setState(() => _datasetError = '$e');
    }
    if (!_sentInitial && (widget.initial?.trim().isNotEmpty ?? false)) {
      _sentInitial = true;
      await _send(widget.initial!.trim(), true);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg),
          backgroundColor: C.ink,
          behavior: SnackBarBehavior.floating),
    );
  }

  List<LawyerModel> _recommendedLawyers(String text, String? category) {
    final t = '${category ?? ''} $text'.toLowerCase();
    bool has(List<String> keys) => keys.any(t.contains);
    final all = kLawyers;
    if (has(['cema', 'nama baik', 'fitnah', 'ujaran'])) {
      return all
          .where((l) => '${l.role} ${l.practiceAreas.join(' ')}'
              .toLowerCase()
              .contains('cema'))
          .toList();
    }
    if (has(['aniaya', 'pukul', 'kekerasan', 'luka'])) {
      return all
          .where((l) =>
              '${l.role} ${l.practiceAreas.join(' ')}'
                  .toLowerCase()
                  .contains('aniaya') ||
              '${l.practiceAreas.join(' ')}'.toLowerCase().contains('pidana'))
          .toList();
    }
    if (has(['tipu', 'gelap', 'curi', 'pidana', 'lapor'])) {
      return all
          .where((l) => '${l.role} ${l.practiceAreas.join(' ')}'
              .toLowerCase()
              .contains('pidana'))
          .toList();
    }
    return category != null || t.split(RegExp(r'\s+')).length > 4
        ? all.take(2).toList()
        : const [];
  }

  Future<void> _send(String text, [bool showText = true]) async {
    final t = text.trim();
    if (t.isEmpty) return;
    if (showText) {
      ref
          .read(chatProvider.notifier)
          .addMessage(ChatMessage(text: t, isUser: true));
    }
    _ctrl.clear();
    ref.read(typingProvider.notifier).state = true;
    _toBottom();
    try {
      final qa = ref.read(legalQaProvider);
      await qa.ensureLoaded();
      // Small delay for natural UX
      await Future<void>.delayed(const Duration(milliseconds: 350));
      final result = qa.answer(t);
      final lawyers = _recommendedLawyers(t, result.category);
      ref.read(chatProvider.notifier).addMessage(
            ChatMessage(
              text: result.reply,
              isUser: false,
              hasLawyers: lawyers.isNotEmpty,
              lawyers: List.from(lawyers),
            ),
          );
      if (!_datasetReady && qa.isReady && mounted) {
        setState(() => _datasetReady = true);
      }
    } catch (e) {
      _snack('Gagal memproses pertanyaan: $e');
      ref.read(chatProvider.notifier).addMessage(
            ChatMessage(
              text:
                  'Maaf, terjadi kendala saat membaca dataset lokal. Pastikan aset dataset tersedia, lalu coba lagi.',
              isUser: false,
            ),
          );
    } finally {
      if (mounted) ref.read(typingProvider.notifier).state = false;
      _toBottom();
    }
  }

  void _toBottom() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scroll.hasClients) return;
        final target = _scroll.position.maxScrollExtent + 220;
        _scroll.animateTo(
          target,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOut,
        );
      });

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatProvider);
    final typing = ref.watch(typingProvider);
    final saved = ref.watch(chatSavedProvider);
    final qa = ref.read(legalQaProvider);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            HukumAppBar(
              title: AppStrings.legalAI,
              onBack: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.goNamed('home');
                }
              },
              action: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleBtn(
                    icon: Icons.add_comment_outlined,
                    onTap: () =>
                        ref.read(chatProvider.notifier).newConversation(),
                    semanticsLabel: 'Chat baru',
                  ),
                  const SizedBox(width: 8),
                  CircleBtn(
                    icon: saved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    onTap: () =>
                        ref.read(chatSavedProvider.notifier).state = !saved,
                    semanticsLabel: saved ? 'Batal simpan chat' : 'Simpan chat',
                  ),
                ],
              ),
            ),
            if (_datasetReady || qa.isReady)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: C.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: C.line),
                ),
                child: Text(
                  'Dataset aktif: QA ${qa.qaCount} baris • Klasifikasi ${qa.clsCount} baris',
                  style: const TextStyle(
                      fontSize: 12, color: C.gray, fontWeight: FontWeight.w600),
                ),
              )
            else if (_datasetError != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: C.line),
                ),
                child: const Text(
                  'Dataset lokal sedang dimuat/gagal dimuat. Coba kirim pertanyaan lagi.',
                  style: TextStyle(fontSize: 12, color: C.ink),
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scroll,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final m in chat.messages) ...[
                      m.isUser
                          ? UserBubble(text: m.text, scan: m.scan)
                          : AiBubble(
                              text: m.text,
                              scan: m.scan,
                              onQuickReply: (r) => _send(r)),
                      if (m.hasLawyers && m.lawyers.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final l in m.lawyers) ...[
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
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: const Text(
                'AI memberi informasi umum dari dataset, bukan nasihat hukum.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.5, color: C.gray),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Composer(
                  controller: _ctrl, hint: AppStrings.whatsNext, onSend: _send),
            ),
          ],
        ),
      ),
    );
  }
}
