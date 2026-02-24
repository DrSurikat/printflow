import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../models/material_item.dart';
import '../providers/material_provider.dart';

class MaterialFormScreen extends StatefulWidget {
  final MaterialItem? material;
  const MaterialFormScreen({super.key, this.material});

  @override
  State<MaterialFormScreen> createState() => _MaterialFormScreenState();
}

class _MaterialFormScreenState extends State<MaterialFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _brandCtrl;
  late TextEditingController _colorCtrl;
  late TextEditingController _stockCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _minStockCtrl;
  late TextEditingController _notesCtrl;
  late MaterialCategory _category;

  bool get isEditing => widget.material != null;

  @override
  void initState() {
    super.initState();
    final m = widget.material;
    _nameCtrl = TextEditingController(text: m?.name ?? '');
    _brandCtrl = TextEditingController(text: m?.brand ?? '');
    _colorCtrl = TextEditingController(text: m?.color ?? '');
    _stockCtrl = TextEditingController(
        text: m != null ? m.stockGrams.toStringAsFixed(0) : '');
    _priceCtrl = TextEditingController(
        text: m != null ? m.pricePerKg.toStringAsFixed(0) : '');
    _minStockCtrl = TextEditingController(
        text: m?.minStockGrams != null
            ? m!.minStockGrams!.toStringAsFixed(0)
            : '');
    _notesCtrl = TextEditingController(text: m?.notes ?? '');
    _category = m?.category ?? MaterialCategory.filament;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _colorCtrl.dispose();
    _stockCtrl.dispose();
    _priceCtrl.dispose();
    _minStockCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<MaterialProvider>();

    final stock = double.tryParse(_stockCtrl.text) ?? 0;
    final price = double.tryParse(_priceCtrl.text) ?? 0;
    final minStock = double.tryParse(_minStockCtrl.text);

    if (isEditing) {
      await provider.updateMaterial(widget.material!.copyWith(
        name: _nameCtrl.text.trim(),
        category: _category,
        brand: _brandCtrl.text.trim(),
        color: _colorCtrl.text.trim(),
        stockGrams: stock,
        pricePerKg: price,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        minStockGrams: minStock,
      ));
    } else {
      await provider.addMaterial(
        name: _nameCtrl.text.trim(),
        category: _category,
        brand: _brandCtrl.text.trim(),
        color: _colorCtrl.text.trim(),
        stockGrams: stock,
        pricePerKg: price,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        minStockGrams: minStock,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Видалити матеріал?'),
        content: Text('«${widget.material!.name}» буде видалено назавжди.'),
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
      context.read<MaterialProvider>().deleteMaterial(widget.material!.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Редагувати матеріал' : 'Новий матеріал'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFE74C3C)),
              onPressed: _confirmDelete,
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
                  const InputDecoration(hintText: 'Наприклад: PLA Black'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Введіть назву' : null,
            ),
            const Gap(20),
            _Label('Категорія'),
            const Gap(8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MaterialCategory.values.map((cat) {
                final selected = _category == cat;
                final color = Color(cat.colorValue);
                return GestureDetector(
                  onTap: () => setState(() => _category = cat),
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
                    child: Text(cat.label,
                        style: TextStyle(
                            color: selected ? color : const Color(0xFF7878A0),
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w400)),
                  ),
                );
              }).toList(),
            ),
            const Gap(20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Label('Виробник'),
                      const Gap(8),
                      TextFormField(
                        controller: _brandCtrl,
                        decoration:
                            const InputDecoration(hintText: 'Esun, Bambu…'),
                      ),
                    ],
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Label('Колір'),
                      const Gap(8),
                      TextFormField(
                        controller: _colorCtrl,
                        decoration:
                            const InputDecoration(hintText: 'Чорний, Білий…'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Label('Запас (г)'),
                      const Gap(8),
                      TextFormField(
                        controller: _stockCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(suffixText: 'г'),
                        validator: (v) {
                          if (v == null || v.isEmpty) return null;
                          if (double.tryParse(v) == null) return 'Число';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Label('Ціна за кг (₴)'),
                      const Gap(8),
                      TextFormField(
                        controller: _priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(suffixText: '₴/кг'),
                        validator: (v) {
                          if (v == null || v.isEmpty) return null;
                          if (double.tryParse(v) == null) return 'Число';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(20),
            _Label('Мінімальний запас (г) — поріг попередження'),
            const Gap(8),
            TextFormField(
              controller: _minStockCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  hintText: 'Наприклад: 200', suffixText: 'г'),
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
            if (isEditing) ...[
              const Gap(20),
              const Divider(color: Color(0xFF2A2A4A)),
              const Gap(12),
              _Label('КОРИГУВАННЯ ЗАПАСУ'),
              const Gap(12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showAdjustDialog(false),
                      icon: const Icon(Icons.remove, size: 16),
                      label: const Text('Витрата'),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFE74C3C),
                          side: const BorderSide(color: Color(0xFFE74C3C))),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showAdjustDialog(true),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Поповнення'),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2ECC71),
                          side: const BorderSide(color: Color(0xFF2ECC71))),
                    ),
                  ),
                ],
              ),
            ],
            const Gap(80),
          ],
        ),
      ),
    );
  }

  Future<void> _showAdjustDialog(bool isAdd) async {
    final ctrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isAdd ? 'Додати запас' : 'Списати запас'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
              labelText: 'Кількість (г)', suffixText: 'г'),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Скасувати')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('OK')),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final grams = double.tryParse(ctrl.text) ?? 0;
      if (grams > 0) {
        await context.read<MaterialProvider>().adjustStock(
              widget.material!.id,
              isAdd ? grams : -grams,
            );
        if (mounted) Navigator.pop(context);
      }
    }
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
