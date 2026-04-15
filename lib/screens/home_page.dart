import 'package:flutter/material.dart';

import '../models/detail_models.dart';
import '../screens/detail_item_form_page.dart';
import '../screens/profile_page.dart';
import '../screens/section_list_page.dart';
import '../widgets/add_item_sheet.dart';
import '../widgets/section_preview.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.sections});

  final List<DetailSection> sections;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<DetailSection> _sections;

  @override
  void initState() {
    super.initState();
    _sections = widget.sections
        .map(
          (section) => section.copyWith(
            items: List<DetailItem>.from(section.items),
            colors: List<Color>.from(section.colors),
          ),
        )
        .toList();
  }

  Future<void> _openAddChooser() async {
    final type = await showModalBottomSheet<DetailSectionType>(
      context: context,
      showDragHandle: true,
      builder: (_) => const AddItemSheet(),
    );

    if (type != null && mounted) {
      await _openEditor(type: type);
    }
  }

  Future<void> _openEditor({
    required DetailSectionType type,
    int? itemIndex,
  }) async {
    final sectionIndex = _sections.indexWhere(
      (section) => section.type == type,
    );
    if (sectionIndex == -1) {
      return;
    }

    final section = _sections[sectionIndex];
    final initialItem = itemIndex == null ? null : section.items[itemIndex];

    final result = await Navigator.of(context).push<DetailEditorResult>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) =>
            DetailItemFormPage(section: section, initialItem: initialItem),
      ),
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      final items = List<DetailItem>.from(section.items);

      switch (result.action) {
        case DetailEditorAction.delete:
          if (itemIndex != null) {
            items.removeAt(itemIndex);
          }
          break;
        case DetailEditorAction.save:
          if (result.item == null) {
            return;
          }
          if (itemIndex == null) {
            items.insert(0, result.item!);
          } else {
            items[itemIndex] = result.item!;
          }
          break;
      }

      _sections[sectionIndex] = section.copyWith(items: items);
    });
  }

  void _openSectionList(DetailSection section) {
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => SectionListPage(
              getSection: () => _sections.firstWhere(
                (current) => current.type == section.type,
              ),
              onItemTap: (itemIndex) async {
                await _openEditor(type: section.type, itemIndex: itemIndex);
              },
            ),
          ),
        )
        .then((_) => setState(() {}));
  }

  void _openProfile() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const ProfilePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Details'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: _openProfile,
              tooltip: 'Profile',
              icon: const CircleAvatar(
                radius: 16,
                child: Icon(Icons.person_rounded, size: 18),
              ),
            ),
          ),
        ],
      ),
      body: _HomeDashboard(
        sections: _sections,
        onShowMore: _openSectionList,
        onItemTap: (type, itemIndex) =>
            _openEditor(type: type, itemIndex: itemIndex),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddChooser,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _HomeDashboard extends StatelessWidget {
  const _HomeDashboard({
    required this.sections,
    required this.onShowMore,
    required this.onItemTap,
  });

  final List<DetailSection> sections;
  final ValueChanged<DetailSection> onShowMore;
  final void Function(DetailSectionType type, int itemIndex) onItemTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.9),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Secure vault',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Everything important in one place',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap any item to edit it, use show more to view all entries, or press the plus button to add something manually.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        for (final section in sections) ...[
          SectionPreview(
            section: section,
            onShowMore: () => onShowMore(section),
            onItemTap: (itemIndex) => onItemTap(section.type, itemIndex),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
