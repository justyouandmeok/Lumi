import 'dart:convert';

import 'package:flutter/material.dart';

import '../icons_data.dart';

class AppIcons {
  static final home = MemoryImage(base64Decode(homePngB64));
  static final explore = MemoryImage(base64Decode(exploreJpgB64));
  static final profile = MemoryImage(base64Decode(profileJpgB64));
}
