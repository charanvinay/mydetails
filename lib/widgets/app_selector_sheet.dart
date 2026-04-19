import 'package:flutter/material.dart';

class AppOption {
  final String identifier;
  final String name;

  const AppOption({required this.identifier, required this.name});

  String get logoUrl =>
      'https://www.google.com/s2/favicons?sz=128&domain=$identifier';
}

final commonApps = <AppOption>[
  const AppOption(identifier: 'gmail.com', name: 'Gmail'),
  const AppOption(identifier: 'apple.com', name: 'Apple'),
  const AppOption(identifier: 'microsoft.com', name: 'Microsoft'),
  const AppOption(identifier: 'netflix.com', name: 'Netflix'),
  const AppOption(identifier: 'spotify.com', name: 'Spotify'),
  const AppOption(identifier: 'instagram.com', name: 'Instagram'),
  const AppOption(identifier: 'facebook.com', name: 'Facebook'),
  const AppOption(identifier: 'x.com', name: 'X / Twitter'),
  const AppOption(identifier: 'linkedin.com', name: 'LinkedIn'),
  const AppOption(identifier: 'github.com', name: 'GitHub'),
];

class AppSelectorSheet extends StatefulWidget {
  const AppSelectorSheet({super.key});

  @override
  State<AppSelectorSheet> createState() => _AppSelectorSheetState();
}

class _AppSelectorSheetState extends State<AppSelectorSheet> {
  final _searchController = TextEditingController();
  List<AppOption> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = commonApps;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filtered = commonApps;
      } else {
        _filtered = commonApps
            .where((a) => a.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Select an app or website",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search app or website...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                  ),
                ),
              ),
              if (query.isNotEmpty &&
                  !commonApps.any(
                    (a) => a.name.toLowerCase() == query.toLowerCase(),
                  ))
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Icon(Icons.web_rounded),
                  ),
                  title: Text('Use "$query"'),
                  subtitle: const Text('Custom website or app'),
                  onTap: () {
                    final id = query.contains('.')
                        ? query.replaceAll(' ', '')
                        : '$query.com'.replaceAll(' ', '');
                    Navigator.of(
                      context,
                    ).pop(AppOption(identifier: id, name: query));
                  },
                ),
              if (_filtered.isEmpty && query.isNotEmpty) const Divider(),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _filtered.length,
                  itemBuilder: (context, index) {
                    final app = _filtered[index];
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).dividerColor.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Image.network(
                          app.logoUrl,
                          webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.web_rounded, color: Colors.grey),
                        ),
                      ),
                      title: Text(app.name),
                      subtitle: Text(app.identifier),
                      onTap: () => Navigator.of(context).pop(app),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
