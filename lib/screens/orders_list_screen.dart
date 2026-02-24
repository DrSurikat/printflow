import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../providers/order_provider.dart';
import '../widgets/order_card.dart';
import 'order_detail_screen.dart';
import 'order_form_screen.dart';

class OrdersListScreen extends StatelessWidget {
  const OrdersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    final orders = provider.filtered;

    return Scaffold(
      appBar: AppBar(
        title:
            Text('Замовлення', style: Theme.of(context).textTheme.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const OrderFormScreen())),
          ),
          const Gap(8),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              onChanged: provider.setSearch,
              decoration: const InputDecoration(
                hintText: 'Пошук за номером або клієнтом…',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
            ),
          ),
          const Gap(12),

          // Filter chips
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(
                  label: 'Всі',
                  selected:
                      provider.filterStatus == null && !provider.filterOverdue,
                  onTap: () {
                    provider.setFilterStatus(null);
                    if (provider.filterOverdue) provider.toggleOverdueFilter();
                  },
                ),
                const Gap(8),
                ...OrderStatus.values.map((s) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _FilterChip(
                        label: s.label,
                        color: Color(s.colorValue),
                        selected: provider.filterStatus == s,
                        onTap: () => provider.setFilterStatus(
                            provider.filterStatus == s ? null : s),
                      ),
                    )),
                _FilterChip(
                  label: '⚠ Прострочені',
                  color: const Color(0xFFE74C3C),
                  selected: provider.filterOverdue,
                  onTap: provider.toggleOverdueFilter,
                ),
              ],
            ),
          ),
          const Gap(12),

          // Orders list
          Expanded(
            child: orders.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const Gap(12),
                    itemBuilder: (ctx, i) => OrderCard(
                      order: orders[i],
                      onTap: () => Navigator.push(
                          ctx,
                          MaterialPageRoute(
                              builder: (_) =>
                                  OrderDetailScreen(orderId: orders[i].id))),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const OrderFormScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Нове замовлення'),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? c.withValues(alpha: 0.2) : Colors.transparent,
          border: Border.all(color: selected ? c : const Color(0xFF2A2A4A)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? c : const Color(0xFF7878A0),
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
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
          const Icon(Icons.receipt_long_outlined,
              size: 72, color: Color(0xFF2A2A4A)),
          const Gap(16),
          Text('Замовлень не знайдено',
              style: Theme.of(context).textTheme.titleMedium),
          const Gap(6),
          Text('Спробуйте змінити фільтр або додайте нове',
              style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
