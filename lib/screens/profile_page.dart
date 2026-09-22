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
      color: NexoColors.background,
      child: Column(
        children: [
          SizedBox(height: top),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
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
                    if (path != null) {
                      await store.setMyAvatar(path);
                    }
                  },
                  child: Stack(
                    children: [
                      UserAvatar(user: me, size: 86),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: NexoColors.accent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        me.displayName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '@${me.username}',
                        style: const TextStyle(color: NexoColors.muted),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        me.bio,
                        style: const TextStyle(height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                _Stat(value: fmt.format(posts.length), label: 'Publicaciones'),
                const SizedBox(width: 24),
                _Stat(value: fmt.format(me.followerCount), label: 'Seguidores'),
                const SizedBox(width: 24),
                _Stat(value: fmt.format(me.followingCount), label: 'Seguidos'),
              ],
            ),
          ),
          const Divider(height: 1, color: NexoColors.line),
          Expanded(
            child: posts.isEmpty
                ? const Center(
                    child: Text(
                      'Tus publicaciones 1:1 aparecen acá\nen cuanto las publiques.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: NexoColors.muted, height: 1.4),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(1),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 1,
                    ),
                    itemCount: posts.length,
                    itemBuilder: (context, i) {
                      return _PostThumb(post: posts[i]);
                    },
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        Text(
          label,
          style: const TextStyle(color: NexoColors.muted, fontSize: 12),
        ),
      ],
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
