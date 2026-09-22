import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/post.dart';
import '../state/scope.dart';
import '../theme.dart';
import '../widgets/user_avatar.dart';
import 'gallery_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStateScope.of(context);
    final me = store.me;
    final posts = store.postsOf(me.id);
    final top = MediaQuery.paddingOf(context).top;
    final fmt = NumberFormat.decimalPattern('es');

    return ColoredBox(
      color: NexoColors.surface,
      child: Column(
        children: [
          SizedBox(height: top),
          SizedBox(
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  me.username,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.15,
                    height: 1,
                  ),
                ),
                const Positioned(
                  right: 8,
                  child: Row(
                    children: [
                      Icon(Icons.add_box_outlined, size: 26),
                      SizedBox(width: 14),
                      Icon(Icons.menu, size: 26),
                      SizedBox(width: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                    final path = await Navigator.of(context).push<String>(
                      MaterialPageRoute(
                        builder: (_) => const GalleryPage(
                          purpose: GalleryPurpose.avatar,
                        ),
                      ),
                    );
                    if (path != null) await store.setMyAvatar(path);
                  },
                  child: Stack(
                    children: [
                      UserAvatar(user: me, size: 86),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: NexoColors.accent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: NexoColors.surface,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 22),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        me.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _Stat(
                              value: fmt.format(posts.length),
                              label: 'publicaciones',
                            ),
                          ),
                          Expanded(
                            child: _Stat(
                              value: fmt.format(me.followerCount),
                              label: 'seguidores',
                            ),
                          ),
                          Expanded(
                            child: _Stat(
                              value: fmt.format(me.followingCount),
                              label: 'seguidos',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (me.bio.isNotEmpty)
                    Text(
                      me.bio,
                      style: const TextStyle(fontSize: 14, height: 1.35),
                    ),
                  if (me.city.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      me.city,
                      style: const TextStyle(
                        fontSize: 13,
                        color: NexoColors.muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Expanded(child: _ActionChip(label: 'Editar perfil')),
                const SizedBox(width: 8),
                Expanded(child: _ActionChip(label: 'Compartir perfil')),
              ],
            ),
          ),
          const Divider(height: 1, color: NexoColors.line),
          const SizedBox(
            height: 44,
            child: Center(
              child: Icon(Icons.grid_on_outlined, size: 22),
            ),
          ),
          const Divider(height: 1, color: NexoColors.line),
          Expanded(
            child: posts.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Cuando publiques, tus fotos 1:1 aparecen acá.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: NexoColors.muted,
                          height: 1.4,
                        ),
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsets.zero,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 1,
                    ),
                    itemCount: posts.length,
                    itemBuilder: (context, i) => _PostThumb(post: posts[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: NexoColors.text),
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PostThumb extends StatelessWidget {
  const _PostThumb({required this.post});
  final NexoPost post;

  @override
  Widget build(BuildContext context) {
    final path = post.localImagePath;
    if (path != null && File(path).existsSync()) {
      return Image.file(File(path), fit: BoxFit.cover);
    }
    return const ColoredBox(color: Color(0xFFEAEAEA));
  }
}
