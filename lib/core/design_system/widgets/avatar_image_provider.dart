import 'dart:io';

import 'package:flutter/material.dart';

ImageProvider<Object>? avatarImageProvider(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }

  final normalized = value.trim();
  final lower = normalized.toLowerCase();
  if (lower.startsWith('http://') || lower.startsWith('https://')) {
    return NetworkImage(normalized);
  }
  return FileImage(File(normalized));
}
