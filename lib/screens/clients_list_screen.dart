import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../models/client.dart';
import '../providers/client_provider.dart';
import '../providers/order_provider.dart';
import 'client_detail_screen.dart';
import 'client_form_screen.dart';

class ClientsListScreen extends StatelessWidget {
  const ClientsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClientProvider>();
    final clients = provider.filtered;

    return Scaffold(
      appBar: AppBar(
        title: Text('Клієнти', style: Theme.of(context).textTheme.titleLarge),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              onChanged: provider.setSearch,
              decoration: const InputDecoration(
                hintText: 'Пошук клієнта…',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
            ),
          ),
          Expanded(
            child: clients.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: clients.length,
                    separatorBuilder: (_, __) => const Gap(10),
                    itemBuilder: (ctx, i) => _ClientTile(client: clients[i]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ClientFormScreen())),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Новий клієнт'),
      ),
    );
  }
}

class _ClientTile extends StatelessWidget {
  final Client client;
  const _ClientTile({required this.client});

  @override
  Widget build(BuildContext context) {
    final orderCount =
        context.read<OrderProvider>().getByClient(client.id).length;

    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ClientDetailScreen(clientId: client.id))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF9B59B6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    client.initials,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16),
                  ),
                ),
              ),
              const Gap(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(client.name,
                        style: Theme.of(context).textTheme.titleMedium),
                    if (client.company.isNotEmpty) ...[
                      const Gap(2),
                      Text(client.company,
                          style: Theme.of(context).textTheme.bodyLarge),
                    ],
                    if (client.phone.isNotEmpty) ...[
                      const Gap(2),
                      Text(client.phone,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$orderCount зам.',
                      style: const TextStyle(
                          color: Color(0xFF6C63FF),
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Gap(4),
                  const Icon(Icons.chevron_right,
                      color: Color(0xFF5A5A7A), size: 18),
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
          const Icon(Icons.people_outline, size: 72, color: Color(0xFF2A2A4A)),
          const Gap(16),
          Text('Клієнтів поки немає',
              style: Theme.of(context).textTheme.titleMedium),
          const Gap(6),
          Text('Додайте першого клієнта',
              style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
