import 'package:flutter/material.dart';

import '../widgets/gradient_icon_badge.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget tile({
      required IconData icon,
      required String title,
      required String subtitle,
    }) {
      return ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        tileColor: theme.cardTheme.color,
        leading: GradientIconBadge(
          icon: icon,
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          size: 42,
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        titleSpacing: 8,
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.9),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: theme.colorScheme.primary,
                  child: const Text(
                    'C',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chanay',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Secure vault owner',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.transparent,
            child: tile(
              icon: Icons.person_outline_rounded,
              title: 'User details',
              subtitle: 'View your basic profile information',
            ),
          ),
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            child: tile(
              icon: Icons.settings_outlined,
              title: 'Settings',
              subtitle: 'Security, preferences, and app options',
            ),
          ),
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            child: tile(
              icon: Icons.upload_file_outlined,
              title: 'Export database',
              subtitle: 'Create a backup of your saved data',
            ),
          ),
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            child: tile(
              icon: Icons.download_outlined,
              title: 'Import database',
              subtitle: 'Restore data from an existing backup',
            ),
          ),
        ],
      ),
    );
  }
}
