import 'package:instagram_clone_flutter/fake_firebase.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_flutter/screens/add_post_screen.dart';
import 'package:instagram_clone_flutter/screens/feed_screen.dart';
import 'package:instagram_clone_flutter/screens/profile_screen.dart';
import 'package:instagram_clone_flutter/screens/notifications_screen.dart';
import 'package:instagram_clone_flutter/screens/search_screen.dart';

const webScreenSize = 600;

List<Widget> get homeScreenItems => [
      const FeedScreen(),
      const SearchScreen(),
      const AddPostScreen(),
      const NotificationsScreen(),
      ProfileScreen(
        uid: FirebaseAuth.instance.currentUser!.uid,
      ),
    ];
