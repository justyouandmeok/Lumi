import 'package:flutter/material.dart';

import '../models/user.dart';
import '../screens/user_profile_page.dart';
import '../state/scope.dart';
import '../theme.dart';
import '../widgets/post_card.dart';
import '../widgets/user_avatar.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStateScope.of(context);
    final result = store.search(_query);
    final top = MediaQuery.paddingOf(context).top;

    return ColoredBox(
      color: NexoColors.background,
      child: Column(
        children: [
          SizedBox(height: top),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Buscar personas, temas, #hashtags o frases',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: NexoColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: NexoColors.line),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: NexoColors.line),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
              children: [
                if (result.users.isNotEmpty) ...[
                  const _SectionTitle('Personas'),
                  ...result.users.map((u) => _UserTile(user: u)),
                ],
                if (result.topics.isNotEmpty) ...[
                  const _SectionTitle('Temas'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: result.topics
                        .map(
                          (t) => ActionChip(
                            label: Text(t),
                            onPressed: () {
                              _controller.text = t;
                              setState(() => _query = t);
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (result.hashtags.isNotEmpty) ...[
                  const _SectionTitle('Hashtags'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: result.hashtags
                        .map(
                          (h) => ActionChip(
                            label: Text(h),
                            onPressed: () {
                              _controller.text = h;
                              setState(() => _query = h);
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (result.posts.isNotEmpty) ...[
                  const _SectionTitle('Frases y publicaciones'),
                  const SizedBox(height: 8),
                  ...result.posts.map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: PostCard(
                          post: p,
                          author: store.userById(p.authorId),
                          onLike: () => store.toggleLike(p.id),
                        ),
                      ),
                    ),
                  ),
                ],
                if (_query.isNotEmpty &&
                    result.users.isEmpty &&
                    result.posts.isEmpty &&
                    result.hashtags.isEmpty &&
                    result.topics.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 48),
                    child: Text(
                      'No hay resultados con esa búsqueda.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: NexoColors.muted),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user});
  final NexoUser user;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => UserProfilePage(userId: user.id),
          ),
        );
      },
      leading: UserAvatar(user: user, size: 48),
      title: Text(
        user.displayName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '@${user.username} · ${user.city}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
