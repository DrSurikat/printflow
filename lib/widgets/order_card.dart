import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../models/order.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const OrderCard({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final currency =
        NumberFormat.currency(locale: 'uk_UA', symbol: '₴', decimalDigits: 0);
    final statusColor = Color(order.status.colorValue);
    final dateFormat = DateFormat('dd.MM.yy');

    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: order.isOverdue
                  ? const Color(0xFFE74C3C).withValues(alpha: 0.4)
                  : const Color(0xFF2A2A4A),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Order number + status badge
                  Row(children: [
                    Text(
                      order.number,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Colors.white),
                    ),
                    const Gap(8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        order.status.label,
                        style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (order.isOverdue) ...[
                      const Gap(6),
                      const Icon(Icons.warning_amber_rounded,
                          size: 14, color: Color(0xFFE74C3C)),
                    ],
                  ]),

                  // Total
                  Text(
                    currency.format(order.total),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF6C63FF)),
                  ),
                ],
              ),
              const Gap(8),
              Row(children: [
                const Icon(Icons.person_outline,
                    size: 14, color: Color(0xFF7878A0)),
                const Gap(4),
                Text(order.clientName,
                    style: Theme.of(context).textTheme.bodyLarge),
                const Spacer(),
                if (order.deadline != null) ...[
                  Icon(
                    Icons.schedule_outlined,
                    size: 14,
                    color: order.isOverdue
                        ? const Color(0xFFE74C3C)
                        : const Color(0xFF7878A0),
                  ),
                  const Gap(3),
                  Text(
                    dateFormat.format(order.deadline!),
                    style: TextStyle(
                        fontSize: 12,
                        color: order.isOverdue
                            ? const Color(0xFFE74C3C)
                            : const Color(0xFF7878A0)),
                  ),
                ],
              ]),
              const Gap(6),
              Row(children: [
                const Icon(Icons.inbox_outlined,
                    size: 13, color: Color(0xFF5A5A7A)),
                const Gap(4),
                Text(
                  '${order.items.length} поз.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (order.isPaid) ...[
                  const Gap(10),
                  const Icon(Icons.check_circle_outline,
                      size: 13, color: Color(0xFF2ECC71)),
                  const Gap(3),
                  const Text('Оплачено',
                      style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF2ECC71),
                          fontWeight: FontWeight.w500)),
                ],
                const Spacer(),
                Text(
                  dateFormat.format(order.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
