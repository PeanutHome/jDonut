import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class JdSkeleton extends StatefulWidget {
  const JdSkeleton({super.key, this.height = 16, this.width, this.radius = 8});

  final double height;
  final double? width;
  final double radius;

  @override
  State<JdSkeleton> createState() => _JdSkeletonState();
}

class _JdSkeletonState extends State<JdSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
      _c.value = 0.5;
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_c.value);
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1.2 + 2.4 * t, 0),
              end: Alignment(-0.2 + 2.4 * t, 0),
              colors: const [
                AppColors.skeletonBase,
                AppColors.skeletonHighlight,
                AppColors.skeletonBase,
              ],
              stops: const [0.25, 0.5, 0.75],
            ),
          ),
        );
      },
    );
  }
}

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppColors.pad),
      children: const [
        JdSkeleton(height: 88, radius: AppColors.radius),
        SizedBox(height: 16),
        JdSkeleton(height: 160, radius: 18),
        SizedBox(height: 24),
        JdSkeleton(height: 22, width: 160),
        SizedBox(height: 12),
        JdSkeleton(height: 180, radius: 15),
        SizedBox(height: 24),
        JdSkeleton(height: 22, width: 140),
        SizedBox(height: 12),
        JdSkeleton(height: 180, radius: 15),
      ],
    );
  }
}
