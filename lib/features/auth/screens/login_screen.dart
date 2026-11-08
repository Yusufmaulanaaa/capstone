import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/providers.dart';
import '../../../shared/widgets/widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _loadingGoogle = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      await ref.read(authProvider.notifier).login(
            email: _email.text,
            password: _password.text,
          );
      if (mounted) context.goNamed('home');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _google() async {
    setState(() => _loadingGoogle = true);
    try {
      await ref.read(authProvider.notifier).signInWithGoogle();
      if (mounted) context.goNamed('home');
    } finally {
      if (mounted) setState(() => _loadingGoogle = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = _loading || _loadingGoogle;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: c.maxHeight - 38),
              child: IntrinsicHeight(
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleBtn(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => context.canPop() ? context.pop() : null,
                        semanticsLabel: 'Back',
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: C.ink,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.balance_rounded,
                            color: C.white, size: 26),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Masuk ke HukumIn',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: C.ink,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Lanjutkan untuk konsultasi kasus dan temukan pengacara.',
                        style: TextStyle(
                            fontSize: 14, color: C.gray, height: 1.45),
                      ),
                      const SizedBox(height: 22),
                      _AuthField(
                        controller: _email,
                        label: 'Email',
                        hint: 'nama@email.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          final s = (v ?? '').trim();
                          if (s.isEmpty) return 'Email wajib diisi';
                          final ok =
                              RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s);
                          if (!ok) return 'Format email tidak valid';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _AuthField(
                        controller: _password,
                        label: 'Kata sandi',
                        hint: 'Masukkan kata sandi',
                        obscureText: _obscure,
                        suffix: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: C.gray,
                            size: 20,
                          ),
                        ),
                        validator: (v) =>
                            (v ?? '').length < 8 ? 'Minimal 8 karakter' : null,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: busy
                              ? null
                              : () => context.pushNamed('forgotPassword'),
                          child: const Text('Lupa kata sandi?',
                              style: TextStyle(
                                  color: C.ink,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13)),
                        ),
                      ),
                      const SizedBox(height: 18),
                      BlackButton(
                        label: 'Masuk',
                        onTap: busy ? null : _submit,
                        loading: _loading,
                      ),
                      const SizedBox(height: 14),
                      Row(children: [
                        Expanded(child: Container(height: 1, color: C.line)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('atau',
                              style: TextStyle(fontSize: 12.5, color: C.gray)),
                        ),
                        Expanded(child: Container(height: 1, color: C.line)),
                      ]),
                      const SizedBox(height: 14),
                      _GoogleButton(
                        label: 'Masuk dengan Google',
                        loading: _loadingGoogle,
                        onTap: busy ? null : _google,
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: TextButton(
                          onPressed: busy
                              ? null
                              : () async {
                                  await ref
                                      .read(settingsProvider.notifier)
                                      .setGuestMode(true);
                                  await ref
                                      .read(settingsProvider.notifier)
                                      .markFirstLaunchSeen();
                                  if (context.mounted) context.goNamed('home');
                                },
                          child: const Text('Lanjut sebagai tamu',
                              style: TextStyle(
                                  color: C.gray, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Prototype: login Google disimulasikan tanpa konfigurasi OAuth/Firebase.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 11.5, color: C.gray, height: 1.35),
                      ),
                      const Spacer(),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Belum punya akun? ',
                              style: TextStyle(color: C.gray, fontSize: 14)),
                          GestureDetector(
                            onTap:
                                busy ? null : () => context.goNamed('register'),
                            child: const Text(
                              'Daftar',
                              style: TextStyle(
                                color: C.ink,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final String? Function(String?)? validator;
  const _AuthField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13.5, fontWeight: FontWeight.w600, color: C.ink)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            validator: validator,
            style: const TextStyle(fontSize: 14.5, color: C.ink),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: C.gray, fontSize: 14),
              filled: true,
              fillColor: C.card,
              suffixIcon: suffix,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: C.line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: C.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: C.ink, width: 1.2),
              ),
            ),
          ),
        ],
      );
}

class _GoogleButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onTap;
  const _GoogleButton({required this.label, required this.loading, this.onTap});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 54,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: C.ink,
            side: const BorderSide(color: C.line),
            backgroundColor: C.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: onTap,
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child:
                      CircularProgressIndicator(strokeWidth: 2, color: C.ink),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: C.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: C.line),
                      ),
                      child: const Text('G',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: C.ink)),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
        ),
      );
}
