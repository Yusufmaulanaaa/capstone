import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/colors.dart';
import '../../../core/strings.dart';
import '../../../shared/widgets/widgets.dart';

class UserBubble extends StatelessWidget {
  final String text;
  const UserBubble({super.key, required this.text});

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
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: C.ink, height: 1.5),
            ),
          ),
          const Positioned(
            right: 0,
            top: 0,
            child: Avatar(
              name: 'Mike',
              url: 'https://i.pravatar.cc/150?img=68',
              size: 38,
            ),
          ),
        ]),
      );
}

class AiBubble extends StatelessWidget {
  final String text;
  final ValueChanged<String>? onQuickReply;

  const AiBubble({super.key, required this.text, this.onQuickReply});

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
                child: Text(
                  text,
                  style:
                      const TextStyle(fontSize: 14, color: C.ink, height: 1.5),
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
                  label: 'Rekomendasi pengacara',
                  onTap: () => onQuickReply!(
                      'Tampilkan rekomendasi pengacara untuk kasus saya'),
                ),
                _QuickReplyChip(
                  label: 'Buat ringkasan kasus',
                  onTap: () =>
                      onQuickReply!('Buatkan ringkasan kronologi kasus saya'),
                ),
              ]),
            ),
          ],
        ],
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
