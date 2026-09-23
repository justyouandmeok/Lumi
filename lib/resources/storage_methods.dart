import 'dart:io';
import 'dart:typed_data';

import 'package:instagram_clone_flutter/fake_firebase.dart';
import 'package:uuid/uuid.dart';

class StorageMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> uploadImageToStorage(
      String childName, Uint8List file, bool isPost) async {
    final id = isPost ? const Uuid().v1() : (_auth.currentUser?.uid ?? 'me');
    final dir = await Directory.systemTemp.createTemp('lumi_$childName');
    final path = '${dir.path}/$id.jpg';
    await File(path).writeAsBytes(file);
    return path;
  }
}
