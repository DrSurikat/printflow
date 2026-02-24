import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/app_settings.dart';
import '../models/client.dart';
import '../models/order.dart';

class InvoiceService {
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
    // ── Load Cyrillic-compatible fonts from Google Fonts ──────────────
    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();
    final fontMedium = await PdfGoogleFonts.robotoMedium();
    final fontItalic = await PdfGoogleFonts.robotoItalic();

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(
        base: fontRegular,
        bold: fontBold,
        italic: fontItalic,
        boldItalic: fontItalic,
      ),
    );

    final currency =
        NumberFormat.currency(locale: 'uk_UA', symbol: '₴', decimalDigits: 2);
    final dateFmt = DateFormat('dd.MM.yyyy');

    const primary = PdfColor.fromInt(0xFF6C63FF);
    const textMuted = PdfColor.fromInt(0xFF666677);
    const borderColor = PdfColor.fromInt(0xFFDDDDEE);

    final invoiceNumber =
        '${settings.invoicePrefix}-${order.number.replaceAll('ORD-', '')}';

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 40),
        build: (context) => [
          // ── Header ────────────────────────────────────────────────────
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Sender info (left)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    settings.senderName.isNotEmpty
                        ? settings.senderName
                        : 'PrintFlow',
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 20,
                      color: primary,
                    ),
                  ),
                  if (settings.senderAddress.isNotEmpty)
                    pw.Text(settings.senderAddress,
                        style: pw.TextStyle(
                            font: fontRegular, fontSize: 9, color: textMuted)),
                  if (settings.senderPhone.isNotEmpty)
                    pw.Text(settings.senderPhone,
                        style: pw.TextStyle(
                            font: fontRegular, fontSize: 9, color: textMuted)),
                  if (settings.senderIpn.isNotEmpty)
                    pw.Text('ІПН: ${settings.senderIpn}',
                        style: pw.TextStyle(
                            font: fontRegular, fontSize: 9, color: textMuted)),
                ],
              ),
              // Invoice title (right)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'РАХУНОК НА ОПЛАТУ',
                    style: pw.TextStyle(font: fontBold, fontSize: 16),
                  ),
                  pw.Text(invoiceNumber,
                      style: pw.TextStyle(
                          font: fontBold, fontSize: 13, color: primary)),
                  pw.Text('Дата: ${dateFmt.format(order.createdAt)}',
                      style: pw.TextStyle(
                          font: fontRegular, fontSize: 9, color: textMuted)),
                  if (order.deadline != null)
                    pw.Text('Термін оплати: ${dateFmt.format(order.deadline!)}',
                        style: pw.TextStyle(
                            font: fontRegular, fontSize: 9, color: textMuted)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Divider(color: borderColor),
          pw.SizedBox(height: 12),

          // ── Client ────────────────────────────────────────────────────
          pw.Text('Платник:',
              style: pw.TextStyle(font: fontBold, fontSize: 11)),
          pw.SizedBox(height: 4),
          pw.Text(
            client != null
                ? '${client.name}'
                    '${client.company.isNotEmpty ? ' (${client.company})' : ''}'
                : order.clientName,
            style: pw.TextStyle(font: fontMedium, fontSize: 11),
          ),
          if (client != null && client.address.isNotEmpty)
            pw.Text(client.address,
                style: pw.TextStyle(
                    font: fontRegular, fontSize: 10, color: textMuted)),
          if (client != null && client.phone.isNotEmpty)
            pw.Text(client.phone,
                style: pw.TextStyle(
                    font: fontRegular, fontSize: 10, color: textMuted)),
          pw.SizedBox(height: 16),

          // ── Items table ───────────────────────────────────────────────
          pw.Table(
            border: pw.TableBorder.all(color: borderColor, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(4),
              1: const pw.FixedColumnWidth(50),
              2: const pw.FixedColumnWidth(70),
              3: const pw.FixedColumnWidth(30),
              4: const pw.FixedColumnWidth(80),
            },
            children: [
              // Header row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: primary),
                children: [
                  _cell('Найменування', font: fontBold, isHeader: true),
                  _cell('К-ть', font: fontBold, isHeader: true),
                  _cell('Ціна', font: fontBold, isHeader: true),
                  _cell('Од.', font: fontBold, isHeader: true),
                  _cell('Сума', font: fontBold, isHeader: true),
                ],
              ),
              // Data rows
              for (final item in order.items)
                pw.TableRow(children: [
                  _cell(item.name, font: fontRegular),
                  _cell('${item.quantity}', font: fontRegular),
                  _cell(currency.format(item.unitPrice), font: fontRegular),
                  _cell(item.unit ?? 'шт', font: fontRegular),
                  _cell(currency.format(item.totalPrice), font: fontMedium),
                ]),
            ],
          ),
          pw.SizedBox(height: 8),

          // ── Totals ────────────────────────────────────────────────────
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.SizedBox(
              width: 240,
              child: pw.Column(children: [
                _totalRow('Підсумок:', currency.format(order.subtotal),
                    regular: fontRegular, bold: fontBold),
                if (order.discount != null && order.discount! > 0)
                  _totalRow(
                    'Знижка ${order.discount!.toStringAsFixed(0)}%:',
                    '- ${currency.format(order.discountAmount)}',
                    regular: fontRegular,
                    bold: fontBold,
                  ),
                pw.Divider(color: borderColor),
                _totalRow(
                  'До сплати:',
                  currency.format(order.total),
                  regular: fontBold,
                  bold: fontBold,
                  isBold: true,
                  color: primary,
                ),
              ]),
            ),
          ),
          pw.SizedBox(height: 16),

          // ── Payment method ────────────────────────────────────────────
          if (order.paymentMethod != null && order.paymentMethod!.isNotEmpty)
            pw.Text('Спосіб оплати: ${order.paymentMethod!}',
                style: pw.TextStyle(
                    font: fontRegular, fontSize: 10, color: textMuted)),

          // ── Footer ────────────────────────────────────────────────────
          if (settings.invoiceFooterText.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Divider(color: borderColor),
            pw.SizedBox(height: 6),
            pw.Text(settings.invoiceFooterText,
                style: pw.TextStyle(
                    font: fontRegular, fontSize: 9, color: textMuted)),
          ],
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _cell(
    String text, {
    required pw.Font font,
    bool isHeader = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: isHeader ? 9 : 10,
          color: isHeader ? PdfColors.white : null,
        ),
      ),
    );
  }

  static pw.Widget _totalRow(
    String label,
    String value, {
    required pw.Font regular,
    required pw.Font bold,
    bool isBold = false,
    PdfColor? color,
  }) {
    final font = isBold ? bold : regular;
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label,
            style: pw.TextStyle(font: font, fontSize: 10, color: color)),
        pw.Text(value,
            style: pw.TextStyle(font: font, fontSize: 10, color: color)),
      ],
    );
  }
}
