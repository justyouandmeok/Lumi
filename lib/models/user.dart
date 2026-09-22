class NexoUser {
  const NexoUser({
    required this.id,
    required this.username,
    required this.displayName,
    required this.bio,
    required this.city,
    this.avatarUrl,
    this.localAvatarPath,
    this.topics = const [],
    this.followerCount = 0,
    this.followingCount = 0,
  });

  final String id;
  final String username;
  final String displayName;
  final String bio;
  final String city;
  final String? avatarUrl;
  final String? localAvatarPath;
  final List<String> topics;
  final int followerCount;
  final int followingCount;

  bool get hasAvatar =>
      (localAvatarPath != null && localAvatarPath!.isNotEmpty) ||
      (avatarUrl != null && avatarUrl!.isNotEmpty);

  NexoUser copyWith({
    String? displayName,
    String? bio,
    String? localAvatarPath,
    String? avatarUrl,
    int? followerCount,
    int? followingCount,
  }) {
    return NexoUser(
      id: id,
      username: username,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      city: city,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      localAvatarPath: localAvatarPath ?? this.localAvatarPath,
      topics: topics,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'displayName': displayName,
        'bio': bio,
        'city': city,
        'avatarUrl': avatarUrl,
        'localAvatarPath': localAvatarPath,
        'topics': topics,
        'followerCount': followerCount,
        'followingCount': followingCount,
      };

  factory NexoUser.fromJson(Map<String, dynamic> json) {
    return NexoUser(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String,
      bio: json['bio'] as String? ?? '',
      city: json['city'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      localAvatarPath: json['localAvatarPath'] as String?,
      topics: (json['topics'] as List?)?.cast<String>() ?? const [],
      followerCount: json['followerCount'] as int? ?? 0,
      followingCount: json['followingCount'] as int? ?? 0,
    );
  }
}
