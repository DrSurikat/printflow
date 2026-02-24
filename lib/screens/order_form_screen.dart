import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../providers/order_provider.dart';
import '../models/order_item.dart';
import '../providers/client_provider.dart';
import '../models/client.dart';
import 'package:uuid/uuid.dart';

class OrderFormScreen extends StatefulWidget {
  final Order? order;
  const OrderFormScreen({super.key, this.order});

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  Client? _selectedClient;
  DateTime? _deadline;
  String? _paymentMethod;
  double? _discount;
  final _notesController = TextEditingController();
  final _discountController = TextEditingController();

  List<_ItemEntry> _items = [];

  bool get isEditing => widget.order != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final o = widget.order!;
      _deadline = o.deadline;
      _paymentMethod = o.paymentMethod;
      _discount = o.discount;
      if (_discount != null) {
        _discountController.text = _discount!.toStringAsFixed(0);
      }
      _notesController.text = o.notes ?? '';
      _items = o.items
          .map((i) => _ItemEntry(
                id: i.id,
                nameCtrl: TextEditingController(text: i.name),
                descCtrl: TextEditingController(text: i.description),
                qtyCtrl: TextEditingController(text: i.quantity.toString()),
                priceCtrl:
                    TextEditingController(text: i.unitPrice.toStringAsFixed(0)),
                unitCtrl: TextEditingController(text: i.unit ?? 'шт'),
              ))
          .toList();
    } else {
      _addItem();
    }
  }

  void _addItem() {
    setState(() {
      _items.add(_ItemEntry(
        id: _uuid.v4(),
        nameCtrl: TextEditingController(),
        descCtrl: TextEditingController(),
        qtyCtrl: TextEditingController(text: '1'),
        priceCtrl: TextEditingController(),
        unitCtrl: TextEditingController(text: 'шт'),
      ));
    });
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('uk'),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClient == null && !isEditing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Оберіть клієнта')),
      );
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Додайте хоча б одну позицію')),
      );
      return;
    }

    final orderItems = _items.map((e) {
      return OrderItem(
        id: e.id,
        name: e.nameCtrl.text.trim(),
        description: e.descCtrl.text.trim(),
        quantity: int.tryParse(e.qtyCtrl.text) ?? 1,
        unitPrice: double.tryParse(e.priceCtrl.text) ?? 0,
        unit: e.unitCtrl.text.trim().isEmpty ? 'шт' : e.unitCtrl.text.trim(),
      );
    }).toList();

    final provider = context.read<OrderProvider>();

    if (isEditing) {
      await provider.updateOrder(widget.order!.copyWith(
        deadline: _deadline,
        items: orderItems,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        discount: double.tryParse(_discountController.text),
        paymentMethod: _paymentMethod?.isEmpty ?? true ? null : _paymentMethod,
      ));
    } else {
      await provider.addOrder(
        clientId: _selectedClient!.id,
        clientName: _selectedClient!.name,
        deadline: _deadline,
        items: orderItems,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        discount: double.tryParse(_discountController.text),
        paymentMethod: _paymentMethod?.isEmpty ?? true ? null : _paymentMethod,
      );
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final clients = context.read<ClientProvider>().all;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Редагувати замовлення' : 'Нове замовлення'),
        actions: [
          TextButton(
            onPressed: _submit,
            child: const Text('Зберегти'),
          ),
          const Gap(8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Client picker
            if (!isEditing) ...[
              _Label('Клієнт *'),
              const Gap(8),
              DropdownButtonFormField<Client>(
                initialValue: _selectedClient,
                decoration: const InputDecoration(
                  hintText: 'Оберіть клієнта',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                items: clients
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.company.isNotEmpty
                              ? '${c.name} (${c.company})'
                              : c.name),
                        ))
                    .toList(),
                onChanged: (c) => setState(() => _selectedClient = c),
                validator: (v) => v == null ? 'Оберіть клієнта' : null,
                dropdownColor: const Color(0xFF1A1A2E),
              ),
              const Gap(20),
            ],

            // Deadline
            _Label('Дедлайн'),
            const Gap(8),
            GestureDetector(
              onTap: _pickDeadline,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(12),
                  border: const Border.fromBorderSide(
                      BorderSide(color: Color(0xFF2A2A4A))),
                ),
                child: Row(children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 18, color: Color(0xFF7878A0)),
                  const Gap(10),
                  Text(
                    _deadline != null
                        ? DateFormat('dd.MM.yyyy').format(_deadline!)
                        : 'Обрати дату',
                    style: TextStyle(
                      color: _deadline != null
                          ? Colors.white
                          : const Color(0xFF5A5A7A),
                    ),
                  ),
                  const Spacer(),
                  if (_deadline != null)
                    GestureDetector(
                      onTap: () => setState(() => _deadline = null),
                      child: const Icon(Icons.close,
                          size: 16, color: Color(0xFF7878A0)),
                    ),
                ]),
              ),
            ),
            const Gap(20),

            // Payment + discount
            Row(children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Спосіб оплати'),
                    const Gap(8),
                    DropdownButtonFormField<String>(
                      initialValue: _paymentMethod,
                      decoration: const InputDecoration(hintText: 'Оберіть'),
                      items: const [
                        DropdownMenuItem(
                            value: 'Готівка', child: Text('Готівка')),
                        DropdownMenuItem(
                            value: 'Картка', child: Text('Картка')),
                        DropdownMenuItem(
                            value: 'Безготівковий',
                            child: Text('Безготівковий')),
                      ],
                      onChanged: (v) => setState(() => _paymentMethod = v),
                      dropdownColor: const Color(0xFF1A1A2E),
                    ),
                  ],
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Знижка %'),
                    const Gap(8),
                    TextFormField(
                      controller: _discountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(suffixText: '%'),
                      validator: (v) {
                        if (v == null || v.isEmpty) return null;
                        final n = double.tryParse(v);
                        if (n == null || n < 0 || n > 100) {
                          return '0-100';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ]),
            const Gap(20),

            // Items
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Label('Позиції замовлення'),
                TextButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Додати'),
                ),
              ],
            ),
            const Gap(8),
            ..._items.asMap().entries.map((e) => _ItemForm(
                  entry: e.value,
                  index: e.key,
                  onRemove: () => _removeItem(e.key),
                )),
            const Gap(20),

            // Notes
            _Label('Примітки'),
            const Gap(8),
            TextFormField(
              controller: _notesController,
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

class _ItemForm extends StatelessWidget {
  final _ItemEntry entry;
  final int index;
  final VoidCallback onRemove;
  const _ItemForm(
      {required this.entry, required this.index, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(14),
        border:
            const Border.fromBorderSide(BorderSide(color: Color(0xFF2A2A4A))),
      ),
      child: Column(
        children: [
          Row(children: [
            Text('Позиція ${index + 1}',
                style: const TextStyle(
                    color: Color(0xFF7878A0),
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
            const Spacer(),
            GestureDetector(
              onTap: onRemove,
              child:
                  const Icon(Icons.close, size: 18, color: Color(0xFF5A5A7A)),
            ),
          ]),
          const Gap(10),
          TextFormField(
            controller: entry.nameCtrl,
            decoration: const InputDecoration(labelText: 'Назва *'),
            validator: (v) => v == null || v.isEmpty ? 'Введіть назву' : null,
          ),
          const Gap(8),
          TextFormField(
            controller: entry.descCtrl,
            decoration: const InputDecoration(labelText: 'Опис'),
          ),
          const Gap(8),
          Row(children: [
            Expanded(
              child: TextFormField(
                controller: entry.qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Кількість'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Вкажіть';
                  if (int.tryParse(v) == null) return 'Ціл.';
                  return null;
                },
              ),
            ),
            const Gap(8),
            Expanded(
              child: TextFormField(
                controller: entry.unitCtrl,
                decoration: const InputDecoration(labelText: 'Одиниці'),
              ),
            ),
            const Gap(8),
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: entry.priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Ціна за од.', suffixText: '₴'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Вкажіть';
                  if (double.tryParse(v) == null) return 'Число';
                  return null;
                },
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

class _ItemEntry {
  final String id;
  final TextEditingController nameCtrl;
  final TextEditingController descCtrl;
  final TextEditingController qtyCtrl;
  final TextEditingController priceCtrl;
  final TextEditingController unitCtrl;

  const _ItemEntry({
    required this.id,
    required this.nameCtrl,
    required this.descCtrl,
    required this.qtyCtrl,
    required this.priceCtrl,
    required this.unitCtrl,
  });
}
