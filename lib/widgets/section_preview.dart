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
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: theme.brightness == Brightness.dark
                      ? ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              Colors.white,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: Icon(
                            section.icon,
                            size: 20,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          section.icon,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${section.items.length} items saved',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onShowMore,
                  icon: const Icon(Icons.chevron_right_rounded),
                  tooltip: 'Show more',
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
