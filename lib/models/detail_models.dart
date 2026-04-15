import 'package:flutter/material.dart';

enum DetailSectionType { passwords, cards, addresses }

class DetailItem {
  const DetailItem({
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.details = const {},
  });

  final String title;
  final String subtitle;
  final String trailing;
  final Map<String, String> details;

  DetailItem copyWith({
    String? title,
    String? subtitle,
    String? trailing,
    Map<String, String>? details,
  }) {
    return DetailItem(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      trailing: trailing ?? this.trailing,
      details: details ?? this.details,
    );
  }
}

class DetailSection {
  const DetailSection({
    required this.type,
    required this.title,
    required this.icon,
    required this.items,
    required this.colors,
  });

  final DetailSectionType type;
  final String title;
  final IconData icon;
  final List<DetailItem> items;
  final List<Color> colors;

  DetailSection copyWith({
    DetailSectionType? type,
    String? title,
    IconData? icon,
    List<DetailItem>? items,
    List<Color>? colors,
  }) {
    return DetailSection(
      type: type ?? this.type,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      items: items ?? this.items,
      colors: colors ?? this.colors,
    );
  }
}
