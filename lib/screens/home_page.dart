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
  String _searchQuery = '';

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

  List<DetailSection> get _filteredSections {
    if (_searchQuery.isEmpty) return _sections;

    final query = _searchQuery.toLowerCase();
    return _sections.map((section) {
      final items = section.items.where((item) {
        return item.title.toLowerCase().contains(query) ||
               item.subtitle.toLowerCase().contains(query) ||
               item.trailing.toLowerCase().contains(query);
      }).toList();
      return section.copyWith(items: items);
    }).where((section) => section.items.isNotEmpty).toList();
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
          sections: _filteredSections,
          onSearchChanged: (value) => setState(() => _searchQuery = value),
          onShowMore: _openSectionList,
          onItemTap: (type, itemIndex) =>
              _openEditor(type: type, itemIndex: itemIndex),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _openAddChooser,
          child: const Icon(Icons.add_rounded),
        ),
      ),
    );
  }
}

class _HomeDashboard extends StatelessWidget {
  const _HomeDashboard({
    required this.sections,
    required this.onSearchChanged,
    required this.onShowMore,
    required this.onItemTap,
  });

  final List<DetailSection> sections;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<DetailSection> onShowMore;
  final void Function(DetailSectionType type, int itemIndex) onItemTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const SizedBox(height: 16),
        SearchBar(
          hintText: 'Search in all sections...',
          leading: const Icon(Icons.search_rounded),
          onChanged: onSearchChanged,
          elevation: WidgetStateProperty.all(0),
          backgroundColor: WidgetStateProperty.all(
            theme.colorScheme.surfaceContainerHigh,
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 24),
        for (final section in sections) ...[
          SectionPreview(
            section: section,
            onShowMore: () => onShowMore(section),
            onItemTap: (itemIndex) => onItemTap(section.type, itemIndex),
          ),
          const SizedBox(height: 16),
        ],
        const SizedBox(height: 100), // FAB space
      ],
    );
  }
}
