import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/app_settings.dart';
import '../providers/settings_provider.dart';
import '../services/update_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  // API keys
  late TextEditingController _novaPoshtaCtrl;
  late TextEditingController _ukrposhtaCtrl;

  // Document / sender
  late TextEditingController _senderNameCtrl;
  late TextEditingController _senderAddressCtrl;
  late TextEditingController _senderPhoneCtrl;
  late TextEditingController _senderIpnCtrl;
  late TextEditingController _footerCtrl;
  late TextEditingController _invoicePrefixCtrl;

  bool _checkingUpdate = false;
  String? _updateMsg;

  @override
  void initState() {
    super.initState();
    final s = context.read<SettingsProvider>().settings;
    _novaPoshtaCtrl = TextEditingController(text: s.novaPoshtaApiKey);
    _ukrposhtaCtrl = TextEditingController(text: s.ukrposhtaToken);
    _senderNameCtrl = TextEditingController(text: s.senderName);
    _senderAddressCtrl = TextEditingController(text: s.senderAddress);
    _senderPhoneCtrl = TextEditingController(text: s.senderPhone);
    _senderIpnCtrl = TextEditingController(text: s.senderIpn);
    _footerCtrl = TextEditingController(text: s.invoiceFooterText);
    _invoicePrefixCtrl = TextEditingController(text: s.invoicePrefix);
  }

  @override
  void dispose() {
    for (final c in [
      _novaPoshtaCtrl,
      _ukrposhtaCtrl,
      _senderNameCtrl,
      _senderAddressCtrl,
      _senderPhoneCtrl,
      _senderIpnCtrl,
      _footerCtrl,
      _invoicePrefixCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<SettingsProvider>().save(AppSettings(
          novaPoshtaApiKey: _novaPoshtaCtrl.text.trim(),
          ukrposhtaToken: _ukrposhtaCtrl.text.trim(),
          senderName: _senderNameCtrl.text.trim(),
          senderAddress: _senderAddressCtrl.text.trim(),
          senderPhone: _senderPhoneCtrl.text.trim(),
          senderIpn: _senderIpnCtrl.text.trim(),
          invoiceFooterText: _footerCtrl.text.trim(),
          invoicePrefix: _invoicePrefixCtrl.text.trim().isNotEmpty
              ? _invoicePrefixCtrl.text.trim()
              : 'РФ',
        ));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Налаштування збережено ✓')),
      );
    }
  }

  Future<void> _checkUpdate() async {
    setState(() {
      _checkingUpdate = true;
      _updateMsg = null;
    });
    final info = await UpdateService.check();
    if (!mounted) return;
    setState(() {
      _checkingUpdate = false;
    });

    if (info == null) {
      setState(() {
        _updateMsg = 'Не вдалося перевірити оновлення.';
      });
      return;
    }
    if (!info.hasUpdate) {
      setState(() {
        _updateMsg = 'У вас найновіша версія (${info.currentVersion}).';
      });
      return;
    }

    // Show update dialog
    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Доступне оновлення 🎉'),
          content: Text('Ваша версія: ${info.currentVersion}\n'
              'Нова версія: ${info.latestVersion}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Пізніше'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final url = Uri.parse(info.downloadUrl ?? info.releaseUrl);
                if (await canLaunchUrl(url)) launchUrl(url);
              },
              child: const Text('Завантажити'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Налаштування'),
        actions: [
          TextButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('Зберегти'),
          ),
          const Gap(8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Document Templates ────────────────────────────────
            _SectionHeader(
              icon: Icons.description_outlined,
              title: 'Шаблони документів',
              subtitle: 'Реквізити для рахунків на оплату',
            ),
            const Gap(12),
            _Field(
              ctrl: _senderNameCtrl,
              label: 'Назва організації / ФОП',
              icon: Icons.business_outlined,
            ),
            const Gap(10),
            _Field(
              ctrl: _senderAddressCtrl,
              label: 'Адреса',
              icon: Icons.location_on_outlined,
            ),
            const Gap(10),
            _Field(
              ctrl: _senderPhoneCtrl,
              label: 'Телефон',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const Gap(10),
            _Field(
              ctrl: _senderIpnCtrl,
              label: 'ІПН / ЄДРПОУ',
              icon: Icons.badge_outlined,
              keyboardType: TextInputType.number,
            ),
            const Gap(10),
            _Field(
              ctrl: _invoicePrefixCtrl,
              label: 'Префікс рахунку (наприклад РФ)',
              icon: Icons.tag_outlined,
            ),
            const Gap(10),
            TextFormField(
              controller: _footerCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Підвал рахунку (банківські реквізити тощо)',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.notes_outlined),
                ),
              ),
            ),

            const Gap(24),
            const Divider(),
            const Gap(12),

            // ── API Integrations ──────────────────────────────────
            _SectionHeader(
              icon: Icons.api_outlined,
              title: 'API інтеграції',
              subtitle: 'Ключі служб доставки',
            ),
            const Gap(12),
            _Field(
              ctrl: _novaPoshtaCtrl,
              label: 'Nova Poshta API ключ',
              icon: Icons.local_shipping_outlined,
              obscure: true,
              hint: 'Отримайте на my.novaposhta.ua',
            ),
            const Gap(10),
            _Field(
              ctrl: _ukrposhtaCtrl,
              label: 'Укрпошта Bearer токен',
              icon: Icons.local_post_office_outlined,
              obscure: true,
              hint: 'cabinet.ukrposhta.ua → API',
            ),

            const Gap(24),
            const Divider(),
            const Gap(12),

            // ── Update Checker ────────────────────────────────────
            _SectionHeader(
              icon: Icons.system_update_outlined,
              title: 'Оновлення',
              subtitle: 'Перевірка нової версії через GitHub Releases',
            ),
            const Gap(12),
            if (_updateMsg != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  _updateMsg!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 13,
                  ),
                ),
              ),
            ElevatedButton.icon(
              onPressed: _checkingUpdate ? null : _checkUpdate,
              icon: _checkingUpdate
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.refresh_outlined, size: 18),
              label: Text(
                  _checkingUpdate ? 'Перевіряємо...' : 'Перевірити оновлення'),
            ),

            const Gap(80),
          ],
        ),
      ),
    );
  }
}

// ── Reusable widgets ─────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child:
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
      ),
      const Gap(12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      ]),
    ]);
  }
}

class _Field extends StatefulWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final bool obscure;
  final String? hint;
  final TextInputType? keyboardType;

  const _Field({
    required this.ctrl,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.hint,
    this.keyboardType,
  });

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.ctrl,
      obscureText: widget.obscure && !_visible,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: Icon(widget.icon),
        suffixIcon: widget.obscure
            ? IconButton(
                icon: Icon(_visible ? Icons.visibility_off : Icons.visibility,
                    size: 18),
                onPressed: () => setState(() => _visible = !_visible),
              )
            : null,
      ),
    );
  }
}
