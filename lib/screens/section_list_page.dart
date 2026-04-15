import 'package:flutter/material.dart';

import '../models/detail_models.dart';
import '../widgets/gradient_icon_badge.dart';
import '../widgets/section_item_tile.dart';

class SectionListPage extends StatefulWidget {
  const SectionListPage({
    super.key,
    required this.getSection,
    required this.onItemTap,
  });

  final DetailSection Function() getSection;
  final Future<void> Function(int itemIndex) onItemTap;

  @override
  State<SectionListPage> createState() => _SectionListPageState();
}

class _SectionListPageState extends State<SectionListPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final section = widget.getSection();

    return Scaffold(
      appBar: AppBar(title: Text(section.title)),
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
                GradientIconBadge(
                  icon: section.icon,
                  colors: section.colors,
                  size: 46,
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
                      Text(
                        '${section.items.length} saved items',
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
          for (var index = 0; index < section.items.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SectionItemTile(
                item: section.items[index],
                onTap: () async {
                  await widget.onItemTap(index);
                  if (mounted) {
                    setState(() {});
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}
