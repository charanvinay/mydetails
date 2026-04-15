import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/detail_models.dart';

class SectionItemTile extends StatelessWidget {
  const SectionItemTile({super.key, required this.item, this.onTap});

  final DetailItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.9),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: item.imageUrl != null
                    ? Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.network(
                          item.imageUrl!,
                          fit: BoxFit.contain,
                          errorBuilder: (ctx, _, __) => Icon(
                            Icons.broken_image_rounded,
                            size: 18,
                            color: theme.colorScheme.error,
                          ),
                        ),
                      )
                    : Center(
                        child: (item.colors != null && item.colors!.length > 1)
                            ? ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: item.colors!,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds),
                                child: FaIcon(
                                  item.icon ?? FontAwesomeIcons.fileLines,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              )
                            : FaIcon(
                                item.icon ?? FontAwesomeIcons.fileLines,
                                color: item.colors?.first ??
                                    theme.colorScheme.primary,
                                size: 22,
                              ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
