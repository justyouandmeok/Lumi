import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
import 'app_icons.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.user, this.size = 36});

  final NexoUser user;
  final double size;

  @override
  Widget build(BuildContext context) {
    final path = user.localAvatarPath;
    Widget child;
    if (path != null && path.isNotEmpty && File(path).existsSync()) {
      child = Image.file(File(path), fit: BoxFit.cover);
    } else if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
      child = CachedNetworkImage(
        imageUrl: user.avatarUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => _fallback(),
        errorWidget: (context, url, error) => _fallback(),
      );
    } else {
      child = _fallback();
    }

    return ClipOval(
      child: SizedBox(width: size, height: size, child: child),
    );
  }

  Widget _fallback() {
    return Image(
      image: AppIcons.profile,
      fit: BoxFit.cover,
      width: size,
      height: size,
    );
  }
}
