import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../data/seed.dart';
import '../models/post.dart';
import '../models/user.dart';

class AppState extends ChangeNotifier {
  AppState();

  static const _postsKey = 'nexo.posts';
  static const _meKey = 'nexo.me';

  final _uuid = const Uuid();

  late NexoUser me = seedMe;
  final Map<String, NexoUser> _users = {
    for (final u in seedPeople) u.id: u,
    seedMe.id: seedMe,
  };
  List<NexoPost> _posts = List.of(seedPosts);
  bool loaded = false;

  List<NexoPost> get feed {
    final list = List<NexoPost>.from(_posts);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  List<NexoPost> postsOf(String userId) =>
      feed.where((p) => p.authorId == userId).toList();

  NexoUser userById(String id) => _users[id] ?? seedMe;

  List<NexoUser> get publicUsers =>
      _users.values.where((u) => u.id != currentUserId).toList();

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final meRaw = prefs.getString(_meKey);
    if (meRaw != null) {
      me = NexoUser.fromJson(jsonDecode(meRaw) as Map<String, dynamic>);
      _users[me.id] = me;
    }
    final postsRaw = prefs.getString(_postsKey);
    if (postsRaw != null) {
      final decoded = (jsonDecode(postsRaw) as List).cast<Map<String, dynamic>>();
      final local = decoded.map(NexoPost.fromJson).toList();
      final seedIds = seedPosts.map((p) => p.id).toSet();
      final extras = local.where((p) => !seedIds.contains(p.id)).toList();
      _posts = [...extras, ...seedPosts];
    }
    loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_meKey, jsonEncode(me.toJson()));
    await prefs.setString(
      _postsKey,
      jsonEncode(_posts.map((p) => p.toJson()).toList()),
    );
  }

  Future<NexoPost> publish({
    required String localImagePath,
    required String caption,
  }) async {
    final post = NexoPost(
      id: _uuid.v4(),
      authorId: me.id,
      createdAt: DateTime.now(),
      caption: caption.trim(),
      localImagePath: localImagePath,
      likes: 0,
    );
    _posts.insert(0, post);
    notifyListeners();
    await _persist();
    return post;
  }

  Future<void> setMyAvatar(String path) async {
    me = me.copyWith(localAvatarPath: path);
    _users[me.id] = me;
    notifyListeners();
    await _persist();
  }

  void toggleLike(String postId) {
    _posts = _posts.map((p) {
      if (p.id != postId) return p;
      final liked = !p.likedByMe;
      return p.copyWith(
        likedByMe: liked,
        likes: p.likes + (liked ? 1 : -1),
      );
    }).toList();
    notifyListeners();
    _persist();
  }

  SearchResult search(String raw) {
    final q = raw.trim().toLowerCase();
    if (q.isEmpty) {
      return SearchResult(
        users: publicUsers,
        posts: const [],
        hashtags: _popularHashtags(),
        topics: _allTopics(),
      );
    }

    final users = _users.values.where((u) {
      return u.username.toLowerCase().contains(q) ||
          u.displayName.toLowerCase().contains(q) ||
          u.city.toLowerCase().contains(q) ||
          u.bio.toLowerCase().contains(q) ||
          u.topics.any((t) => t.toLowerCase().contains(q));
    }).toList();

    final posts = feed.where((p) {
      final author = userById(p.authorId);
      return p.caption.toLowerCase().contains(q) ||
          author.displayName.toLowerCase().contains(q) ||
          author.username.toLowerCase().contains(q);
    }).toList();

    final tags = <String>{};
    for (final p in feed) {
      for (final h in p.hashtags) {
        if (h.contains(q) || q.replaceAll('#', '') == h.replaceAll('#', '')) {
          tags.add(h);
        }
      }
    }
    if (q.startsWith('#')) {
      tags.addAll(
        feed.expand((p) => p.hashtags).where((h) => h.contains(q)),
      );
    }

    final topics = _allTopics()
        .where((t) => t.toLowerCase().contains(q.replaceAll('#', '')))
        .toList();

    return SearchResult(
      users: users,
      posts: posts,
      hashtags: tags.toList()..sort(),
      topics: topics,
    );
  }

  List<String> _popularHashtags() {
    final counts = <String, int>{};
    for (final p in feed) {
      for (final h in p.hashtags) {
        counts[h] = (counts[h] ?? 0) + 1;
      }
    }
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.map((e) => e.key).toList();
  }

  List<String> _allTopics() {
    final set = <String>{};
    for (final u in _users.values) {
      set.addAll(u.topics);
    }
    final list = set.toList()..sort();
    return list;
  }
}

class SearchResult {
  const SearchResult({
    required this.users,
    required this.posts,
    required this.hashtags,
    required this.topics,
  });

  final List<NexoUser> users;
  final List<NexoPost> posts;
  final List<String> hashtags;
  final List<String> topics;
}
