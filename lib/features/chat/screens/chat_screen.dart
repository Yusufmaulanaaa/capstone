import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/colors.dart';
import '../../../core/strings.dart';
import '../../../core/providers.dart';
import '../../../data/models/chat_model.dart';
import '../../../data/repositories/mock_repository.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../shared/widgets/lawyer_card.dart';
import '../services/document_scan_service.dart';
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
  final ImagePicker _picker = ImagePicker();
  final DocumentScanService _scanService = const DocumentScanService();
  Timer? _timer;
  bool _processingDoc = false;

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
            text:
                'Halo! Saya asisten hukum HukumIn. Ceritakan kasus Anda (penipuan, penggelapan, pencurian, penganiayaan, atau pencemaran nama baik), atau unggah foto dokumen/bukti agar saya bantu analisis awal dengan fitur PCD.',
            isUser: false,
          ),
        ]);
      } else {
        ref.read(chatProvider.notifier).addMessage(
              ChatMessage(text: widget.initial!, isUser: true),
            );
        ref.read(typingProvider.notifier).state = true;
        _scheduleReply(widget.initial!);
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

  void _scheduleReply(String contextText) {
    _timer?.cancel();
    final lower = contextText.toLowerCase();
    final needsLawyers = lower.contains('pengacara') ||
        lower.contains('rekomendasi') ||
        lower.contains('konsultasi') ||
        lower.contains('penipuan') ||
        lower.contains('penggelapan') ||
        lower.contains('pencurian') ||
        lower.contains('penganiayaan') ||
        lower.contains('pencemaran');
    _timer = Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      ref.read(typingProvider.notifier).state = false;
      final reply = _buildReply(lower);
      ref.read(chatProvider.notifier).addMessage(ChatMessage(
            text: reply,
            isUser: false,
            hasLawyers: needsLawyers,
          ));
      _toBottom();
    });
  }

  String _buildReply(String lower) {
    if (lower.contains('ringkasan') || lower.contains('kronologi')) {
      return 'Untuk ringkasan kasus, mohon siapkan:\n1) Waktu & tempat kejadian\n2) Pihak terlibat\n3) Kronologi singkat\n4) Bukti (chat, transfer, foto, saksi)\n5) Kerugian yang dialami.\n\nAnda bisa unggah foto dokumen/bukti lewat tombol lampiran agar saya bantu pratinjau kualitas dan kategorinya (PCD).';
    }
    if (lower.contains('checklist') || lower.contains('bukti')) {
      return 'Checklist bukti awal yang disarankan:\n• Identitas pelapor/korban\n• Kronologi tertulis\n• Bukti digital (screenshot/chat) — simpan asli\n• Bukti transaksi/foto dokumen\n• Data saksi (jika ada)\n• Laporan/nomor aduan jika sudah dibuat\n\nUnggah gambar dokumen untuk analisis PCD (peningkatan kontras, binarisasi, estimasi kualitas bacaan).';
    }
    if (lower.contains('pencemaran')) {
      return 'Kasus pencemaran nama baik biasanya memerlukan bukti digital (tautan, screenshot, waktu unggah, akun pelaku). Simpan bukti asli dan hindari konfrontasi publik. Saya bisa bantu analisis awal dokumen/screenshot Anda lewat fitur PCD dan merekomendasikan pengacara relevan.';
    }
    return 'Baik, saya catat informasi awal Anda. Untuk analisis yang lebih membantu, jelaskan kronologi singkat dan unggah foto dokumen/bukti (surat, bukti transfer, screenshot) bila ada. Sistem akan menjalankan pipeline PCD (grayscale, reduksi noise, threshold Otsu, binarisasi/penajaman) untuk pratinjau dokumen, lalu memberi rekomendasi langkah dan pengacara.';
  }

  Future<void> _pickDocument() async {
    if (_processingDoc) return;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _DocSourceSheet(),
    );
    if (source == null) return;
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 92,
      maxWidth: 2200,
    );
    if (picked == null) return;
    setState(() => _processingDoc = true);
    try {
      final bytes = await picked.readAsBytes();
      final scan = _scanService.process(fileName: picked.name, bytes: bytes);
      if (!mounted) return;
      ref.read(chatProvider.notifier).addMessage(ChatMessage(
            text: 'Saya mengunggah dokumen: ${picked.name}',
            isUser: true,
            scan: scan,
          ));
      ref.read(typingProvider.notifier).state = true;
      _toBottom();
      _timer?.cancel();
      _timer = Timer(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        ref.read(typingProvider.notifier).state = false;
        ref.read(chatProvider.notifier).addMessage(ChatMessage(
              text: scan.summary,
              isUser: false,
              scan: scan,
              hasLawyers: true,
            ));
        setState(() => _processingDoc = false);
        _toBottom();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _processingDoc = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memproses dokumen: $e'),
          backgroundColor: C.ink,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _send(String text) {
    final t = text.trim();
    if (t.isEmpty) return;
    ref
        .read(chatProvider.notifier)
        .addMessage(ChatMessage(text: t, isUser: true));
    ref.read(typingProvider.notifier).state = true;
    _ctrl.clear();
    _scheduleReply(t);
    _toBottom();
  }

  void _toBottom() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scroll.hasClients) return;
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 120,
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
                          ? UserBubble(text: m.text, scan: m.scan)
                          : AiBubble(
                              text: m.text,
                              scan: m.scan,
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
              onAttach: _processingDoc ? null : _pickDocument,
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
          _done ? 'Memproses suara…' : AppStrings.listening,
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

class _DocSourceSheet extends StatelessWidget {
  const _DocSourceSheet();

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          color: C.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: SafeArea(
          top: false,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: C.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Unggah Dokumen (PCD)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: C.ink,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Pilih foto dokumen/bukti. Sistem akan melakukan praproses citra untuk analisis awal.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: C.gray, height: 1.4),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: _SourceAction(
                  icon: Icons.photo_library_outlined,
                  label: 'Galeri',
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SourceAction(
                  icon: Icons.photo_camera_outlined,
                  label: 'Kamera',
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
              ),
            ]),
          ]),
        ),
      );
}

class _SourceAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SourceAction(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: C.card,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: C.line),
            ),
            child: Column(
              children: [
                Icon(icon, color: C.ink),
                const SizedBox(height: 8),
                Text(label,
                    style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: C.ink)),
              ],
            ),
          ),
        ),
      );
}
