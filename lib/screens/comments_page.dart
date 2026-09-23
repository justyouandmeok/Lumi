import 'package:flutter/material.dart';

import '../state/scope.dart';
import '../theme.dart';
import '../widgets/user_avatar.dart';

class CommentsPage extends StatefulWidget {
  const CommentsPage({super.key, required this.postId});
  final String postId;

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStateScope.of(context);
    final matches = store.feed.where((p) => p.id == widget.postId);
    final post = matches.isEmpty ? null : matches.first;
    if (post == null) {
      return const Scaffold(body: Center(child: Text('Publicación no encontrada')));
    }

    return Scaffold(
      backgroundColor: NexoColors.surface,
      appBar: AppBar(
        title: const Text('Comentarios', style: TextStyle(fontSize: 18)),
      ),
      body: Column(
        children: [
          Expanded(
            child: post.comments.isEmpty
                ? const Center(
                    child: Text(
                      'Todavía no hay comentarios.',
                      style: TextStyle(color: NexoColors.muted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    itemCount: post.comments.length,
                    itemBuilder: (context, i) {
                      final c = post.comments[i];
                      final user = store.userById(c.authorId);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            UserAvatar(user: user, size: 32),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${user.username}  ',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    TextSpan(text: c.text),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const Divider(height: 1, color: NexoColors.line),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
              child: Row(
                children: [
                  UserAvatar(user: store.me, size: 32),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Agregar un comentario...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await store.addComment(widget.postId, _controller.text);
                      _controller.clear();
                    },
                    child: const Text('Publicar'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
