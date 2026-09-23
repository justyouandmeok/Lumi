class NexoComment {
  const NexoComment({
    required this.id,
    required this.authorId,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String authorId;
  final String text;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorId': authorId,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };

  factory NexoComment.fromJson(Map<String, dynamic> json) {
    return NexoComment(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      text: json['text'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class NexoPost {
  const NexoPost({
    required this.id,
    required this.authorId,
    required this.createdAt,
    required this.caption,
    this.networkImageUrl,
    this.localImagePath,
    this.likes = 0,
    this.likedByMe = false,
    this.comments = const [],
  });

  final String id;
  final String authorId;
  final DateTime createdAt;
  final String caption;
  final String? networkImageUrl;
  final String? localImagePath;
  final int likes;
  final bool likedByMe;
  final List<NexoComment> comments;

  List<String> get hashtags {
    final matches = RegExp(r'#[\wáéíóúñÁÉÍÓÚÑ]+').allMatches(caption);
    return matches.map((m) => m.group(0)!.toLowerCase()).toList();
  }

  NexoPost copyWith({
    int? likes,
    bool? likedByMe,
    List<NexoComment>? comments,
  }) {
    return NexoPost(
      id: id,
      authorId: authorId,
      createdAt: createdAt,
      caption: caption,
      networkImageUrl: networkImageUrl,
      localImagePath: localImagePath,
      likes: likes ?? this.likes,
      likedByMe: likedByMe ?? this.likedByMe,
      comments: comments ?? this.comments,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorId': authorId,
        'createdAt': createdAt.toIso8601String(),
        'caption': caption,
        'networkImageUrl': networkImageUrl,
        'localImagePath': localImagePath,
        'likes': likes,
        'likedByMe': likedByMe,
        'comments': comments.map((c) => c.toJson()).toList(),
      };

  factory NexoPost.fromJson(Map<String, dynamic> json) {
    return NexoPost(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      caption: json['caption'] as String? ?? '',
      networkImageUrl: json['networkImageUrl'] as String?,
      localImagePath: json['localImagePath'] as String?,
      likes: json['likes'] as int? ?? 0,
      likedByMe: json['likedByMe'] as bool? ?? false,
      comments: ((json['comments'] as List?) ?? const [])
          .cast<Map<String, dynamic>>()
          .map(NexoComment.fromJson)
          .toList(),
    );
  }
}
