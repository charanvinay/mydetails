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
        contentPadding: const EdgeInsets.symmetric(vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
          child: theme.brightness == Brightness.dark
              ? ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [theme.colorScheme.primary, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Icon(
                    icon,
                    size: 20,
                    color: Colors.white,
                  ),
                )
              : Icon(
                  icon,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
        ),
        minLeadingWidth: 0,
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall,
        ),
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
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose a category to add an item manually.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              buildChoice(
                type: DetailSectionType.passwords,
                icon: Icons.key_rounded,
                title: 'Password',
                subtitle: 'Add an app, website, or account login',
              ),
              buildChoice(
                type: DetailSectionType.cards,
                icon: Icons.wallet_rounded,
                title: 'Card',
                subtitle: 'Add a saved payment card manually',
              ),
              buildChoice(
                type: DetailSectionType.addresses,
                icon: Icons.location_on_rounded,
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
