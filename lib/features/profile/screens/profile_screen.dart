import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../shared/widgets/widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: C.ink,
                      ),
                    ),
                  ),
                  CircleBtn(
                    icon: Icons.settings_outlined,
                    onTap: () {},
                    semanticsLabel: 'Settings',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [C.ink, Color(0xFF262632)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x290A0A0F),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: C.gold, width: 2),
                      ),
                      child: const Avatar(
                        name: 'Mike',
                        url: 'https://i.pravatar.cc/150?img=68',
                        size: 58,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mike',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: C.white,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'mike@email.com',
                            style: TextStyle(
                                fontSize: 13, color: Color(0xCCFFFFFF)),
                          ),
                          SizedBox(height: 8),
                          _Badge(label: 'Member HukumIn'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Row(
                children: [
                  _StatCard(label: 'Kasus', value: '3'),
                  SizedBox(width: 10),
                  _StatCard(label: 'Konsultasi', value: '2'),
                  SizedBox(width: 10),
                  _StatCard(label: 'Tersimpan', value: '5'),
                ],
              ),
              const SizedBox(height: 18),
              _Tile(
                icon: Icons.bookmark_outline_rounded,
                label: 'Tersimpan',
                onTap: () => context.pushNamed('saved'),
              ),
              _Tile(
                icon: Icons.notifications_none_rounded,
                label: 'Notifikasi',
                onTap: () => context.pushNamed('notifications'),
              ),
              _Tile(
                icon: Icons.description_outlined,
                label: 'Dokumen saya',
                onTap: () {},
              ),
              _Tile(
                icon: Icons.verified_user_outlined,
                label: 'Privasi & keamanan',
                onTap: () {},
              ),
              _Tile(
                icon: Icons.help_outline_rounded,
                label: 'Bantuan',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: C.gold.withAlpha(45),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: C.gold.withAlpha(120)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: C.gold,
          ),
        ),
      );
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: C.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: C.line),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: C.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(fontSize: 12, color: C.gray)),
            ],
          ),
        ),
      );
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Tile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: C.white,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: C.line),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: C.card,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: C.ink, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: C.ink,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: C.gray),
                ],
              ),
            ),
          ),
        ),
      );
}
