import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:scanner_red/models/device_model.dart';
import 'package:intl/intl.dart';

class PdfService {
  Future<void> generateRadarReport(List<DispositivoRed> devices) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(now);

    final logoImage = await imageFromAssetBundle('assets/images/logo.png');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            _buildHeader("NETWORK SCAN REPORT", dateStr, logoImage),
            pw.SizedBox(height: 20),
            _buildSummary(
              "Total Devices Found: ${devices.length}",
              "Scan completed successfully.",
            ),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: ['IP Address', 'Device Name', 'MAC Address', 'Vendor'],
              data: devices
                  .map((d) => [d.ip, d.nombre, d.mac, d.vendedor])
                  .toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              cellHeight: 30,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.center,
                3: pw.Alignment.centerLeft,
              },
            ),
            pw.SizedBox(height: 20),
            _buildFooter(),
          ];
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'network_scan_report.pdf',
    );
  }

  Future<void> generateAuditReport(
    String targetIp,
    List<int> openPorts,
    List<String> logs,
  ) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(now);

    final logoImage = await imageFromAssetBundle('assets/images/logo.png');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            _buildHeader("SECURITY AUDIT REPORT", dateStr, logoImage),
            pw.SizedBox(height: 20),
            _buildSummary(
              "Target: $targetIp",
              "Open Ports: ${openPorts.length}",
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              "Open Ports Details",
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Wrap(
              spacing: 10,
              children: openPorts
                  .map(
                    (p) => pw.Container(
                      padding: const pw.EdgeInsets.all(5),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.red),
                        borderRadius: pw.BorderRadius.circular(5),
                      ),
                      child: pw.Text(
                        "Port $p",
                        style: const pw.TextStyle(color: PdfColors.red),
                      ),
                    ),
                  )
                  .toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              "Scan Logs",
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.Divider(),
            ...logs.map(
              (log) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Text(
                  log,
                  style: pw.TextStyle(fontSize: 10, font: pw.Font.courier()),
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            _buildFooter(),
          ];
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'audit_report_$targetIp.pdf',
    );
  }

  pw.Widget _buildHeader(
    String title,
    String date,
    pw.ImageProvider? logoImage,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Row(
          children: [
            if (logoImage != null)
              pw.Container(
                width: 40,
                height: 40,
                margin: const pw.EdgeInsets.only(right: 10),
                child: pw.Image(logoImage),
              ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.Text(
                  "Generated by Scanner Red",
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ],
        ),
        pw.Text(date, style: const pw.TextStyle(fontSize: 12)),
      ],
    );
  }

  pw.Widget _buildSummary(String line1, String line2) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey400),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(line1, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(line2),
        ],
      ),
    );
  }

  pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.Center(
          child: pw.Text(
            "CONFIDENTIAL - FOR AUTHORIZED USE ONLY",
            style: const pw.TextStyle(color: PdfColors.grey, fontSize: 8),
          ),
        ),
      ],
    );
  }
}
