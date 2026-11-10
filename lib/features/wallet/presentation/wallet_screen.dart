import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/mmk_format.dart';
import '../../../core/theme/app_colors.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../catalog/domain/catalog_models.dart';
import '../../shell/presentation/jd_bottom_nav.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  static const routePath = '/wallet';
  static const routeName = 'wallet';

  static const _bg = Color(0xFFF0F2F3);
  static const _cyan = Color(0xFF55CBE4);

  static const _activity = <_WalletTx>[
    _WalletTx('Order · Coconut Donut', -3200, 'Today'),
    _WalletTx('Rewards · Eat 4 Coco', 100, 'Yesterday'),
    _WalletTx('Top-up (demo)', 50000, 'Mon'),
    _WalletTx('Order · Coffee', -2800, 'Sun'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(homeCatalogProvider);
    final bottom = JdBottomNav.heightFor(context);

    return ColoredBox(
      color: _bg,
      child: SafeArea(
        left: true,
        top: true,
        right: true,
        bottom: false,
        child: catalog.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Wallet unavailable\n$e', textAlign: TextAlign.center)),
          data: (data) => ListView(
            padding: EdgeInsets.fromLTRB(18, 12, 18, bottom + 16),
            children: [
              const Text(
                'Wallet',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF29323A)),
              ),
              const SizedBox(height: 16),
              _BalanceCard(member: data.member),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Top up — demo only')),
                    );
                  },
                  icon: const Icon(Icons.add_card_rounded),
                  label: const Text('Top up'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _cyan,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Recent activity',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF29323A)),
              ),
              const SizedBox(height: 10),
              for (final tx in _activity) _TxTile(tx: tx),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.member});

  final CatalogMember member;

  @override
  Widget build(BuildContext context) {
    final points = member.totalPoints;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF55CBE4), Color(0xFF3BB4D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: WalletScreen._cyan.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            member.displayName,
            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            '${formatMmk(points)} pts',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '≈ ${formatMmk(points * 10)} MMK store credit (demo)',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white54),
            ),
            child: Text(
              '${member.tier} member',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletTx {
  const _WalletTx(this.title, this.deltaPoints, this.when);

  final String title;
  final int deltaPoints;
  final String when;
}

class _TxTile extends StatelessWidget {
  const _TxTile({required this.tx});

  final _WalletTx tx;

  @override
  Widget build(BuildContext context) {
    final credit = tx.deltaPoints >= 0;
    final color = credit ? const Color(0xFF2E9E6B) : const Color(0xFF29323A);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDF0F2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: (credit ? AppColors.pink : WalletScreen._cyan).withValues(alpha: 0.15),
            child: Icon(
              credit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              size: 16,
              color: credit ? AppColors.pink : WalletScreen._cyan,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 2),
                Text(tx.when, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(
            '${credit ? '+' : ''}${formatMmk(tx.deltaPoints)}',
            style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
