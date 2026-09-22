import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/post.dart';
import '../models/user.dart';
import '../theme.dart';
import 'user_avatar.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.author,
    this.onLike,
    this.compact = false,
  });

  final NexoPost post;
  final NexoUser author;
  final VoidCallback? onLike;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: NexoColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Row(
              children: [
                UserAvatar(user: author, size: 34),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        author.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '@${author.username} · ${_timeAgo(post.createdAt)}',
                        style: const TextStyle(
                          color: NexoColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AspectRatio(
            aspectRatio: 1,
            child: ColoredBox(
              color: const Color(0xFFF0F0F0),
              child: _image(),
            ),
          ),
          if (!compact) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 4, 14, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onLike,
                    icon: Icon(
                      post.likedByMe
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: post.likedByMe
                          ? NexoColors.accent
                          : NexoColors.text,
                    ),
                  ),
                  Text(
                    NumberFormat.decimalPattern('es').format(post.likes),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            if (post.caption.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${author.username}  ',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: post.caption),
                    ],
                  ),
                  style: const TextStyle(fontSize: 14, height: 1.35),
                ),
              )
            else
              const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _image() {
    final local = post.localImagePath;
    if (local != null && local.isNotEmpty && File(local).existsSync()) {
      return Image.file(File(local), fit: BoxFit.cover);
    }
    if (post.networkImageUrl != null) {
      return CachedNetworkImage(
        imageUrl: post.networkImageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => const Center(
          child: Icon(Icons.image_not_supported_outlined),
        ),
      );
    }
    return const Center(child: Icon(Icons.image_outlined));
  }

  String _timeAgo(DateTime date) {
    final d = DateTime.now().difference(date);
    if (d.inMinutes < 1) return 'ahora';
    if (d.inMinutes < 60) return 'hace ${d.inMinutes} min';
    if (d.inHours < 24) return 'hace ${d.inHours} h';
    if (d.inDays < 7) return 'hace ${d.inDays} d';
    return DateFormat('d MMM', 'es').format(date);
  }
}
