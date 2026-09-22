import '../models/post.dart';
import '../models/user.dart';

const currentUserId = 'me';

final NexoUser seedMe = NexoUser(
  id: currentUserId,
  username: 'vos',
  displayName: 'Vos',
  bio: 'Mi perfil en Nexo.',
  city: 'Buenos Aires, Argentina',
  followerCount: 0,
  followingCount: 12,
  topics: const ['fotografia', 'ciudad'],
);

final List<NexoUser> seedPeople = [
  NexoUser(
    id: 'u_lucia',
    username: 'lucia.morel',
    displayName: 'Lucía Morel',
    bio: 'Arquitecta. Camino la ciudad con la cámara al hombro.',
    city: 'Palermo, Buenos Aires',
    avatarUrl: 'https://randomuser.me/api/portraits/women/65.jpg',
    followerCount: 18420,
    followingCount: 312,
    topics: const ['arquitectura', 'buenosaires', 'luz'],
  ),
  NexoUser(
    id: 'u_tomas',
    username: 'tomas.vega',
    displayName: 'Tomás Vega',
    bio: 'Café de especialidad y barrios de CABA.',
    city: 'San Telmo, Buenos Aires',
    avatarUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
    followerCount: 9034,
    followingCount: 201,
    topics: const ['cafe', 'barrios', 'fotografia'],
  ),
  NexoUser(
    id: 'u_sofia',
    username: 'sofia.rial',
    displayName: 'Sofía Rial',
    bio: 'Diseño gráfico y plantas que sobreviven al invierno.',
    city: 'Rosario, Santa Fe',
    avatarUrl: 'https://randomuser.me/api/portraits/women/21.jpg',
    followerCount: 22110,
    followingCount: 440,
    topics: const ['diseno', 'plantas', 'color'],
  ),
  NexoUser(
    id: 'u_mateo',
    username: 'mateo.aguirre',
    displayName: 'Mateo Aguirre',
    bio: 'Cocino lo que encuentro en el mercado del barrio.',
    city: 'Córdoba Capital',
    avatarUrl: 'https://randomuser.me/api/portraits/men/75.jpg',
    followerCount: 15402,
    followingCount: 188,
    topics: const ['cocina', 'mercado', 'comida'],
  ),
  NexoUser(
    id: 'u_valentina',
    username: 'valen.pardo',
    displayName: 'Valentina Pardo',
    bio: 'Ceramista. El barro enseña a esperar.',
    city: 'Tigre, Buenos Aires',
    avatarUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
    followerCount: 7601,
    followingCount: 97,
    topics: const ['ceramica', 'oficio', 'manos'],
  ),
  NexoUser(
    id: 'u_leo',
    username: 'leo.benitez',
    displayName: 'Leo Benítez',
    bio: 'Música en vivo y recortes de diario.',
    city: 'La Plata',
    avatarUrl: 'https://randomuser.me/api/portraits/men/12.jpg',
    followerCount: 5104,
    followingCount: 260,
    topics: const ['musica', 'ciudad', 'noche'],
  ),
];

final List<NexoPost> seedPosts = [
  NexoPost(
    id: 'p1',
    authorId: 'u_lucia',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    caption:
        'La recova de Constitución a las 7:40. #buenosaires #arquitectura #luz',
    networkImageUrl:
        'https://images.unsplash.com/photo-1544473244-f6895e69ad8b?auto=format&fit=crop&w=1080&h=1080&q=80',
    likes: 428,
  ),
  NexoPost(
    id: 'p2',
    authorId: 'u_tomas',
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    caption: 'Doble espresso en Defensa y Chile. #cafe #santelmo #barrios',
    networkImageUrl:
        'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=1080&h=1080&q=80',
    likes: 891,
  ),
  NexoPost(
    id: 'p3',
    authorId: 'u_sofia',
    createdAt: DateTime.now().subtract(const Duration(hours: 9)),
    caption: 'Monstera que ya no entra en el living. #plantas #color #diseno',
    networkImageUrl:
        'https://images.unsplash.com/photo-1463320726281-696a485928c7?auto=format&fit=crop&w=1080&h=1080&q=80',
    likes: 1204,
  ),
  NexoPost(
    id: 'p4',
    authorId: 'u_mateo',
    createdAt: DateTime.now().subtract(const Duration(hours: 14)),
    caption:
        'Tomates del Mercado Norte, todavía calientes de sol. #comida #mercado #cocina',
    networkImageUrl:
        'https://images.unsplash.com/photo-1546470427-227c7369a59c?auto=format&fit=crop&w=1080&h=1080&q=80',
    likes: 673,
  ),
  NexoPost(
    id: 'p5',
    authorId: 'u_valentina',
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    caption: 'Cuenco que salió del horno anoche. #ceramica #oficio #manos',
    networkImageUrl:
        'https://images.unsplash.com/photo-1565193566173-7a0ee3dbe261?auto=format&fit=crop&w=1080&h=1080&q=80',
    likes: 512,
  ),
  NexoPost(
    id: 'p6',
    authorId: 'u_leo',
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
    caption: 'Ensayo en el garage de 8 y 50. #musica #laplata #noche',
    networkImageUrl:
        'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=1080&h=1080&q=80',
    likes: 298,
  ),
  NexoPost(
    id: 'p7',
    authorId: 'u_lucia',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    caption: 'El Río de la Plata cuando el viento para. #rio #paisaje #silencio',
    networkImageUrl:
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1080&h=1080&q=80',
    likes: 1560,
  ),
  NexoPost(
    id: 'p8',
    authorId: 'u_tomas',
    createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 6)),
    caption: 'Vereda de adoquines después de la lluvia. #ciudad #detalle',
    networkImageUrl:
        'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?auto=format&fit=crop&w=1080&h=1080&q=80',
    likes: 744,
  ),
];
