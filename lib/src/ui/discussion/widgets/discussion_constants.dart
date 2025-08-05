import 'package:flutter/material.dart';

class DiscussionConstants {
  static const double subtitleFontSize = 12;
  static const double iconSize = 16;
  static const double spacing = 4;
  
  static final Color avatarBackgroundColor = Colors.blue[100]!;
  static final Color avatarTextColor = Colors.blue[800]!;
  static const Color subtitleColor = Colors.grey;
  static final Color trailingIconColor = Colors.grey[400]!;
  
  static const TextStyle subtitleTextStyle = TextStyle(
    color: subtitleColor,
    fontSize: subtitleFontSize,
  );
  
  static const TextStyle avatarTextStyle = TextStyle(
    fontWeight: FontWeight.bold,
  );
}
