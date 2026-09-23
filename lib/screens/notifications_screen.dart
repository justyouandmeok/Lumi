import 'package:flutter/material.dart';
import 'package:instagram_clone_flutter/utils/colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text('Notifications'),
        centerTitle: false,
      ),
      body: const Center(
        child: Text(
          'No notifications yet',
          style: TextStyle(color: secondaryColor),
        ),
      ),
    );
  }
}
