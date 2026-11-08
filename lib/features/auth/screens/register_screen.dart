import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/providers.dart';
import '../../../data/services/api_client.dart';
import '../../../shared/widgets/widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false; bool _loadingGoogle = false; bool _obscure = true;

  @override
  void dispose() { _name.dispose(); _email.dispose(); _password.dispose(); _confirm.dispose(); super.dispose(); }

  void _snack(String msg, {bool error = true}) { if (!mounted) return; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: error ? C.red : C.ink, behavior: SnackBarBehavior.floating)); }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      await ref.read(authProvider.notifier).register(name: _name.text, email: _email.text, password: _password.text);
      if (mounted) context.goNamed('home');
    } on ApiException catch (e) {
      _snack(e.message);
    } catch (_) {
      _snack('Tidak dapat terhubung ke server. Pastikan backend berjalan.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _google() async {
    setState(() => _loadingGoogle = true);
    try { await ref.read(authProvider.notifier).signInWithGoogle(); if (mounted) context.goNamed('home'); }
    on ApiException catch (e) { _snack(e.message); } catch (e) { _snack('$e'); }
    finally { if (mounted) setState(() => _loadingGoogle = false); }
  }

  @override
  Widget build(BuildContext context) {
    final busy = _loading || _loadingGoogle;
    return Scaffold(body: SafeArea(child: SingleChildScrollView(physics: const BouncingScrollPhysics(), padding: const EdgeInsets.fromLTRB(20, 14, 20, 24), child: Form(key: _form, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CircleBtn(icon: Icons.arrow_back_ios_new_rounded, onTap: () => context.canPop() ? context.pop() : context.goNamed('login'), semanticsLabel: 'Back'),
      const SizedBox(height: 18),
      const Text('Buat akun HukumIn', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: C.ink, height: 1.15)),
      const SizedBox(height: 8),
      const Text('Akun disimpan di backend agar chat, booking, dan notifikasi tersinkron.', style: TextStyle(fontSize: 14, color: C.gray, height: 1.45)),
      const SizedBox(height: 20),
      _Field(controller: _name, label: 'Nama lengkap', hint: 'Nama Anda', validator: (v) => (v ?? '').trim().length < 2 ? 'Nama wajib diisi' : null),
      const SizedBox(height: 12),
      _Field(controller: _email, label: 'Email', hint: 'nama@email.com', keyboardType: TextInputType.emailAddress, validator: (v) { final s = (v ?? '').trim(); if (s.isEmpty) return 'Email wajib diisi'; if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s)) return 'Format email tidak valid'; return null; }),
      const SizedBox(height: 12),
      _Field(controller: _password, label: 'Kata sandi', hint: 'Minimal 8 karakter', obscureText: _obscure, suffix: IconButton(onPressed: () => setState(() => _obscure = !_obscure), icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: C.gray, size: 20)), validator: (v) => (v ?? '').length < 8 ? 'Minimal 8 karakter' : null),
      const SizedBox(height: 12),
      _Field(controller: _confirm, label: 'Konfirmasi kata sandi', hint: 'Ulangi kata sandi', obscureText: _obscure, validator: (v) => v != _password.text ? 'Kata sandi tidak sama' : null),
      const SizedBox(height: 18),
      BlackButton(label: 'Daftar', onTap: busy ? null : _submit, loading: _loading),
      const SizedBox(height: 14),
      Row(children: [Expanded(child: Container(height: 1, color: C.line)), const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('atau', style: TextStyle(fontSize: 12.5, color: C.gray))), Expanded(child: Container(height: 1, color: C.line))]),
      const SizedBox(height: 14),
      _GoogleButton(label: 'Daftar dengan Google', loading: _loadingGoogle, onTap: busy ? null : _google),
      const SizedBox(height: 18),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('Sudah punya akun? ', style: TextStyle(color: C.gray, fontSize: 14)), GestureDetector(onTap: busy ? null : () => context.goNamed('login'), child: const Text('Masuk', style: TextStyle(color: C.ink, fontSize: 14, fontWeight: FontWeight.w700))) ]),
    ])))));
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller; final String label; final String hint; final TextInputType? keyboardType; final bool obscureText; final Widget? suffix; final String? Function(String?)? validator;
  const _Field({required this.controller, required this.label, required this.hint, this.keyboardType, this.obscureText = false, this.suffix, this.validator});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: C.ink)), const SizedBox(height: 8), TextFormField(controller: controller, keyboardType: keyboardType, obscureText: obscureText, validator: validator, style: const TextStyle(fontSize: 14.5, color: C.ink), decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: C.gray, fontSize: 14), filled: true, fillColor: C.card, suffixIcon: suffix, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: C.line)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: C.line)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: C.ink, width: 1.2))))]);
}

class _GoogleButton extends StatelessWidget {
  final String label; final bool loading; final VoidCallback? onTap;
  const _GoogleButton({required this.label, required this.loading, this.onTap});
  @override
  Widget build(BuildContext context) => SizedBox(width: double.infinity, height: 54, child: OutlinedButton(style: OutlinedButton.styleFrom(foregroundColor: C.ink, side: const BorderSide(color: C.line), backgroundColor: C.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))), onPressed: onTap, child: loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: C.ink)) : Row(mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 22, height: 22, alignment: Alignment.center, decoration: BoxDecoration(color: C.white, shape: BoxShape.circle, border: Border.all(color: C.line)), child: const Text('G', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: C.ink))), const SizedBox(width: 10), Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)))])));
}
