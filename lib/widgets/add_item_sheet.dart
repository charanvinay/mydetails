import 'package:flutter/material.dart';

import '../models/detail_models.dart';
import 'gradient_icon_badge.dart';

class AddItemSheet extends StatelessWidget {
  const AddItemSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget buildChoice({
      required DetailSectionType type,
      required IconData icon,
      required String title,
      required String subtitle,
    }) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: GradientIconBadge(
          icon: icon,
          colors: switch (type) {
            DetailSectionType.passwords => const [
              Color(0xFF2563EB),
              Color(0xFF7C3AED),
            ],
            DetailSectionType.cards => const [
              Color(0xFFEA580C),
              Color(0xFFEF4444),
            ],
            DetailSectionType.addresses => const [
              Color(0xFF059669),
              Color(0xFF14B8A6),
            ],
          },
          size: 42,
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: () => Navigator.of(context).pop(type),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What do you want to add?',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a category to add an item manually.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              buildChoice(
                type: DetailSectionType.passwords,
                icon: Icons.password_rounded,
                title: 'Password',
                subtitle: 'Add an app, website, or account login',
              ),
              buildChoice(
                type: DetailSectionType.cards,
                icon: Icons.credit_card_rounded,
                title: 'Card',
                subtitle: 'Add a saved payment card manually',
              ),
              buildChoice(
                type: DetailSectionType.addresses,
                icon: Icons.home_rounded,
                title: 'Address',
                subtitle: 'Add a saved address for home, work, or more',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
