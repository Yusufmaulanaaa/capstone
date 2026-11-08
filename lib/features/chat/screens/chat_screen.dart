import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/providers.dart';
import '../../../core/strings.dart';
import '../../../data/models/chat_model.dart';
import '../../../data/models/lawyer_model.dart';
import '../../../data/services/api_client.dart';
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
  String? _datasetStatus;
  bool _loadingStatus = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  ChatMessage _welcome() => ChatMessage(
        text:
            'Halo! Saya asisten hukum HukumIn.\n\n'
            'Ceritakan masalah hukum Anda secara singkat (kronologi, pihak terkait, dan bukti jika ada). '
            'Saya akan mencari jawaban yang paling relevan dari dataset gabungan HukumIn (543 Legal QA + 500 klasifikasi kasus hukum) melalui server.',
        isUser: false,
      );

  Future<void> _init() async {
    final user = ref.read(authProvider);
    final chat = ref.read(chatProvider);
    final onlyWelcome = chat.messages.length == 1 && !chat.messages.first.isUser && chat.conversationId == null;
    if (chat.messages.isEmpty || onlyWelcome) {
      if (user != null) {
        final restored = await _restoreLastConversation();
        if (!restored && mounted) {
          ref.read(chatProvider.notifier).setMessages([_welcome()], restored: true);
        }
      } else if (chat.messages.isEmpty && mounted) {
        ref.read(chatProvider.notifier).setMessages([_welcome()], restored: true);
      }
    }
    if (user != null) {
      await _loadDatasetStatus();
    }
    if (!_sentInitial && (widget.initial?.trim().isNotEmpty ?? false)) {
      _sentInitial = true;
      await _send(widget.initial!.trim(), showText: true);
    }
  }

  Future<bool> _restoreLastConversation() async {
    try {
      final list = await ref.read(chatApiProvider).conversations();
      if (list.isEmpty) return false;
      final latest = list.first;
      final detail = await ref.read(chatApiProvider).detail(latest.id);
      final raw = detail['messages'];
      if (raw is! List || raw.isEmpty) return false;
      final msgs = raw.whereType<Map>().map((e) {
        final m = Map<String, dynamic>.from(e);
        return ChatMessage(text: '${m['content'] ?? ''}', isUser: '${m['role']}' == 'user');
      }).where((m) => m.text.trim().isNotEmpty).toList();
      if (msgs.isEmpty || !mounted) return false;
      ref.read(chatProvider.notifier).setMessages(msgs, conversationId: latest.id, restored: true);
      _toBottom();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _loadDatasetStatus() async {
    if (_loadingStatus) return;
    _loadingStatus = true;
    try {
      final raw = await ref.read(chatApiProvider).datasetStatus();
      final primary = raw['primary'] == true;
      final qa = raw['qaRows'] ?? raw['qa'] ?? 0;
      final cls = raw['classificationRows'] ?? raw['clsRows'] ?? raw['cls'] ?? 0;
      if (!mounted) return;
      setState(() {
        _datasetStatus = primary
            ? 'Dataset server aktif: $qa QA • $cls klasifikasi'
            : 'Dataset server: $qa QA • $cls klasifikasi';
      });
    } catch (_) {
      if (mounted) setState(() => _datasetStatus = 'Dataset server belum dapat dimuat (pastikan login & server aktif).');
    } finally {
      _loadingStatus = false;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _snack(String msg, {VoidCallback? action, String actionLabel = 'Login'}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: C.ink,
        behavior: SnackBarBehavior.floating,
        action: action == null ? null : SnackBarAction(label: actionLabel, textColor: C.white, onPressed: action),
      ),
    );
  }

  List<LawyerModel> _mapLawyers(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => LawyerModel.fromJson(Map<String, dynamic>.from(e)))
        .where((l) => l.name.trim().isNotEmpty)
        .toList();
  }

  Future<void> _send(String text, {bool showText = true}) async {
    final t = text.trim();
    if (t.isEmpty) return;
    final user = ref.read(authProvider);
    if (user == null) {
      _snack('Masuk terlebih dahulu untuk menggunakan chat.', action: () => context.pushNamed('login'));
      return;
    }
    if (showText) {
      ref.read(chatProvider.notifier).addMessage(ChatMessage(text: t, isUser: true));
    }
    _ctrl.clear();
    ref.read(typingProvider.notifier).state = true;
    _toBottom();
    try {
      final res = await ref.read(chatApiProvider).send(
            conversationId: ref.read(chatProvider).conversationId,
            message: t,
          );
      final conversationId = res['conversationId']?.toString();
      final msg = res['message'] is Map ? Map<String, dynamic>.from(res['message'] as Map) : <String, dynamic>{};
      final content = (msg['content'] ?? res['reply'] ?? res['answer'] ?? '').toString().trim();
      final dataset = res['dataset'] is Map ? Map<String, dynamic>.from(res['dataset'] as Map) : const <String, dynamic>{};
      final category = dataset['category']?.toString();
      final lawyers = _mapLawyers(res['lawyers']);
      final display = content.isNotEmpty
          ? content
          : 'Maaf, server tidak mengembalikan jawaban. Coba kirim ulang pertanyaan Anda.';
      ref.read(chatProvider.notifier).addMessage(
            ChatMessage(text: display, isUser: false, hasLawyers: lawyers.isNotEmpty, lawyers: lawyers),
          );
      if (conversationId != null && conversationId.isNotEmpty) {
        ref.read(chatProvider.notifier).setMessages(
              ref.read(chatProvider).messages,
              conversationId: conversationId,
            );
      }
      if (_datasetStatus == null) unawaited(_loadDatasetStatus());
      // keep category available for UX/debug via snack only when clearly mismatched? not needed.
      if (category != null && category.isEmpty) {}
    } catch (e) {
      final msg = e is ApiException
          ? e.message
          : 'Gagal terhubung ke server. Pastikan backend aktif dan Anda sudah login.';
      if (e is ApiException && e.statusCode == 401) {
        _snack('Sesi berakhir. Silakan login kembali.', action: () => context.pushNamed('login'));
      } else {
        _snack(msg);
      }
      ref.read(chatProvider.notifier).addMessage(
            ChatMessage(
              text:
                  'Maaf, saya belum bisa memproses permintaan Anda saat ini. Periksa koneksi ke server HukumIn, lalu coba lagi.',
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
        _scroll.animateTo(target, duration: const Duration(milliseconds: 320), curve: Curves.easeOut);
      });

  void _newConversation() {
    ref.read(chatProvider.notifier).newConversation();
    ref.read(chatProvider.notifier).setMessages([_welcome()]);
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatProvider);
    final typing = ref.watch(typingProvider);
    final saved = ref.watch(chatSavedProvider);
    final user = ref.watch(authProvider);
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
                    onTap: _newConversation,
                    semanticsLabel: 'Chat baru',
                  ),
                  const SizedBox(width: 8),
                  CircleBtn(
                    icon: saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    onTap: () => ref.read(chatSavedProvider.notifier).state = !saved,
                    semanticsLabel: saved ? 'Batal simpan chat' : 'Simpan chat',
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: C.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: C.line),
              ),
              child: Text(
                user == null
                    ? 'Login diperlukan agar chat terhubung ke dataset gabungan di server.'
                    : (_datasetStatus ?? 'Menghubungkan ke dataset gabungan server...'),
                style: const TextStyle(fontSize: 12, color: C.gray, fontWeight: FontWeight.w600),
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
                          : AiBubble(text: m.text, scan: m.scan, onQuickReply: (r) => _send(r)),
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
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text(
                'Jawaban berbasis dataset gabungan HukumIn (server). Ini informasi umum, bukan nasihat hukum resmi.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.5, color: C.gray),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Composer(controller: _ctrl, hint: AppStrings.whatsNext, onSend: _send),
            ),
          ],
        ),
      ),
    );
  }
}
