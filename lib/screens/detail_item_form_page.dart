import 'package:flutter/material.dart';

import '../models/detail_models.dart';
import '../widgets/gradient_icon_badge.dart';
import '../widgets/app_selector_sheet.dart';

enum DetailEditorAction { save, delete }

class DetailEditorResult {
  const DetailEditorResult({required this.action, this.item});

  final DetailEditorAction action;
  final DetailItem? item;
}

class DetailItemFormPage extends StatefulWidget {
  const DetailItemFormPage({
    super.key,
    required this.section,
    this.initialItem,
  });

  final DetailSection section;
  final DetailItem? initialItem;

  bool get isEditing => initialItem != null;

  @override
  State<DetailItemFormPage> createState() => _DetailItemFormPageState();
}

class _DetailItemFormPageState extends State<DetailItemFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final field in _fields)
        field.key: TextEditingController(
          text:
              widget.initialItem?.details[field.key] ?? _legacyValue(field.key),
        ),
    };
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  List<_FormFieldSpec> get _fields {
    switch (widget.section.type) {
      case DetailSectionType.cards:
        return const [
          _FormFieldSpec(key: 'card_number', label: 'Card number'),
          _FormFieldSpec(key: 'card_name', label: 'Name on card'),
          _FormFieldSpec(key: 'expiry_year', label: 'Expiry year'),
          _FormFieldSpec(key: 'cvv', label: 'CVV'),
        ];
      case DetailSectionType.passwords:
        return const [
          _FormFieldSpec(key: 'app_name', label: 'App or website'),
          _FormFieldSpec(key: 'username', label: 'Username or email'),
          _FormFieldSpec(key: 'password', label: 'Password'),
          _FormFieldSpec(key: 'identifier', label: 'Identifier'),
        ];
      case DetailSectionType.addresses:
        return const [
          _FormFieldSpec(key: 'label', label: 'Address label'),
          _FormFieldSpec(key: 'address_line', label: 'Full address'),
          _FormFieldSpec(key: 'city', label: 'City'),
          _FormFieldSpec(key: 'postal_code', label: 'Postal code'),
        ];
    }
  }

  String _legacyValue(String key) {
    final item = widget.initialItem;
    if (item == null) {
      return '';
    }

    switch (widget.section.type) {
      case DetailSectionType.cards:
        if (key == 'card_number') return item.subtitle;
        if (key == 'card_name') return item.title;
        if (key == 'expiry_year') return item.trailing;
        return '';
      case DetailSectionType.passwords:
        if (key == 'app_name') return item.title;
        if (key == 'username') return item.subtitle;
        if (key == 'password') return item.trailing;
        return '';
      case DetailSectionType.addresses:
        if (key == 'label') return item.title;
        if (key == 'address_line') return item.subtitle;
        if (key == 'city') return item.trailing;
        return '';
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final values = {
      for (final field in _fields)
        field.key: _controllers[field.key]!.text.trim(),
    };

    Navigator.of(context).pop(
      DetailEditorResult(
        action: DetailEditorAction.save,
        item: _buildItem(values),
      ),
    );
  }

  DetailItem _buildItem(Map<String, String> values) {
    switch (widget.section.type) {
      case DetailSectionType.cards:
        return DetailItem(
          title: values['card_name']!,
          subtitle: values['card_number']!,
          trailing: 'Exp ${values['expiry_year']!}',
          details: values,
        );
      case DetailSectionType.passwords:
        // We do not display the identifier on the detail preview directly, but we keep it in details map.
        return DetailItem(
          title: values['app_name']!,
          subtitle: values['username']!,
          trailing: values['password']!,
          details: values,
        );
      case DetailSectionType.addresses:
        return DetailItem(
          title: values['label']!,
          subtitle: values['address_line']!,
          trailing: values['city']!,
          details: values,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 64,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.close_rounded),
            ),
          ),
          titleSpacing: 8,
          title: Text(
            widget.isEditing
                ? 'Edit ${widget.section.title}'
                : 'Add ${widget.section.title}',
          ),
          actions: [
            if (widget.isEditing)
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop(
                    const DetailEditorResult(action: DetailEditorAction.delete),
                  );
                },
                icon: const Icon(Icons.delete_outline_rounded),
                tooltip: 'Delete',
              ),
            const SizedBox(width: 16),
          ],
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    children: [
                      const SizedBox(height: 10),
                      for (final field in _fields) ...[
                        if (field.key == 'app_name')
                          TextFormField(
                            controller: _controllers[field.key],
                            readOnly: true,
                            onTap: () async {
                              final AppOption? selected =
                                  await showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (_) => const AppSelectorSheet(),
                                  );
                              if (selected != null) {
                                setState(() {
                                  _controllers['app_name']?.text =
                                      selected.name;
                                  _controllers['identifier']?.text =
                                      selected.identifier;
                                });
                              }
                            },
                            decoration: InputDecoration(
                              labelText: field.label,
                              suffixIcon: const Icon(
                                Icons.arrow_drop_down_rounded,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          )
                        else
                          TextFormField(
                            controller: _controllers[field.key],
                            obscureText:
                                field.key == 'password' || field.key == 'cvv',
                            keyboardType: _keyboardType(field.key),
                            decoration: InputDecoration(labelText: field.label),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        const SizedBox(height: 14),
                      ],
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _save,
                            child: Text(widget.isEditing ? 'Update' : 'Save'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextInputType _keyboardType(String key) {
    switch (key) {
      case 'card_number':
      case 'cvv':
      case 'postal_code':
      case 'expiry_year':
        return TextInputType.number;
      case 'identifier':
        return TextInputType.url;
      default:
        return TextInputType.text;
    }
  }

  Widget? _getIconForCurrentInput() {
    final text = _controllers['app_name']?.text.toLowerCase() ?? '';
    final identifier = _controllers['identifier']?.text.toLowerCase() ?? '';
    if (text.isEmpty && identifier.isEmpty)
      return const Icon(Icons.web_rounded);

    final matched = commonApps.cast<AppOption?>().firstWhere(
      (app) =>
          app!.name.toLowerCase() == text ||
          (identifier.isNotEmpty && app.identifier.contains(identifier)),
      orElse: () => null,
    );

    final targetId = matched?.identifier ?? identifier;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      width: 28,
      height: 20,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: targetId.isNotEmpty
          ? Image.network(
              'https://www.google.com/s2/favicons?sz=128&domain=$targetId',
              webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.web_rounded),
            )
          : const Icon(Icons.web_rounded),
    );
  }
}

class _FormIntro extends StatelessWidget {
  const _FormIntro({required this.section});

  final DetailSection section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.9)),
      ),
      child: Row(
        children: [
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
                const SizedBox(height: 6),
                Text(
                  'Fill in the most relevant details for this ${section.title.toLowerCase()} item.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          GradientIconBadge(
            icon: section.icon,
            colors: section.colors,
            size: 52,
          ),
        ],
      ),
    );
  }
}

class _FormFieldSpec {
  const _FormFieldSpec({required this.key, required this.label});

  final String key;
  final String label;
}
