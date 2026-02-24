import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../models/client.dart';
import '../providers/client_provider.dart';

class ClientFormScreen extends StatefulWidget {
  final Client? client;
  const ClientFormScreen({super.key, this.client});

  @override
  State<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends State<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _companyCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _telegramCtrl;
  late final TextEditingController _viberCtrl;
  late final TextEditingController _instagramCtrl;

  bool get isEditing => widget.client != null;

  @override
  void initState() {
    super.initState();
    final c = widget.client;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _phoneCtrl = TextEditingController(text: c?.phone ?? '');
    _emailCtrl = TextEditingController(text: c?.email ?? '');
    _companyCtrl = TextEditingController(text: c?.company ?? '');
    _addressCtrl = TextEditingController(text: c?.address ?? '');
    _notesCtrl = TextEditingController(text: c?.notes ?? '');
    _telegramCtrl = TextEditingController(text: c?.telegram ?? '');
    _viberCtrl = TextEditingController(text: c?.viber ?? '');
    _instagramCtrl = TextEditingController(text: c?.instagram ?? '');
  }

  @override
  void dispose() {
    for (final ctrl in [
      _nameCtrl,
      _phoneCtrl,
      _emailCtrl,
      _companyCtrl,
      _addressCtrl,
      _notesCtrl,
      _telegramCtrl,
      _viberCtrl,
      _instagramCtrl,
    ]) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<ClientProvider>();

    String? tg =
        _telegramCtrl.text.trim().isEmpty ? null : _telegramCtrl.text.trim();
    String? vb = _viberCtrl.text.trim().isEmpty ? null : _viberCtrl.text.trim();
    String? ig =
        _instagramCtrl.text.trim().isEmpty ? null : _instagramCtrl.text.trim();

    if (isEditing) {
      await provider.updateClient(widget.client!.copyWith(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        company: _companyCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        telegram: tg,
        viber: vb,
        instagram: ig,
      ));
    } else {
      await provider.addClient(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        company: _companyCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        telegram: tg,
        viber: vb,
        instagram: ig,
      );
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Редагувати клієнта' : 'Новий клієнт'),
        actions: [
          TextButton(onPressed: _submit, child: const Text('Зберегти')),
          const Gap(8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _field(_nameCtrl, 'Ім\'я *', Icons.person_outline, required: true),
            const Gap(12),
            _field(_companyCtrl, 'Компанія', Icons.business_outlined),
            const Gap(12),
            _field(_phoneCtrl, 'Телефон', Icons.phone_outlined,
                keyboardType: TextInputType.phone),
            const Gap(12),
            _field(_emailCtrl, 'Email', Icons.email_outlined,
                keyboardType: TextInputType.emailAddress),
            const Gap(12),
            _field(_addressCtrl, 'Адреса', Icons.location_on_outlined),
            const Gap(20),
            const Text('Месенджери',
                style: TextStyle(
                    color: Color(0xFF7878A0),
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
            const Gap(8),
            _field(
                _telegramCtrl, 'Telegram (username або номер)', Icons.telegram,
                hint: 'username або +380XXXXXXXXX'),
            const Gap(12),
            _field(_viberCtrl, 'Viber (номер телефону)',
                Icons.phone_in_talk_outlined,
                hint: '+380XXXXXXXXX', keyboardType: TextInputType.phone),
            const Gap(12),
            _field(_instagramCtrl, 'Instagram (username)',
                Icons.camera_alt_outlined,
                hint: 'username'),
            const Gap(20),
            const Text('Примітки',
                style: TextStyle(
                    color: Color(0xFF7878A0),
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
            const Gap(8),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 4,
              decoration:
                  const InputDecoration(hintText: 'Нотатки про клієнта…'),
            ),
            const Gap(80),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool required = false,
    TextInputType? keyboardType,
    String? hint,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
      ),
      validator: required
          ? (v) => v == null || v.trim().isEmpty ? 'Обов\'язкове поле' : null
          : null,
    );
  }
}
