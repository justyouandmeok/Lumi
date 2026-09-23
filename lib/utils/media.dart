import 'dart:io';

import 'package:flutter/material.dart';

ImageProvider appImage(String url) {
  if (url.startsWith('http://') || url.startsWith('https://')) {
    return NetworkImage(url);
  }
  final path = url.startsWith('file://') ? url.substring(7) : url;
  return FileImage(File(path));
}

Widget appImageWidget(String url, {BoxFit fit = BoxFit.cover}) {
  if (url.startsWith('http://') || url.startsWith('https://')) {
    return Image.network(url, fit: fit);
  }
  final path = url.startsWith('file://') ? url.substring(7) : url;
  return Image.file(File(path), fit: fit);
}
