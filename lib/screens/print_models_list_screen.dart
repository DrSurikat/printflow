import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/print_model.dart';
import '../providers/print_model_provider.dart';
import 'print_model_form_screen.dart';

class PrintModelsListScreen extends StatelessWidget {
  const PrintModelsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrintModelProvider>();
    final models = provider.filtered;

    return Scaffold(
      appBar: AppBar(
        title: Text('Моделі', style: Theme.of(context).textTheme.titleLarge),
      ),
      body: Column(
        children: [
          // Stats
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                _StatBadge(
                  label: 'Бібліотека',
                  value: provider.totalCount.toString(),
                  color: const Color(0xFF6C63FF),
                ),
                const Gap(8),
                _StatBadge(
                  label: 'Разів надруковано',
                  value: provider.totalPrints.toString(),
                  color: const Color(0xFF03DAC6),
                ),
              ],
            ),
          ),
          const Gap(12),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: provider.setSearch,
              decoration: const InputDecoration(
                hintText: 'Пошук моделі, тегу, клієнта…',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
            ),
          ),
          const Gap(12),

          // File type chips
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _TypeChip(
                  label: 'Всі',
                  selected: provider.filterType == null,
                  onTap: () => provider.setFilterType(null),
                ),
                const Gap(8),
                ...ModelFileType.values.map((t) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _TypeChip(
                        label: t.label,
                        selected: provider.filterType == t,
                        onTap: () => provider
                            .setFilterType(provider.filterType == t ? null : t),
                      ),
                    )),
              ],
            ),
          ),
          const Gap(12),

          // Grid
          Expanded(
            child: models.isEmpty
                ? const _EmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      mainAxisExtent: 180,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: models.length,
                    itemBuilder: (ctx, i) => _ModelCard(model: models[i]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PrintModelFormScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Нова модель'),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBadge(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Text(value,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w700, fontSize: 18)),
            const Gap(8),
            Text(label,
                style: const TextStyle(color: Color(0xFF7878A0), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
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
        child: Text(label,
            style: TextStyle(
              color: selected ? color : const Color(0xFF7878A0),
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            )),
      ),
    );
  }
}

class _ModelCard extends StatelessWidget {
  final PrintModel model;
  const _ModelCard({required this.model});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd.MM.yy');
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => PrintModelFormScreen(model: model))),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A2A4A)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon + file type
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF03DAC6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.view_in_ar,
                        color: Colors.white, size: 20),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(model.fileType.label,
                        style: const TextStyle(
                            color: Color(0xFF8B85FF),
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const Gap(12),

              Text(model.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const Gap(4),

              if (model.clientName != null)
                Text(model.clientName!,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(fmt.format(model.createdAt),
                      style: Theme.of(context).textTheme.bodySmall),
                  if (model.printCount > 0)
                    Row(
                      children: [
                        const Icon(Icons.print_outlined,
                            size: 12, color: Color(0xFF7878A0)),
                        const Gap(3),
                        Text('${model.printCount}',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
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
          const Icon(Icons.view_in_ar_outlined,
              size: 72, color: Color(0xFF2A2A4A)),
          const Gap(16),
          Text('Бібліотека порожня',
              style: Theme.of(context).textTheme.titleMedium),
          const Gap(6),
          Text('Додайте першу 3D-модель',
              style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
