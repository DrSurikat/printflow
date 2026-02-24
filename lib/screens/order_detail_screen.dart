import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/delivery_tracking.dart';
import '../models/order.dart';
import '../providers/delivery_provider.dart';
import '../providers/order_provider.dart';
import '../providers/settings_provider.dart';
import '../services/invoice_service.dart';
import 'order_form_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final _trackingCtrl = TextEditingController();
  DeliveryCarrier _carrier = DeliveryCarrier.novaPoshta;

  @override
  void dispose() {
    _trackingCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    final order = provider.getById(widget.orderId);
    if (order == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Замовлення не знайдено')),
      );
    }

    final currency =
        NumberFormat.currency(locale: 'uk_UA', symbol: '₴', decimalDigits: 0);
    final statusColor = Color(order.status.colorValue);
    final settings = context.watch<SettingsProvider>().settings;
    final deliveryProv = context.watch<DeliveryProvider>();
    final tracking = deliveryProv.getLatestByOrder(widget.orderId);

    return Scaffold(
      appBar: AppBar(
        title: Text(order.number),
        actions: [
          // Invoice button
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Рахунок PDF',
            onPressed: () async {
              try {
                await InvoiceService.showInvoice(
                  order: order,
                  settings: settings,
                );
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Помилка генерації рахунку: $e')),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => OrderFormScreen(order: order))),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, provider, order),
          ),
          const Gap(8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status + dates card
            _InfoCard(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Статус',
                            style: Theme.of(context).textTheme.bodySmall),
                        const Gap(4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: statusColor.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            order.status.label,
                            style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ]),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('Оплата',
                        style: Theme.of(context).textTheme.bodySmall),
                    const Gap(4),
                    Row(children: [
                      Icon(
                        order.isPaid
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: order.isPaid
                            ? const Color(0xFF2ECC71)
                            : const Color(0xFF7878A0),
                        size: 18,
                      ),
                      const Gap(4),
                      Text(
                        order.isPaid ? 'Оплачено' : 'Не оплачено',
                        style: TextStyle(
                          color: order.isPaid
                              ? const Color(0xFF2ECC71)
                              : const Color(0xFF7878A0),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ]),
                  ]),
                ],
              ),
              const Gap(16),
              Row(children: [
                Expanded(
                    child: _DateInfo(
                  label: 'Створено',
                  date: order.createdAt,
                )),
                if (order.deadline != null)
                  Expanded(
                      child: _DateInfo(
                    label: 'Дедлайн',
                    date: order.deadline!,
                    isOverdue: order.isOverdue,
                  )),
              ]),
            ]),
            const Gap(12),

            // Client card
            _InfoCard(children: [
              _SectionLabel('Клієнт'),
              const Gap(8),
              Row(children: [
                const Icon(Icons.person_outline,
                    size: 18, color: Color(0xFF7878A0)),
                const Gap(8),
                Text(order.clientName,
                    style: Theme.of(context).textTheme.titleMedium),
              ]),
              if (order.paymentMethod != null) ...[
                const Gap(6),
                Row(children: [
                  const Icon(Icons.payment_outlined,
                      size: 18, color: Color(0xFF7878A0)),
                  const Gap(8),
                  Text(order.paymentMethod!,
                      style: Theme.of(context).textTheme.bodyLarge),
                ]),
              ],
            ]),
            const Gap(12),

            // Items card
            _InfoCard(children: [
              _SectionLabel('Позиції замовлення'),
              const Gap(12),
              ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontSize: 14)),
                              if (item.description.isNotEmpty)
                                Text(item.description,
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                        Text(
                          '${item.quantity} ${item.unit}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const Gap(16),
                        Text(
                          currency.format(item.totalPrice),
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ],
                    ),
                  )),
              const Divider(color: Color(0xFF2A2A4A)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Підсумок',
                      style: TextStyle(color: Color(0xFF7878A0))),
                  Text(currency.format(order.subtotal),
                      style: const TextStyle(color: Colors.white)),
                ],
              ),
              if (order.discount != null && order.discount! > 0) ...[
                const Gap(4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Знижка ${order.discount!.toStringAsFixed(0)}%',
                        style: const TextStyle(color: Color(0xFFFFB347))),
                    Text('- ${currency.format(order.discountAmount)}',
                        style: const TextStyle(color: Color(0xFFFFB347))),
                  ],
                ),
              ],
              const Gap(8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Всього',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.white)),
                  Text(
                    currency.format(order.total),
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: Color(0xFF6C63FF)),
                  ),
                ],
              ),
            ]),
            const Gap(12),

            if (order.notes != null && order.notes!.isNotEmpty)
              _InfoCard(children: [
                _SectionLabel('Примітки'),
                const Gap(8),
                Text(order.notes!,
                    style: Theme.of(context).textTheme.bodyLarge),
              ]),
            const Gap(12),

            // ── Delivery tracking ──────────────────────────────
            _InfoCard(children: [
              _SectionLabel('Доставка'),
              const Gap(12),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _trackingCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Трекінг-номер',
                      prefixIcon: Icon(Icons.local_shipping_outlined),
                      isDense: true,
                    ),
                  ),
                ),
                const Gap(8),
                DropdownButton<DeliveryCarrier>(
                  value: _carrier,
                  underline: const SizedBox(),
                  borderRadius: BorderRadius.circular(12),
                  items: DeliveryCarrier.values
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c.label,
                                style: const TextStyle(fontSize: 13)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _carrier = v ?? _carrier),
                ),
              ]),
              const Gap(10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: deliveryProv.isLoading
                      ? null
                      : () => _track(context, order, deliveryProv, settings),
                  icon: deliveryProv.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.search, size: 18),
                  label: Text(
                      deliveryProv.isLoading ? 'Запитуємо...' : 'Відстежити'),
                ),
              ),
              if (deliveryProv.error != null) ...[
                const Gap(8),
                Text(deliveryProv.error!,
                    style: const TextStyle(
                        color: Color(0xFFE74C3C), fontSize: 12)),
              ],
              if (tracking != null) ...[
                const Gap(12),
                const Divider(color: Color(0xFF2A2A4A)),
                const Gap(8),
                Row(children: [
                  const Icon(Icons.info_outline,
                      size: 16, color: Color(0xFF7878A0)),
                  const Gap(6),
                  Expanded(
                    child: Text(
                      tracking.lastStatus,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                  ),
                ]),
                const Gap(4),
                Text(
                  'Оновлено: ${DateFormat('dd.MM.yyyy HH:mm').format(tracking.lastUpdated)}',
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFF7878A0)),
                ),
                if (tracking.history.isNotEmpty) ...[
                  const Gap(8),
                  ...tracking.history.map((step) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ',
                                style: TextStyle(color: Color(0xFF7878A0))),
                            Expanded(
                              child: Text(step,
                                  style: const TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      )),
                ],
              ],
            ]),
            const Gap(12),

            // Status change buttons
            _SectionLabel('Змінити статус'),
            const Gap(10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  OrderStatus.values.where((s) => s != order.status).map((s) {
                final c = Color(s.colorValue);
                return OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: c,
                    side: BorderSide(color: c.withValues(alpha: 0.5)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => provider.updateStatus(order.id, s),
                  child: Text(s.label, style: const TextStyle(fontSize: 13)),
                );
              }).toList(),
            ),
            const Gap(80),
          ],
        ),
      ),
    );
  }

  Future<void> _track(
    BuildContext context,
    Order order,
    DeliveryProvider deliveryProv,
    dynamic settings,
  ) async {
    final number = _trackingCtrl.text.trim();
    if (number.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введіть трекінг-номер')),
      );
      return;
    }

    final apiKey = _carrier == DeliveryCarrier.novaPoshta
        ? settings.novaPoshtaApiKey
        : settings.ukrposhtaToken;

    await deliveryProv.track(
      orderId: order.id,
      orderNumber: order.number,
      trackingNumber: number,
      carrier: _carrier,
      apiKey: apiKey,
    );
  }

  void _confirmDelete(BuildContext ctx, OrderProvider provider, Order order) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Видалити замовлення?'),
        content: Text('Замовлення ${order.number} буде видалено назавжди.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Скасувати')),
          TextButton(
            onPressed: () {
              provider.deleteOrder(order.id);
              Navigator.pop(ctx);
              Navigator.pop(ctx);
            },
            child: const Text('Видалити',
                style: TextStyle(color: Color(0xFFE74C3C))),
          ),
        ],
      ),
    );
  }
}

// ── Reusable widgets ──────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border:
            const Border.fromBorderSide(BorderSide(color: Color(0xFF2A2A4A))),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          color: Color(0xFF7878A0),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8),
    );
  }
}

class _DateInfo extends StatelessWidget {
  final String label;
  final DateTime date;
  final bool isOverdue;
  const _DateInfo(
      {required this.label, required this.date, this.isOverdue = false});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd.MM.yyyy');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Color(0xFF7878A0), fontSize: 11)),
        const Gap(2),
        Text(
          fmt.format(date),
          style: TextStyle(
            color: isOverdue ? const Color(0xFFE74C3C) : Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
