import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/scope.dart';
import '../theme.dart';
import '../widgets/post_card.dart';
import 'gallery_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStateScope.of(context);
    final posts = store.feed;
    final top = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: ColoredBox(
        color: NexoColors.background,
        child: Column(
          children: [
            SizedBox(height: top),
            SizedBox(
              height: 48,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    const Text(
                      'Lumi',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Crear publicación',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const GalleryPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add, size: 28),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: NexoColors.line),
            Expanded(
              child: posts.isEmpty
                  ? const Center(
                      child: Text('Todavía no hay publicaciones.'),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: posts.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final post = posts[i];
                        return PostCard(
                          post: post,
                          author: store.userById(post.authorId),
                          onLike: () => store.toggleLike(post.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
