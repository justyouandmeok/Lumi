import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/post.dart';
import '../state/scope.dart';
import '../theme.dart';
import '../widgets/user_avatar.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key, required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context) {
    final store = AppStateScope.of(context);
    final user = store.userById(userId);
    final posts = store.postsOf(userId);
    final mine = user.id == store.me.id;
    final following = store.isFollowing(user.id);
    final fmt = NumberFormat.decimalPattern('es');

    return Scaffold(
      backgroundColor: NexoColors.surface,
      appBar: AppBar(
        title: Text(
          user.username,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 20, 0),
            child: Row(
              children: [
                UserAvatar(user: user, size: 86),
                const SizedBox(width: 22),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _n(fmt.format(posts.length), 'publicaciones'),
                          _n(fmt.format(user.followerCount), 'seguidores'),
                          _n(fmt.format(user.followingCount), 'seguidos'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (user.bio.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(user.bio, style: const TextStyle(height: 1.35)),
              ),
            ),
          if (!mine)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: SizedBox(
                width: double.infinity,
                height: 34,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        following ? const Color(0xFFF2F2F2) : NexoColors.accent,
                    foregroundColor:
                        following ? NexoColors.text : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => store.toggleFollow(user.id),
                  child: Text(following ? 'Siguiendo' : 'Seguir'),
                ),
              ),
            )
          else
            const SizedBox(height: 12),
          const Divider(height: 1, color: NexoColors.line),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
              ),
              itemCount: posts.length,
              itemBuilder: (context, i) => _Thumb(post: posts[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _n(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.post});
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
