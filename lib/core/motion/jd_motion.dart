import 'package:flutter/material.dart';

/// Shared durations / curves — keep motion out of widgets as magic numbers.
abstract final class JdMotion {
  static const Duration fast = Duration(milliseconds: 220);
  static const Duration authStep = Duration(milliseconds: 320);
  static const Duration page = Duration(milliseconds: 420);
  static const Duration pageReverse = Duration(milliseconds: 360);
  static const Duration stagger = Duration(milliseconds: 90);
  static const Duration entrance = Duration(milliseconds: 700);
  static const Duration ringSweep = Duration(milliseconds: 650);
  static const Duration ringMorph = Duration(milliseconds: 480);
  static const Duration ringHold = Duration(milliseconds: 280);

  static const Duration rewardsRing = Duration(milliseconds: 1400);
  static const Duration rewardsTier = Duration(milliseconds: 520);
  static const Duration rewardsBadgePop = Duration(milliseconds: 560);
  static const Duration rewardsChallenge = Duration(milliseconds: 420);
  static const Duration qtyChange = Duration(milliseconds: 220);
  static const Duration bannerAutoPlay = Duration(seconds: 4);
  static const Duration bannerPage = Duration(milliseconds: 480);

  /// Spec Task 3 — points counter target on Rewards.
  static const int rewardsPointsCountTarget = 680000;

  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeInOut = Curves.easeInOutCubic;
  static const Curve emphasize = Curves.easeOutBack;

  /// [scope] keeps tags unique when the same product appears in multiple lists.
  static String productHeroTag(String productId, {String scope = 'main'}) =>
      'product-hero-$scope-$productId';

  static Duration reduced(BuildContext context, Duration full) {
    return MediaQuery.disableAnimationsOf(context) ? Duration.zero : full;
  }
}
