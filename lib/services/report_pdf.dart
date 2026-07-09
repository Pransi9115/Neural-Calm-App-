import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../constants/zones.dart';
import '../models/assessment_result.dart';

/// Builds the professional report as a shareable PDF.
class ReportPdf {
  static const _navy = PdfColor.fromInt(0xFF1E1148);
  static const _purple = PdfColor.fromInt(0xFF7E5CE6);
  static const _muted = PdfColor.fromInt(0xFF6B5F8A);

  static PdfColor _zoneColor(Zone z) => switch (z) {
        Zone.optimal => const PdfColor.fromInt(0xFF16A34A),
        Zone.moderate => const PdfColor.fromInt(0xFFD97706),
        Zone.elevated => const PdfColor.fromInt(0xFFDC2626),
      };

  static String _fmtDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day.toString().padLeft(2, '0')} ${m[d.month - 1]} ${d.year}';
  }

  static Future<void> share(AssessmentResult r,
      {required String clientName, String? email}) async {
    final doc = pw.Document();
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: double.infinity,
            color: _navy,
            padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.RichText(
                  text: pw.TextSpan(children: [
                    pw.TextSpan(
                        text: 'Neural',
                        style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold)),
                    pw.TextSpan(
                        text: 'Calm',
                        style: pw.TextStyle(
                            color: const PdfColor.fromInt(0xFF9B7ED4),
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold)),
                    pw.TextSpan(
                        text: ' (TM)',
                        style: const pw.TextStyle(
                            color: PdfColors.white, fontSize: 8)),
                  ]),
                ),
                pw.Text(
                  'WELLBEING ASSESSMENT REPORT\nFOR HEALTH PROFESSIONAL REVIEW',
                  textAlign: pw.TextAlign.right,
                  style: const pw.TextStyle(
                      color: PdfColor.fromInt(0xFFC0B4DC), fontSize: 7),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 14),
          pw.Row(children: [
            pw.Expanded(child: pw.Text('Client:  $clientName', style: const pw.TextStyle(fontSize: 10))),
            pw.Expanded(child: pw.Text('Date:  ${_fmtDate(r.takenAt)}', style: const pw.TextStyle(fontSize: 10))),
          ]),
          pw.SizedBox(height: 3),
          pw.Row(children: [
            pw.Expanded(child: pw.Text('Assessment:  #${r.number} (self-reported)', style: const pw.TextStyle(fontSize: 10))),
            pw.Expanded(child: pw.Text(email == null ? '' : 'Account:  $email', style: const pw.TextStyle(fontSize: 10))),
          ]),
          pw.SizedBox(height: 14),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: _zoneColor(r.zone)),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(children: [
              pw.Text('${r.overall}',
                  style: pw.TextStyle(
                      fontSize: 34,
                      fontWeight: pw.FontWeight.bold,
                      color: _zoneColor(r.zone))),
              pw.SizedBox(width: 14),
              pw.Expanded(
                child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('${r.zone.label.toUpperCase()} ZONE',
                          style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: _zoneColor(r.zone))),
                      pw.Text(
                        'Neural Calm Score — weighted composite of 6 domains, 0-100; '
                        'lower indicates a calmer state. Optimal 0-35 · Moderate 36-60 · Elevated 61-100.',
                        style: const pw.TextStyle(fontSize: 8, color: _muted),
                      ),
                    ]),
              ),
            ]),
          ),
          pw.SizedBox(height: 14),
          pw.Text('DOMAIN RESULTS',
              style: pw.TextStyle(
                  fontSize: 9, fontWeight: pw.FontWeight.bold, color: _muted)),
          pw.SizedBox(height: 5),
          pw.TableHelper.fromTextArray(
            headers: ['Domain', 'Score', 'Zone'],
            data: r.domainScores.entries
                .map((e) => [e.key, '${e.value}', zoneFor(e.value).label])
                .toList(),
            headerStyle:
                pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
            cellStyle: const pw.TextStyle(fontSize: 9),
            border: null,
            headerDecoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: _muted, width: .5))),
            cellPadding:
                const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 2),
          ),
          pw.SizedBox(height: 12),
          pw.Text('FLAGGED RESPONSES',
              style: pw.TextStyle(
                  fontSize: 9, fontWeight: pw.FontWeight.bold, color: _muted)),
          pw.SizedBox(height: 5),
          if (r.flags.isEmpty)
            pw.Text('None.', style: const pw.TextStyle(fontSize: 9))
          else
            ...r.flags.map((f) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 3),
                  child: pw.Text(
                      '- ${f.label} — "${f.answerText}" (${f.value}/5)',
                      style: const pw.TextStyle(fontSize: 9)),
                )),
          pw.Spacer(),
          pw.Divider(color: _muted, thickness: .5),
          pw.Text(
            'This report presents self-reported responses to the NeuralCalm (TM) wellbeing '
            'questionnaire and derived scores. It is a wellness coaching instrument, not a '
            'clinical assessment, and does not constitute a medical diagnosis. Flagged items '
            'follow NeuralCalm safeguarding thresholds and are provided to support '
            'professional judgement. Generated by the NeuralCalm app.',
            style: const pw.TextStyle(fontSize: 7, color: _muted),
          ),
        ],
      ),
    ));
    await Printing.sharePdf(
        bytes: await doc.save(),
        filename:
            'neuralcalm-report-${r.takenAt.toIso8601String().substring(0, 10)}.pdf');
  }
}
