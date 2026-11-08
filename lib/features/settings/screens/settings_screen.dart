import 'package:flutter/material.dart';
import '../../../core/colors.dart';
import '../../../shared/widgets/widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _lang = 'id';
  double _textScale = 1.0;
  String _theme = 'system';
  bool _nChat = true, _nBooking = true, _nCase = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(children: [
        HukumAppBar(
            title: 'Pengaturan',
            onBack: () => Navigator.of(context).maybePop()),
        Expanded(
            child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
              _Card(
                  title: 'Bahasa',
                  child: DropdownButton<String>(
                      value: _lang,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      items: const [
                        DropdownMenuItem(value: 'id', child: Text('Indonesia')),
                        DropdownMenuItem(value: 'en', child: Text('English'))
                      ],
                      onChanged: (v) => setState(() => _lang = v ?? 'id'))),
              _Card(
                  title: 'Ukuran teks (${_textScale.toStringAsFixed(1)}x)',
                  child: Slider(
                      value: _textScale,
                      min: 0.9,
                      max: 1.3,
                      divisions: 4,
                      activeColor: C.ink,
                      inactiveColor: C.line,
                      onChanged: (v) => setState(() => _textScale = v))),
              _Card(
                  title: 'Tema',
                  child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'light', label: Text('Terang')),
                        ButtonSegment(value: 'dark', label: Text('Gelap')),
                        ButtonSegment(value: 'system', label: Text('Sistem'))
                      ],
                      selected: {
                        _theme
                      },
                      onSelectionChanged: (s) =>
                          setState(() => _theme = s.first),
                      showSelectedIcon: false)),
              _Card(
                  title: 'Notifikasi',
                  child: Column(children: [
                    SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        activeColor: C.ink,
                        value: _nChat,
                        onChanged: (v) => setState(() => _nChat = v),
                        title: const Text('Balasan chat')),
                    SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        activeColor: C.ink,
                        value: _nBooking,
                        onChanged: (v) => setState(() => _nBooking = v),
                        title: const Text('Pengingat booking')),
                    SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        activeColor: C.ink,
                        value: _nCase,
                        onChanged: (v) => setState(() => _nCase = v),
                        title: const Text('Update kasus')),
                  ])),
              _Card(
                title: 'Privasi',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Hapus riwayat chat'),
                  subtitle: const Text('Simulasi - konfirmasi diperlukan'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () async {
                    final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                                title: const Text('Hapus riwayat chat?'),
                                content: const Text(
                                    'Tindakan ini disimulasikan pada prototype.'),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Batal')),
                                  FilledButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Hapus'))
                                ]));
                    if (ok == true && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Riwayat chat (simulasi) dibersihkan.'),
                        ),
                      );
                    }
                  },
                ),
              ),
              _Card(
                title: 'Tentang & Disclaimer',
                child: const Text(
                    'HukumIn adalah prototype konsultasi hukum berbasis AI. AI memberikan informasi umum, bukan nasihat hukum. Keputusan hukum harus dikonsultasikan dengan pengacara berlisensi.',
                    style:
                        TextStyle(fontSize: 13.5, color: C.gray, height: 1.45)),
              ),
            ])),
      ])),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  const _Card({required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: C.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: C.line),
          boxShadow: const [
            BoxShadow(
                color: Color(0x080A0A0F), blurRadius: 10, offset: Offset(0, 4))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                fontSize: 14.5, fontWeight: FontWeight.w700, color: C.ink)),
        const SizedBox(height: 8),
        child
      ]));
}
