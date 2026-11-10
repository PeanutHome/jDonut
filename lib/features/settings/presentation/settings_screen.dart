import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/jd_catalog_image.dart';
import '../../auth/application/auth_session_notifier.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../shell/presentation/jd_bottom_nav.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const routePath = '/more';
  static const routeName = 'more';

  static const _bg = Color(0xFFF0F2F3);
  static const _ink = Color(0xFF29323A);
  static const _cyan = Color(0xFF55CBE4);
  static const _pink = Color(0xFFF34E9B);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authSessionProvider).value;
    final member = ref.watch(memberProvider);
    final bottom = JdBottomNav.heightFor(context);

    return ColoredBox(
      color: _bg,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(18, 12, 18, bottom + 16),
          children: [
            const Text(
              'More',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _ink),
            ),
            const SizedBox(height: 16),
            _ProfileCard(
              name: member?.displayName ?? 'Member',
              phone: user?.phoneE164 ?? '—',
              tier: member?.tier ?? 'Bronze',
              avatarAsset: member?.avatarAsset,
            ),
            const SizedBox(height: 18),
            _Section(
              title: 'Account',
              children: [
                _Tile(
                  icon: Icons.person_outline_rounded,
                  label: 'Profile',
                  onTap: () => _soon(context),
                ),
                _Tile(
                  icon: Icons.notifications_none_rounded,
                  label: 'Notifications',
                  onTap: () => _soon(context),
                ),
                _Tile(
                  icon: Icons.location_on_outlined,
                  label: 'Saved addresses',
                  onTap: () => _soon(context),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _Section(
              title: 'Support',
              children: [
                _Tile(
                  icon: Icons.help_outline_rounded,
                  label: 'Help center',
                  onTap: () => _soon(context),
                ),
                _Tile(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Contact us',
                  onTap: () => _soon(context),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _Section(
              title: 'App',
              children: [
                _Tile(
                  icon: Icons.description_outlined,
                  label: 'Terms of use',
                  onTap: () => _soon(context),
                ),
                _Tile(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy policy',
                  onTap: () => _soon(context),
                ),
              ],
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(authSessionProvider.notifier).logout();
                  if (context.mounted) context.go(AppRoutes.onboarding);
                },
                icon: const Icon(Icons.logout_rounded, color: _pink),
                label: const Text(
                  'Log out',
                  style: TextStyle(fontWeight: FontWeight.w700, color: _pink),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _pink, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'J’Donuts · demo build',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary.withValues(alpha: 0.8)),
            ),
          ],
        ),
      ),
    );
  }

  void _soon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon')),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.name,
    required this.phone,
    required this.tier,
    this.avatarAsset,
  });

  final String name;
  final String phone;
  final String tier;
  final String? avatarAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDF0F2)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 56,
              height: 56,
              child: avatarAsset == null
                  ? const ColoredBox(
                      color: Color(0xFFE8EBED),
                      child: Icon(Icons.person, color: Color(0xFF8A939C)),
                    )
                  : JdCatalogImage(
                      asset: avatarAsset!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      preferAsset: true,
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: SettingsScreen._ink),
                ),
                const SizedBox(height: 3),
                Text(phone, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: SettingsScreen._cyan.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              tier,
              style: const TextStyle(
                color: SettingsScreen._cyan,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: Color(0xFF8A939C),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFEDF0F2)),
          ),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  const Divider(height: 1, indent: 54, color: Color(0xFFEDF0F2)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: SettingsScreen._cyan.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: SettingsScreen._cyan),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: SettingsScreen._ink),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFB0B8C0)),
            ],
          ),
        ),
      ),
    );
  }
}
