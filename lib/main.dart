import 'package:instagram_clone_flutter/fake_firebase.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_flutter/providers/user_provider.dart';
import 'package:instagram_clone_flutter/responsive/mobile_screen_layout.dart';
import 'package:instagram_clone_flutter/responsive/responsive_layout.dart';
import 'package:instagram_clone_flutter/responsive/web_screen_layout.dart';
import 'package:instagram_clone_flutter/screens/login_screen.dart';
import 'package:instagram_clone_flutter/utils/colors.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseFirestore.instance.load();
  await seedDemoIfNeeded();
  await FirebaseAuth.instance.restore();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider(),),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Instagram Clone',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: mobileBackgroundColor,
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              // Checking if the snapshot has any data or not
              if (snapshot.hasData) {
                // if snapshot has data which means user is logged in then we check the width of screen and accordingly display the screen layout
                return const ResponsiveLayout(
                  mobileScreenLayout: MobileScreenLayout(),
                  webScreenLayout: WebScreenLayout(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('${snapshot.error}'),
                );
              }
            }

            // means connection to future hasnt been made yet
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return const LoginScreen();
          },
        ),
      ),
    );
  }
}

Future<void> seedDemoIfNeeded() async {
  final fs = FirebaseFirestore.instance;
  if ((fs.cols['posts'] ?? {}).isNotEmpty) return;
  await fs.collection('users').doc('2').set({
    'username': 'rivaan',
    'uid': '2',
    'email': 'rivaan@gmail.com',
    'photoUrl': 'https://i.pravatar.cc/300?img=12',
    'bio': 'Hey there I am Rivaan Ranawat',
    'followers': [],
    'following': [],
  });
  await fs.collection('users').doc('3').set({
    'username': 'raphael',
    'uid': '3',
    'email': 'raphael@gmail.com',
    'photoUrl': 'https://i.pravatar.cc/300?img=33',
    'bio': 'Photography',
    'followers': [],
    'following': [],
  });
  await fs.collection('posts').doc('p1').set({
    'description': 'This is a test from Rivaan!',
    'uid': '2',
    'username': 'rivaan',
    'likes': [],
    'postId': 'p1',
    'datePublished': DateTime.now().subtract(const Duration(hours: 2)),
    'postUrl': 'https://picsum.photos/id/1015/800/800',
    'profImage': 'https://i.pravatar.cc/300?img=12',
  });
  await fs.collection('posts').doc('p2').set({
    'description': 'Sunset in the city',
    'uid': '3',
    'username': 'raphael',
    'likes': [],
    'postId': 'p2',
    'datePublished': DateTime.now().subtract(const Duration(hours: 5)),
    'postUrl': 'https://picsum.photos/id/1016/800/800',
    'profImage': 'https://i.pravatar.cc/300?img=33',
  });
}
