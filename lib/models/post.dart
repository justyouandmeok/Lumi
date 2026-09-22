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
  });

  final String id;
  final String authorId;
  final DateTime createdAt;
  final String caption;
  final String? networkImageUrl;
  final String? localImagePath;
  final int likes;
  final bool likedByMe;

  List<String> get hashtags {
    final matches = RegExp(r'#[\wáéíóúñÁÉÍÓÚÑ]+').allMatches(caption);
    return matches.map((m) => m.group(0)!.toLowerCase()).toList();
  }

  NexoPost copyWith({int? likes, bool? likedByMe}) {
    return NexoPost(
      id: id,
      authorId: authorId,
      createdAt: createdAt,
      caption: caption,
      networkImageUrl: networkImageUrl,
      localImagePath: localImagePath,
      likes: likes ?? this.likes,
      likedByMe: likedByMe ?? this.likedByMe,
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
    );
  }
}
