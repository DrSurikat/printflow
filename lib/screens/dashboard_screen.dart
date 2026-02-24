import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../providers/order_provider.dart';
import '../providers/client_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/order_card.dart';
import 'order_detail_screen.dart';
import 'order_form_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>();
    final clients = context.watch<ClientProvider>();
    final currency =
        NumberFormat.currency(locale: 'uk_UA', symbol: '₴', decimalDigits: 0);

    final recentOrders = orders.all.take(5).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF03DAC6)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.print, color: Colors.white, size: 18),
                ),
                const Gap(10),
                Text('PrintFlow',
                    style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Нове замовлення',
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const OrderFormScreen())),
              ),
              const Gap(8),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Огляд',
                      style: Theme.of(context).textTheme.displayLarge),
                  const Gap(4),
                  Text(
                    DateFormat('EEEE, d MMMM yyyy', 'uk_UA')
                        .format(DateTime.now()),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const Gap(20),

                  // Revenue row
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: 'Виручка',
                          value: currency.format(orders.totalRevenue),
                          icon: Icons.payments_outlined,
                          color: const Color(0xFF2ECC71),
                          subtitle: 'Завершені',
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: StatCard(
                          label: 'В очікуванні',
                          value: currency.format(orders.pendingRevenue),
                          icon: Icons.pending_outlined,
                          color: const Color(0xFFFFB347),
                          subtitle: 'Активні',
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),

                  // Counts row
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: 'Замовлення',
                          value: orders.totalCount.toString(),
                          icon: Icons.receipt_long_outlined,
                          color: const Color(0xFF6C63FF),
                          subtitle: 'Всього',
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: StatCard(
                          label: 'Клієнти',
                          value: clients.totalCount.toString(),
                          icon: Icons.people_outline,
                          color: const Color(0xFF9B59B6),
                          subtitle: 'Зареєстровано',
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: StatCard(
                          label: 'Прострочені',
                          value: orders.overdueCount.toString(),
                          icon: Icons.warning_amber_outlined,
                          color: const Color(0xFFE74C3C),
                          subtitle: 'Увага',
                        ),
                      ),
                    ],
                  ),
                  const Gap(20),

                  // Status chips
                  Text('По статусах',
                      style: Theme.of(context).textTheme.titleMedium),
                  const Gap(12),
                  _StatusRow(orders: orders),
                  const Gap(20),

                  // Recent orders
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Останні замовлення',
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  const Gap(12),
                ],
              ),
            ),
          ),
          if (recentOrders.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.inbox_outlined,
                          size: 64, color: Color(0xFF3A3A5C)),
                      const Gap(12),
                      Text('Замовлень поки немає',
                          style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: OrderCard(
                      order: recentOrders[i],
                      onTap: () => Navigator.push(
                          ctx,
                          MaterialPageRoute(
                              builder: (_) => OrderDetailScreen(
                                  orderId: recentOrders[i].id))),
                    ),
                  ),
                  childCount: recentOrders.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final OrderProvider orders;
  const _StatusRow({required this.orders});

  @override
  Widget build(BuildContext context) {
    final statuses = [
      OrderStatus.new_,
      OrderStatus.inProgress,
      OrderStatus.readyForPickup,
      OrderStatus.completed,
      OrderStatus.cancelled,
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: statuses.map((s) {
          final count = orders.countByStatus(s);
          final color = Color(s.colorValue);
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const Gap(6),
                Text(
                  '${s.label}  $count',
                  style: TextStyle(
                      color: color, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
