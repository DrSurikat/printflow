import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/order.dart';
import '../providers/order_provider.dart';
import '../providers/client_provider.dart';
import '../widgets/order_card.dart';
import 'order_detail_screen.dart';
import 'client_form_screen.dart';

class ClientDetailScreen extends StatelessWidget {
  final String clientId;
  const ClientDetailScreen({super.key, required this.clientId});

  @override
  Widget build(BuildContext context) {
    final clientProvider = context.watch<ClientProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final client = clientProvider.getById(clientId);

    if (client == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Клієнта не знайдено')),
      );
    }

    final orders = orderProvider.getByClient(clientId);
    final totalSpent = orders
        .where((o) => o.status == OrderStatus.completed)
        .fold(0.0, (s, o) => s + o.total);
    final currency =
        NumberFormat.currency(locale: 'uk_UA', symbol: '₴', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: Text(client.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ClientFormScreen(client: client))),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, clientProvider),
          ),
          const Gap(8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar + name
            Row(children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF9B59B6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    client.initials,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 22),
                  ),
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(client.name,
                        style: Theme.of(context).textTheme.titleLarge),
                    if (client.company.isNotEmpty) ...[
                      const Gap(2),
                      Text(client.company,
                          style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ],
                ),
              ),
            ]),
            const Gap(20),

            // Stats row
            Row(children: [
              _StatPill(label: 'Замовлень', value: orders.length.toString()),
              const Gap(10),
              _StatPill(
                  label: 'Витрачено',
                  value: currency.format(totalSpent),
                  color: const Color(0xFF2ECC71)),
            ]),
            const Gap(20),

            // Contact info
            _Section('Контакти', [
              if (client.phone.isNotEmpty)
                _ContactRow(Icons.phone_outlined, client.phone),
              if (client.email.isNotEmpty)
                _ContactRow(Icons.email_outlined, client.email),
              if (client.address.isNotEmpty)
                _ContactRow(Icons.location_on_outlined, client.address),
            ]),
            if (client.notes != null && client.notes!.isNotEmpty) ...[
              const Gap(16),
              _Section('Примітки', [
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(client.notes!,
                      style: Theme.of(context).textTheme.bodyLarge),
                ),
              ]),
            ],

            // Messengers
            if (client.telegram != null ||
                client.viber != null ||
                client.instagram != null) ...[
              const Gap(16),
              _Section('Месенджери', [
                if (client.telegram != null)
                  _ContactRow(
                    Icons.telegram,
                    'Telegram: ${client.telegram!}',
                    color: const Color(0xFF2CA5E0),
                    onTap: () {
                      final u = client.telegram!.startsWith('+')
                          ? 'tg://resolve?phone=${client.telegram!.replaceAll('+', '')}'
                          : 'tg://resolve?domain=${client.telegram!}';
                      launchUrl(Uri.parse(u));
                    },
                  ),
                if (client.viber != null)
                  _ContactRow(
                    Icons.phone_in_talk_outlined,
                    'Viber: ${client.viber!}',
                    color: const Color(0xFF7360F2),
                    onTap: () => launchUrl(Uri.parse(
                        'viber://chat?number=${Uri.encodeComponent(client.viber!)}')),
                  ),
                if (client.instagram != null)
                  _ContactRow(
                    Icons.camera_alt_outlined,
                    'Instagram: ${client.instagram!}',
                    color: const Color(0xFFE1306C),
                    onTap: () => launchUrl(Uri.parse(
                        'https://instagram.com/${client.instagram!}')),
                  ),
              ]),
            ],
            const Gap(20),

            // Orders
            Text('Замовлення', style: Theme.of(context).textTheme.titleMedium),
            const Gap(12),
            if (orders.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Немає замовлень',
                    style: Theme.of(context).textTheme.bodyLarge),
              )
            else
              ...orders.map((o) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: OrderCard(
                      order: o,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  OrderDetailScreen(orderId: o.id))),
                    ),
                  )),
            const Gap(60),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, ClientProvider provider) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Видалити клієнта?'),
        content: const Text('Всі дані клієнта будуть видалені.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Скасувати')),
          TextButton(
            onPressed: () {
              provider.deleteClient(clientId);
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

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatPill(
      {required this.label,
      required this.value,
      this.color = const Color(0xFF6C63FF)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w700, fontSize: 16)),
          Text(label,
              style: const TextStyle(color: Color(0xFF7878A0), fontSize: 11)),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section(this.title, this.children);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(),
            style: const TextStyle(
                color: Color(0xFF7878A0),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8)),
        const Gap(8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF16213E),
            borderRadius: BorderRadius.circular(14),
            border: const Border.fromBorderSide(
                BorderSide(color: Color(0xFF2A2A4A))),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback? onTap;
  const _ContactRow(this.icon, this.text,
      {this.color = const Color(0xFF6C63FF), this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Icon(icon, size: 18, color: color),
          const Gap(10),
          Expanded(
              child: Text(text, style: Theme.of(context).textTheme.bodyLarge)),
          if (onTap != null)
            Icon(Icons.open_in_new,
                size: 14, color: color.withValues(alpha: .6)),
        ]),
      ),
    );
  }
}
