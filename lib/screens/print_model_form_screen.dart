import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../models/print_model.dart';
import '../providers/print_model_provider.dart';
import '../providers/client_provider.dart';

class PrintModelFormScreen extends StatefulWidget {
  final PrintModel? model;
  const PrintModelFormScreen({super.key, this.model});

  @override
  State<PrintModelFormScreen> createState() => _PrintModelFormScreenState();
}

class _PrintModelFormScreenState extends State<PrintModelFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _printTimeCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _filePathCtrl;
  late TextEditingController _tagsCtrl;
  late TextEditingController _notesCtrl;
  late ModelFileType _fileType;
  String? _selectedClientId;
  String? _selectedClientName;

  bool get isEditing => widget.model != null;

  @override
  void initState() {
    super.initState();
    final m = widget.model;
    _nameCtrl = TextEditingController(text: m?.name ?? '');
    _descCtrl = TextEditingController(text: m?.description ?? '');
    _printTimeCtrl = TextEditingController(
        text: m?.printTimeHours != null
            ? m!.printTimeHours!.toStringAsFixed(1)
            : '');
    _weightCtrl = TextEditingController(
        text: m?.weightGrams != null ? m!.weightGrams!.toStringAsFixed(0) : '');
    _filePathCtrl = TextEditingController(text: m?.filePath ?? '');
    _tagsCtrl = TextEditingController(text: m?.tags ?? '');
    _notesCtrl = TextEditingController(text: m?.notes ?? '');
    _fileType = m?.fileType ?? ModelFileType.stl;
    _selectedClientId = m?.clientId;
    _selectedClientName = m?.clientName;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _printTimeCtrl.dispose();
    _weightCtrl.dispose();
    _filePathCtrl.dispose();
    _tagsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<PrintModelProvider>();

    final printTime = double.tryParse(_printTimeCtrl.text);
    final weight = double.tryParse(_weightCtrl.text);

    if (isEditing) {
      await provider.updateModel(widget.model!.copyWith(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        fileType: _fileType,
        clientId: _selectedClientId,
        clientName: _selectedClientName,
        printTimeHours: printTime,
        weightGrams: weight,
        filePath: _filePathCtrl.text.trim().isEmpty
            ? null
            : _filePathCtrl.text.trim(),
        tags: _tagsCtrl.text.trim().isEmpty ? null : _tagsCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      ));
    } else {
      await provider.addModel(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        fileType: _fileType,
        clientId: _selectedClientId,
        clientName: _selectedClientName,
        printTimeHours: printTime,
        weightGrams: weight,
        filePath: _filePathCtrl.text.trim().isEmpty
            ? null
            : _filePathCtrl.text.trim(),
        tags: _tagsCtrl.text.trim().isEmpty ? null : _tagsCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Видалити модель?'),
        content: Text('«${widget.model!.name}» буде видалено назавжди.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Скасувати')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Видалити',
                  style: TextStyle(color: Color(0xFFE74C3C)))),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<PrintModelProvider>().deleteModel(widget.model!.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final clients = context.read<ClientProvider>().all;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Редагувати модель' : 'Нова модель'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFE74C3C)),
              onPressed: _confirmDelete,
            ),
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.print_outlined, color: Color(0xFF03DAC6)),
              tooltip: 'Відмітити як надруковану',
              onPressed: () async {
                final provider = context.read<PrintModelProvider>();
                final navigator = Navigator.of(context);
                await provider.incrementPrintCount(widget.model!.id);
                if (mounted) navigator.pop();
              },
            ),
          TextButton(onPressed: _submit, child: const Text('Зберегти')),
          const Gap(8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Label('Назва *'),
            const Gap(8),
            TextFormField(
              controller: _nameCtrl,
              decoration:
                  const InputDecoration(hintText: 'Наприклад: Кронштейн v2'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Введіть назву' : null,
            ),
            const Gap(20),
            _Label('Опис'),
            const Gap(8),
            TextFormField(
              controller: _descCtrl,
              maxLines: 2,
              decoration:
                  const InputDecoration(hintText: 'Короткий опис моделі'),
            ),
            const Gap(20),
            _Label('Тип файлу'),
            const Gap(8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ModelFileType.values.map((t) {
                final selected = _fileType == t;
                final color = Theme.of(context).colorScheme.primary;
                return GestureDetector(
                  onTap: () => setState(() => _fileType = t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? color.withValues(alpha: 0.2)
                          : const Color(0xFF1A1A2E),
                      border: Border.all(
                          color: selected ? color : const Color(0xFF2A2A4A)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(t.label,
                        style: TextStyle(
                            color: selected ? color : const Color(0xFF7878A0),
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w400)),
                  ),
                );
              }).toList(),
            ),
            const Gap(20),
            _Label('Клієнт (необов\'язково)'),
            const Gap(8),
            DropdownButtonFormField<String?>(
              initialValue: _selectedClientId,
              decoration: const InputDecoration(
                  hintText: 'Прив\'язати до клієнта',
                  prefixIcon: Icon(Icons.person_outline)),
              items: [
                const DropdownMenuItem<String?>(
                    value: null, child: Text('— Без клієнта —')),
                ...clients.map((c) => DropdownMenuItem<String?>(
                    value: c.id,
                    child: Text(c.company.isNotEmpty
                        ? '${c.name} (${c.company})'
                        : c.name))),
              ],
              onChanged: (id) {
                setState(() {
                  _selectedClientId = id;
                  _selectedClientName = id == null
                      ? null
                      : clients.firstWhere((c) => c.id == id).name;
                });
              },
              dropdownColor: const Color(0xFF1A1A2E),
            ),
            const Gap(20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Label('Час друку (год)'),
                      const Gap(8),
                      TextFormField(
                        controller: _printTimeCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(suffixText: 'год'),
                      ),
                    ],
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Label('Витрата матеріалу (г)'),
                      const Gap(8),
                      TextFormField(
                        controller: _weightCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(suffixText: 'г'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(20),
            _Label('Шлях до файлу'),
            const Gap(8),
            TextFormField(
              controller: _filePathCtrl,
              decoration: const InputDecoration(
                  hintText: 'C:\\models\\...',
                  prefixIcon: Icon(Icons.folder_outlined)),
            ),
            const Gap(20),
            _Label('Теги (через кому)'),
            const Gap(8),
            TextFormField(
              controller: _tagsCtrl,
              decoration:
                  const InputDecoration(hintText: 'механіка, прототип, клієнт'),
            ),
            const Gap(20),
            _Label('Примітки'),
            const Gap(8),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration:
                  const InputDecoration(hintText: 'Додаткова інформація…'),
            ),
            const Gap(80),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF7878A0),
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}
