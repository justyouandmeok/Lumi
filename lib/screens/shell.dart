import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/app_icons.dart';
import 'explore_page.dart';
import 'home_page.dart';
import 'profile_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexoColors.background,
      body: IndexedStack(
        index: _index,
        children: const [
          HomePage(),
          ExplorePage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: NexoColors.surface,
          border: Border(top: BorderSide(color: NexoColors.line)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 58,
            child: Row(
              children: [
                _NavItem(
                  image: AppIcons.home,
                  selected: _index == 0,
                  invert: true,
                  onTap: () => setState(() => _index = 0),
                ),
                _NavItem(
                  image: AppIcons.explore,
                  selected: _index == 1,
                  onTap: () => setState(() => _index = 1),
                ),
                _NavItem(
                  image: AppIcons.profile,
                  selected: _index == 2,
                  circular: true,
                  onTap: () => setState(() => _index = 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.image,
    required this.selected,
    required this.onTap,
    this.circular = false,
    this.invert = false,
  });

  final ImageProvider image;
  final bool selected;
  final VoidCallback onTap;
  final bool circular;
  final bool invert;

  @override
  Widget build(BuildContext context) {
    Widget icon = Image(
      image: image,
      width: circular ? 28 : 30,
      height: circular ? 28 : 30,
      fit: BoxFit.contain,
      color: invert ? (selected ? NexoColors.text : NexoColors.muted) : null,
      colorBlendMode: invert ? BlendMode.srcIn : null,
    );

    if (circular) {
      icon = ClipOval(child: icon);
    }

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Opacity(
          opacity: selected ? 1 : 0.55,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: selected ? 16 : 0,
                height: 3,
                decoration: BoxDecoration(
                  color: NexoColors.accent,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
