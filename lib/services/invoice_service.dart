import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/app_settings.dart';
import '../models/client.dart';
import '../models/order.dart';

class InvoiceService {
  /// Generates and shows a PDF invoice for the given order.
  static Future<void> showInvoice({
    required Order order,
    Client? client,
    required AppSettings settings,
  }) async {
    final bytes = await _buildPdf(order, client, settings);
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: 'Рахунок_${order.number}.pdf',
    );
  }

  static Future<Uint8List> _buildPdf(
    Order order,
    Client? client,
    AppSettings settings,
  ) async {
    final doc = pw.Document();
    final currency =
        NumberFormat.currency(locale: 'uk_UA', symbol: '₴', decimalDigits: 2);
    final dateFmt = DateFormat('dd.MM.yyyy');

    // Colour palette
    const primary = PdfColor.fromInt(0xFF6C63FF);
    const textMuted = PdfColor.fromInt(0xFF555566);
    const borderColor = PdfColor.fromInt(0xFFDDDDEE);

    final invoiceNumber =
        '${settings.invoicePrefix}-${order.number.replaceAll('ORD-', '')}';

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 40),
        build: (context) => [
          // ── Header ──────────────────────────────────────
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    settings.senderName.isNotEmpty
                        ? settings.senderName
                        : 'PrintFlow',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: primary,
                    ),
                  ),
                  if (settings.senderAddress.isNotEmpty)
                    pw.Text(settings.senderAddress,
                        style:
                            const pw.TextStyle(fontSize: 9, color: textMuted)),
                  if (settings.senderPhone.isNotEmpty)
                    pw.Text(settings.senderPhone,
                        style:
                            const pw.TextStyle(fontSize: 9, color: textMuted)),
                  if (settings.senderIpn.isNotEmpty)
                    pw.Text('ІПН: ${settings.senderIpn}',
                        style:
                            const pw.TextStyle(fontSize: 9, color: textMuted)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'РАХУНОК НА ОПЛАТУ',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(invoiceNumber,
                      style: pw.TextStyle(
                          fontSize: 13,
                          color: primary,
                          fontWeight: pw.FontWeight.bold)),
                  pw.Text('Дата: ${dateFmt.format(order.createdAt)}',
                      style: const pw.TextStyle(fontSize: 9, color: textMuted)),
                  if (order.deadline != null)
                    pw.Text('Термін оплати: ${dateFmt.format(order.deadline!)}',
                        style:
                            const pw.TextStyle(fontSize: 9, color: textMuted)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Divider(color: borderColor),
          pw.SizedBox(height: 12),

          // ── Client info ──────────────────────────────
          pw.Text('Платник:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(
            client != null
                ? '${client.name}${client.company.isNotEmpty ? ' (${client.company})' : ''}'
                : order.clientName,
            style: const pw.TextStyle(fontSize: 11),
          ),
          if (client != null && client.address.isNotEmpty)
            pw.Text(client.address,
                style: const pw.TextStyle(fontSize: 10, color: textMuted)),
          if (client != null && client.phone.isNotEmpty)
            pw.Text(client.phone,
                style: const pw.TextStyle(fontSize: 10, color: textMuted)),
          pw.SizedBox(height: 16),

          // ── Items table ─────────────────────────────
          pw.Table(
            border: pw.TableBorder.all(color: borderColor, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(4),
              1: const pw.FixedColumnWidth(50),
              2: const pw.FixedColumnWidth(60),
              3: const pw.FixedColumnWidth(30),
              4: const pw.FixedColumnWidth(75),
            },
            children: [
              // Header row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: primary),
                children: [
                  _cell('Найменування', isHeader: true),
                  _cell('К-ть', isHeader: true),
                  _cell('Ціна', isHeader: true),
                  _cell('Од.', isHeader: true),
                  _cell('Сума', isHeader: true),
                ],
              ),
              // Data rows
              for (final item in order.items)
                pw.TableRow(children: [
                  _cell(item.name),
                  _cell('${item.quantity}'),
                  _cell(currency.format(item.unitPrice)),
                  _cell(item.unit ?? 'шт'),
                  _cell(currency.format(item.totalPrice)),
                ]),
            ],
          ),
          pw.SizedBox(height: 8),

          // ── Totals ──────────────────────────────────
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Container(
              width: 220,
              child: pw.Column(children: [
                _totalRow('Підсумок:', currency.format(order.subtotal)),
                if (order.discount != null && order.discount! > 0)
                  _totalRow(
                    'Знижка ${order.discount!.toStringAsFixed(0)}%:',
                    '- ${currency.format(order.discountAmount)}',
                  ),
                pw.Divider(color: borderColor),
                _totalRow(
                  'До сплати:',
                  currency.format(order.total),
                  isBold: true,
                  color: primary,
                ),
              ]),
            ),
          ),
          pw.SizedBox(height: 24),

          // ── Payment method ───────────────────────────
          if (order.paymentMethod != null && order.paymentMethod!.isNotEmpty)
            pw.Text('Спосіб оплати: ${order.paymentMethod!}',
                style: const pw.TextStyle(fontSize: 10, color: textMuted)),

          // ── Footer ──────────────────────────────────
          if (settings.invoiceFooterText.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Divider(color: borderColor),
            pw.SizedBox(height: 6),
            pw.Text(settings.invoiceFooterText,
                style: const pw.TextStyle(fontSize: 9, color: textMuted)),
          ],
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _cell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 9 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : null,
          color: isHeader ? PdfColors.white : null,
        ),
      ),
    );
  }

  static pw.Widget _totalRow(String label, String value,
      {bool isBold = false, PdfColor? color}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label,
            style: pw.TextStyle(
                fontSize: 10,
                fontWeight: isBold ? pw.FontWeight.bold : null,
                color: color)),
        pw.Text(value,
            style: pw.TextStyle(
                fontSize: 10,
                fontWeight: isBold ? pw.FontWeight.bold : null,
                color: color)),
      ],
    );
  }
}
