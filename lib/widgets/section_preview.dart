import 'package:flutter/material.dart';

import '../models/detail_models.dart';
import 'gradient_icon_badge.dart';
import 'section_item_tile.dart';

class SectionPreview extends StatelessWidget {
  const SectionPreview({
    super.key,
    required this.section,
    required this.onShowMore,
    required this.onItemTap,
  });

  final DetailSection section;
  final VoidCallback onShowMore;
  final ValueChanged<int> onItemTap;

  @override
  Widget build(BuildContext context) {
    final previewItems = section.items.take(2).toList();
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                GradientIconBadge(
                  icon: section.icon,
                  colors: section.colors,
                  size: 50,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${section.items.length} items saved',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onShowMore,
                  child: const Text('Show more'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              height: 1,
              color: theme.dividerColor.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 2),
            for (var index = 0; index < previewItems.length; index++)
              SectionItemTile(
                item: previewItems[index],
                onTap: () => onItemTap(index),
              ),
          ],
        ),
      ),
    );
  }
}
