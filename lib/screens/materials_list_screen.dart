import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/material_item.dart';
import '../providers/material_provider.dart';
import 'material_form_screen.dart';

class MaterialsListScreen extends StatelessWidget {
  const MaterialsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MaterialProvider>();
    final materials = provider.filtered;
    final currency =
        NumberFormat.currency(locale: 'uk_UA', symbol: '₴', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: Text('Матеріали', style: Theme.of(context).textTheme.titleLarge),
      ),
      body: Column(
        children: [
          // Summary bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                _SummaryChip(
                  label: 'Всього',
                  value: provider.totalCount.toString(),
                  color: const Color(0xFF6C63FF),
                ),
                const Gap(8),
                _SummaryChip(
                  label: 'Мало запасів',
                  value: provider.lowStockCount.toString(),
                  color: const Color(0xFFE74C3C),
                ),
                const Gap(8),
                _SummaryChip(
                  label: 'Вартість',
                  value: currency.format(provider.totalInventoryValue),
                  color: const Color(0xFF2ECC71),
                ),
              ],
            ),
          ),
          const Gap(12),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: provider.setSearch,
              decoration: const InputDecoration(
                hintText: 'Пошук матеріалу…',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
            ),
          ),
          const Gap(12),

          // Category filter
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _CategoryChip(
                  label: 'Всі',
                  selected: provider.filterCategory == null,
                  color: const Color(0xFF6C63FF),
                  onTap: () => provider.setFilterCategory(null),
                ),
                const Gap(8),
                ...MaterialCategory.values.map((cat) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _CategoryChip(
                        label: cat.label,
                        selected: provider.filterCategory == cat,
                        color: Color(cat.colorValue),
                        onTap: () => provider.setFilterCategory(
                            provider.filterCategory == cat ? null : cat),
                      ),
                    )),
              ],
            ),
          ),
          const Gap(12),

          // Materials list
          Expanded(
            child: materials.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: materials.length,
                    separatorBuilder: (_, __) => const Gap(10),
                    itemBuilder: (ctx, i) =>
                        _MaterialTile(material: materials[i]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const MaterialFormScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Додати матеріал'),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w700, fontSize: 15)),
            Text(label,
                style: const TextStyle(color: Color(0xFF7878A0), fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.2) : Colors.transparent,
          border: Border.all(color: selected ? color : const Color(0xFF2A2A4A)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : const Color(0xFF7878A0),
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _MaterialTile extends StatelessWidget {
  final MaterialItem material;
  const _MaterialTile({required this.material});

  @override
  Widget build(BuildContext context) {
    final color = Color(material.category.colorValue);
    final isLow = material.isLowStock;

    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => MaterialFormScreen(material: material))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Category icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  material.category == MaterialCategory.filament
                      ? Icons.cable_outlined
                      : material.category == MaterialCategory.resin
                          ? Icons.water_drop_outlined
                          : Icons.layers_outlined,
                  color: color,
                  size: 22,
                ),
              ),
              const Gap(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(material.name,
                              style: Theme.of(context).textTheme.titleMedium),
                        ),
                        if (isLow)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE74C3C)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('⚠ Мало',
                                style: TextStyle(
                                    color: Color(0xFFE74C3C),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),
                    const Gap(4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(material.category.label,
                              style: TextStyle(
                                  color: color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500)),
                        ),
                        if (material.brand.isNotEmpty) ...[
                          const Gap(6),
                          Text(material.brand,
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                        if (material.color.isNotEmpty) ...[
                          const Gap(6),
                          Text('• ${material.color}',
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${material.stockKg.toStringAsFixed(2)} кг',
                    style: TextStyle(
                      color: isLow ? const Color(0xFFE74C3C) : Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    '${material.pricePerKg.toStringAsFixed(0)} ₴/кг',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.layers_outlined, size: 72, color: Color(0xFF2A2A4A)),
          const Gap(16),
          Text('Матеріалів поки немає',
              style: Theme.of(context).textTheme.titleMedium),
          const Gap(6),
          Text('Додайте перший матеріал до бази',
              style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
