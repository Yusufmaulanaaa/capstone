import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/colors.dart';
import '../../../core/strings.dart';
import '../../../data/models/chat_model.dart';
import '../../../shared/widgets/widgets.dart';

class UserBubble extends StatelessWidget {
  final String text;
  final DocumentScanResult? scan;
  const UserBubble({super.key, required this.text, this.scan});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: text));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.copied),
              backgroundColor: C.ink,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        },
        child: Stack(clipBehavior: Clip.none, children: [
          Container(
            margin: const EdgeInsets.only(left: 20, right: 10, top: 12),
            padding: const EdgeInsets.fromLTRB(16, 14, 30, 14),
            decoration: BoxDecoration(
              color: C.card,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: C.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (scan != null) ...[
                  _ScanThumb(scan: scan!),
                  const SizedBox(height: 10),
                ],
                Text(
                  text,
                  style:
                      const TextStyle(fontSize: 14, color: C.ink, height: 1.5),
                ),
              ],
            ),
          ),
          const Positioned(
            right: 0,
            top: 0,
            child: Avatar(
              name: 'You',
              url: '',
              size: 38,
            ),
          ),
        ]),
      );
}

class AiBubble extends StatelessWidget {
  final String text;
  final DocumentScanResult? scan;
  final ValueChanged<String>? onQuickReply;

  const AiBubble({
    super.key,
    required this.text,
    this.scan,
    this.onQuickReply,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(AppStrings.copied),
                  backgroundColor: C.ink,
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Stack(clipBehavior: Clip.none, children: [
              Container(
                margin: const EdgeInsets.only(left: 10, right: 20, top: 14),
                padding: const EdgeInsets.fromLTRB(26, 14, 16, 14),
                decoration: BoxDecoration(
                  color: C.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: C.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (scan != null) ...[
                      _ScanResultCard(scan: scan!),
                      const SizedBox(height: 12),
                    ],
                    Text(
                      text,
                      style: const TextStyle(
                          fontSize: 14, color: C.ink, height: 1.5),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: C.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: C.line),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded,
                      size: 16, color: C.ink),
                ),
              ),
            ]),
          ),
          if (onQuickReply != null) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Wrap(spacing: 8, runSpacing: 8, children: [
                _QuickReplyChip(
                  label: 'Cari pengacara',
                  onTap: () => onQuickReply!(
                      'Tampilkan rekomendasi pengacara untuk kasus saya'),
                ),
                _QuickReplyChip(
                  label: 'Ringkasan kasus',
                  onTap: () =>
                      onQuickReply!('Buatkan ringkasan kronologi kasus saya'),
                ),
                _QuickReplyChip(
                  label: 'Checklist bukti',
                  onTap: () => onQuickReply!(
                      'Buat checklist bukti yang perlu saya siapkan'),
                ),
              ]),
            ),
          ],
        ],
      );
}

class _ScanThumb extends StatelessWidget {
  final DocumentScanResult scan;
  const _ScanThumb({required this.scan});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: C.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: C.line),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(
                scan.originalBytes,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                gaplessPlayback: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scan.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: C.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Dikirim untuk analisis PCD',
                    style: TextStyle(
                        fontSize: 12, color: C.gray.withValues(alpha: 1)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _ScanResultCard extends StatelessWidget {
  final DocumentScanResult scan;
  const _ScanResultCard({required this.scan});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [C.card, C.white],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: C.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: C.ink,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.document_scanner_rounded,
                      color: C.white, size: 18),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Hasil PCD Dokumen',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: C.ink,
                    ),
                  ),
                ),
                _Tag(label: scan.qualityLabel),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _ImagePanel(title: 'Asli', bytes: scan.originalBytes),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ImagePanel(
                      title: 'PCD (biner)', bytes: scan.processedBytes),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _MetricChip('Kategori', scan.detectedCategory),
                _MetricChip('Brightness',
                    '${(scan.brightness * 100).toStringAsFixed(0)}%'),
                _MetricChip(
                    'Kontras', '${(scan.contrast * 100).toStringAsFixed(0)}%'),
                _MetricChip('Ketajaman',
                    '${(scan.sharpness * 100).toStringAsFixed(0)}%'),
              ],
            ),
            const SizedBox(height: 10),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              dense: true,
              visualDensity: VisualDensity.compact,
              title: const Text(
                'Pipeline PCD',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: C.ink,
                ),
              ),
              children: [
                for (final step in scan.pcdSteps)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: Icon(Icons.circle, size: 6, color: C.gray),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(step,
                              style: const TextStyle(
                                  fontSize: 12.5, color: C.gray, height: 1.35)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
}

class _ImagePanel extends StatelessWidget {
  final String title;
  final Uint8List bytes;
  const _ImagePanel({required this.title, required this.bytes});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 11.5, fontWeight: FontWeight.w700, color: C.gray)),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child:
                  Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true),
            ),
          ),
        ],
      );
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});
  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(maxWidth: 130),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: C.ink.withAlpha(10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: C.ink.withAlpha(18)),
        ),
        child: Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 10.5, fontWeight: FontWeight.w700, color: C.ink),
        ),
      );
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  const _MetricChip(this.label, this.value);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: C.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: C.line),
        ),
        child: Text('$label: $value',
            style: const TextStyle(
                fontSize: 11.5, fontWeight: FontWeight.w600, color: C.ink)),
      );
}

class _QuickReplyChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickReplyChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: C.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: C.line),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: C.ink,
            ),
          ),
        ),
      );
}
