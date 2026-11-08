import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/colors.dart';

// ──────────────────────────────────────────────
// Avatar with cached network image + initials fallback
// ──────────────────────────────────────────────

class Avatar extends StatelessWidget {
  final String name;
  final String url;
  final double size;

  const Avatar({
    super.key,
    required this.name,
    required this.url,
    this.size = 44,
  });

  Widget _fallback() => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        color: C.line,
        child: Text(
          name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase(),
          style: TextStyle(
            color: C.ink,
            fontWeight: FontWeight.w700,
            fontSize: size * 0.4,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            placeholder: (_, __) => _fallback(),
            errorWidget: (_, __, ___) => _fallback(),
          ),
        ),
      );
}

// ──────────────────────────────────────────────
// CircleBtn
// ──────────────────────────────────────────────

class CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool dot;
  final String? semanticsLabel;

  const CircleBtn({
    super.key,
    required this.icon,
    this.onTap,
    this.dot = false,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) => Semantics(
        label: semanticsLabel ?? '',
        button: true,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: C.white,
              shape: BoxShape.circle,
              border: Border.all(color: C.line),
            ),
            child: Stack(alignment: Alignment.center, children: [
              Icon(icon, size: 20, color: C.ink),
              if (dot)
                Positioned(
                  top: 11,
                  right: 11,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: C.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ]),
          ),
        ),
      );
}

// ──────────────────────────────────────────────
// BlackButton — full-width primary CTA
// ──────────────────────────────────────────────

class BlackButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool loading;

  const BlackButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 54,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: C.ink,
            foregroundColor: C.white,
            disabledBackgroundColor: C.ink.withAlpha(100),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: loading ? null : onTap,
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child:
                      CircularProgressIndicator(strokeWidth: 2, color: C.white),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (icon != null) ...[
                      const SizedBox(width: 8),
                      Icon(icon, size: 18),
                    ],
                  ],
                ),
        ),
      );
}

// ──────────────────────────────────────────────
// OutlinedPillButton
// ──────────────────────────────────────────────

class OutlinedPillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;

  const OutlinedPillButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 54,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: C.ink,
            side: const BorderSide(color: C.ink),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 8),
                Icon(icon, size: 18),
              ],
            ],
          ),
        ),
      );
}

// ──────────────────────────────────────────────
// Composer
// ──────────────────────────────────────────────

class Composer extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onSend;
  final VoidCallback? onSpeak;
  final VoidCallback? onAttach;

  const Composer({
    super.key,
    required this.controller,
    required this.hint,
    required this.onSend,
    this.onSpeak,
    this.onAttach,
  });

  Widget _dark(Widget child, {double size = 40, VoidCallback? onTap}) =>
      InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(color: C.ink, shape: BoxShape.circle),
          child: child,
        ),
      );

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 10),
        decoration: BoxDecoration(
          color: C.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: C.ink, width: 1.2),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: controller,
            minLines: 2,
            maxLines: 4,
            style: const TextStyle(fontSize: 14.5, color: C.ink),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(color: C.gray, fontSize: 14.5),
            ),
          ),
          const SizedBox(height: 10),
          Row(children: [
            _dark(
              const Icon(Icons.attach_file_rounded, color: C.white, size: 21),
              onTap: onAttach,
            ),
            const SizedBox(width: 8),
            Flexible(
              fit: FlexFit.loose,
              child: Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: onSpeak,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
                        decoration: BoxDecoration(
                          color: C.ink,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 15,
                              backgroundColor: Color(0x33FFFFFF),
                              child: Icon(Icons.mic_none_rounded,
                                  size: 16, color: C.white),
                            ),
                            SizedBox(width: 6),
                            Text('Rekam',
                                style: TextStyle(
                                    color: C.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                    Semantics(
                      label: 'Kirim pesan',
                      button: true,
                      child: _dark(
                        const Icon(Icons.near_me_rounded,
                            color: C.white, size: 20),
                        onTap: () => onSend(controller.text),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ]),
      );
}

// ──────────────────────────────────────────────
// CopyableText — long-press to copy
// ──────────────────────────────────────────────

class CopyableText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const CopyableText({super.key, required this.text, this.style});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: text));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tersalin ke clipboard'),
              backgroundColor: C.ink,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        },
        child: Text(text, style: style),
      );
}

// ──────────────────────────────────────────────
// AppBar row (back + title + action)
// ──────────────────────────────────────────────

class HukumAppBar extends StatelessWidget {
  final String title;
  final Widget? action;
  final VoidCallback? onBack;

  const HukumAppBar({
    super.key,
    required this.title,
    this.action,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
        child: Row(children: [
          CircleBtn(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: onBack ?? () => Navigator.of(context).maybePop(),
            semanticsLabel: 'Kembali',
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: C.ink,
                ),
              ),
            ),
          ),
          if (action != null) action! else const SizedBox(width: 46),
        ]),
      );
}
