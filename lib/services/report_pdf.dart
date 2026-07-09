import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../constants/zones.dart';
import '../models/assessment_result.dart';

/// Professional Wellbeing Assessment Report — A4 PDF matching the
/// approved report design: navy letterhead with the NeuralCalm(TM)
/// wordmark, zone-coloured score ring, clinical domain table,
/// flagged responses, score trend and disclaimer.
class ReportPdf {
  // Brand palette (same values as AppColors)
  static const _navy = PdfColor.fromInt(0xFF1E1148);
  static const _purple = PdfColor.fromInt(0xFF7E5CE6);
  static const _purpleLight = PdfColor.fromInt(0xFF9B7ED4);
  static const _purplePale = PdfColor.fromInt(0xFFE4DBF9);
  static const _lav = PdfColor.fromInt(0xFFF5F2FC);
  static const _border = PdfColor.fromInt(0xFFDFD6F4);
  static const _muted = PdfColor.fromInt(0xFF6B5F8A);
  static const _green = PdfColor.fromInt(0xFF16A34A);
  static const _greenPale = PdfColor.fromInt(0xFFDCFCE7);
  static const _amber = PdfColor.fromInt(0xFFD97706);
  static const _amberPale = PdfColor.fromInt(0xFFFEF3C7);
  static const _red = PdfColor.fromInt(0xFFDC2626);
  static const _redPale = PdfColor.fromInt(0xFFFEE2E2);
  static const _redDark = PdfColor.fromInt(0xFF991B1B);

  static PdfColor _zc(Zone z) => switch (z) {
        Zone.optimal => _green,
        Zone.moderate => _amber,
        Zone.elevated => _red,
      };
  static PdfColor _zPale(Zone z) => switch (z) {
        Zone.optimal => _greenPale,
        Zone.moderate => _amberPale,
        Zone.elevated => _redPale,
      };
  static PdfColor _zText(Zone z) => switch (z) {
        Zone.optimal => _green,
        Zone.moderate => _amber,
        Zone.elevated => _redDark,
      };
  static String _zoneRange(Zone z) => switch (z) {
        Zone.optimal => '0-35',
        Zone.moderate => '36-60',
        Zone.elevated => '61-100',
      };

  static String _fmtDate(DateTime d) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final ap = d.hour >= 12 ? 'PM' : 'AM';
    return '${d.day.toString().padLeft(2, '0')} ${m[d.month - 1]} ${d.year}, '
        '$h:${d.minute.toString().padLeft(2, '0')} $ap';
  }

  // Small-caps clinical section label
  static pw.Widget _sec(String t) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 14, bottom: 6),
        child: pw.Text(t.toUpperCase(),
            style: pw.TextStyle(
                fontSize: 8,
                letterSpacing: 1.2,
                fontWeight: pw.FontWeight.bold,
                color: _muted)),
      );

  // Zone pill chip (as in the app)
  static pw.Widget _zoneChip(Zone z) => pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
        decoration: pw.BoxDecoration(
            color: _zPale(z), borderRadius: pw.BorderRadius.circular(8)),
        child: pw.Text(z.label,
            style: pw.TextStyle(
                fontSize: 8, fontWeight: pw.FontWeight.bold, color: _zText(z))),
      );

  static pw.Widget _metaItem(String k, String v, {PdfColor? vColor}) =>
      pw.RichText(
          text: pw.TextSpan(children: [
        pw.TextSpan(
            text: '$k:  ',
            style: const pw.TextStyle(fontSize: 9, color: _muted)),
        pw.TextSpan(
            text: v,
            style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: vColor ?? _navy)),
      ]));

  static pw.Widget _cell(pw.Widget child,
          {pw.Alignment align = pw.Alignment.centerLeft}) =>
      pw.Container(
          alignment: align,
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: child);

  static pw.Widget _hCell(String t,
          {pw.Alignment align = pw.Alignment.centerLeft}) =>
      pw.Container(
          alignment: align,
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: pw.Text(t.toUpperCase(),
              style: pw.TextStyle(
                  fontSize: 7.5,
                  letterSpacing: 1,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white)));

  /// Build and open the native share sheet.
  /// [history] (oldest -> newest) draws the trend; pass what you have.
  static Future<void> share(AssessmentResult r,
      {required String clientName,
      String? email,
      List<AssessmentResult> history = const []}) async {
    final doc = pw.Document(
        title: 'NeuralCalm Wellbeing Assessment Report',
        author: 'NeuralCalm app');

    // Trend: last 5 including this one
    final trend = List<AssessmentResult>.from(history);
    if (trend.isEmpty || trend.last.takenAt != r.takenAt) trend.add(r);
    final last5 = trend.length > 5 ? trend.sublist(trend.length - 5) : trend;

    final domains = r.domainScores.entries.toList();
    const weights = <String, String>{
      'Stress': '1.2',
      'Anxiety': '1.2',
      'Sleep': '1.0',
      'Mood & Wellbeing': '1.3',
      'Overwhelm': '1.0',
      'Biometric Data': '0.8',
    };

    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(40, 36, 40, 30),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // ── LETTERHEAD ─────────────────────────────────────────
          pw.Container(
            width: double.infinity,
            decoration: pw.BoxDecoration(
                color: _navy, borderRadius: pw.BorderRadius.circular(8)),
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Row(children: [
                  // glyph: purple circle with white half-moon
                  pw.Container(
                    width: 22,
                    height: 22,
                    decoration: const pw.BoxDecoration(
                        color: _purple, shape: pw.BoxShape.circle),
                    alignment: pw.Alignment.center,
                    child: pw.Container(
                        width: 8,
                        height: 12,
                        margin: const pw.EdgeInsets.only(right: 6),
                        decoration: const pw.BoxDecoration(
                            color: PdfColors.white,
                            borderRadius: pw.BorderRadius.only(
                                topLeft: pw.Radius.circular(6),
                                bottomLeft: pw.Radius.circular(6)))),
                  ),
                  pw.SizedBox(width: 8),
                  pw.RichText(
                      text: pw.TextSpan(children: [
                    pw.TextSpan(
                        text: 'Neural',
                        style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 17,
                            fontWeight: pw.FontWeight.bold)),
                    pw.TextSpan(
                        text: 'Calm',
                        style: pw.TextStyle(
                            color: _purpleLight,
                            fontSize: 17,
                            fontWeight: pw.FontWeight.bold)),
                    const pw.TextSpan(
                        text: ' ™',
                        style: pw.TextStyle(
                            color: PdfColors.white, fontSize: 8)),
                  ])),
                ]),
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('WELLBEING ASSESSMENT REPORT',
                          style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 8.5,
                              letterSpacing: 1.4,
                              fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 2),
                      pw.Text('FOR HEALTH PROFESSIONAL REVIEW',
                          style: const pw.TextStyle(
                              color: PdfColor.fromInt(0xFFC0B4DC),
                              fontSize: 7,
                              letterSpacing: 1.2)),
                    ]),
              ],
            ),
          ),
          pw.SizedBox(height: 14),

          // ── META ───────────────────────────────────────────────
          pw.Row(children: [
            pw.Expanded(child: _metaItem('Client', clientName)),
            pw.Expanded(child: _metaItem('Date', _fmtDate(r.takenAt))),
          ]),
          pw.SizedBox(height: 4),
          pw.Row(children: [
            pw.Expanded(
                child: _metaItem(
                    'Assessment', '#${r.number} (self-reported)')),
            pw.Expanded(
                child: _metaItem('Overall zone', r.zone.label,
                    vColor: _zc(r.zone))),
          ]),
          if (email != null && email.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            _metaItem('Account', email),
          ],
          pw.SizedBox(height: 14),

          // ── SCORE RING + EXPLANATION ───────────────────────────
          pw.Container(
            width: double.infinity,
            decoration: pw.BoxDecoration(
                color: _lav,
                border: pw.Border.all(color: _border, width: .8),
                borderRadius: pw.BorderRadius.circular(10)),
            padding: const pw.EdgeInsets.all(14),
            child: pw.Row(children: [
              pw.Container(
                width: 96,
                height: 96,
                decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    shape: pw.BoxShape.circle,
                    border: pw.Border.all(color: _zc(r.zone), width: 7)),
                alignment: pw.Alignment.center,
                child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text('${r.overall}',
                          style: pw.TextStyle(
                              fontSize: 30,
                              fontWeight: pw.FontWeight.bold,
                              color: _navy)),
                      pw.Text('CALM SCORE',
                          style: const pw.TextStyle(
                              fontSize: 5.5,
                              letterSpacing: 1.6,
                              color: _purpleLight)),
                    ]),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                          '${r.zone.label.toUpperCase()} ZONE (${_zoneRange(r.zone)})',
                          style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: _zc(r.zone))),
                      pw.SizedBox(height: 5),
                      pw.Text(
                          'The Neural Calm Score is a weighted composite of six '
                          'wellbeing domains on a 0-100 scale, where a LOWER score '
                          'indicates a calmer state.',
                          style: const pw.TextStyle(
                              fontSize: 8.5, color: _muted, lineSpacing: 2)),
                      pw.SizedBox(height: 6),
                      pw.Row(children: [
                        _legendDot(_green, 'Optimal 0-35'),
                        pw.SizedBox(width: 12),
                        _legendDot(_amber, 'Moderate 36-60'),
                        pw.SizedBox(width: 12),
                        _legendDot(_red, 'Elevated 61-100'),
                      ]),
                    ]),
              ),
            ]),
          ),

          // ── DOMAIN TABLE ───────────────────────────────────────
          _sec('Domain results'),
          pw.Table(
            border: pw.TableBorder.all(color: _border, width: .6),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(1.6),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: _navy),
                children: [
                  _hCell('Domain'),
                  _hCell('Weight', align: pw.Alignment.center),
                  _hCell('Score', align: pw.Alignment.center),
                  _hCell('Zone', align: pw.Alignment.center),
                ],
              ),
              ...List.generate(domains.length, (i) {
                final e = domains[i];
                final z = zoneFor(e.value);
                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                      color: i.isOdd ? _lav : PdfColors.white),
                  children: [
                    _cell(pw.Text(e.key,
                        style: pw.TextStyle(
                            fontSize: 9, fontWeight: pw.FontWeight.bold))),
                    _cell(
                        pw.Text('x ${weights[e.key] ?? '1.0'}',
                            style: const pw.TextStyle(
                                fontSize: 8.5, color: _muted)),
                        align: pw.Alignment.center),
                    _cell(
                        pw.Text('${e.value}',
                            style: pw.TextStyle(
                                fontSize: 9.5,
                                fontWeight: pw.FontWeight.bold,
                                color: _zc(z))),
                        align: pw.Alignment.center),
                    _cell(_zoneChip(z), align: pw.Alignment.center),
                  ],
                );
              }),
            ],
          ),

          // ── FLAGS ──────────────────────────────────────────────
          _sec('Flagged responses'),
          if (r.flags.isEmpty)
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                  color: _greenPale,
                  borderRadius: pw.BorderRadius.circular(6)),
              child: pw.Text(
                  'No safeguarding flags were raised in this assessment.',
                  style: pw.TextStyle(
                      fontSize: 8.5,
                      color: _green,
                      fontWeight: pw.FontWeight.bold)),
            )
          else
            ...r.flags.map((f) => pw.Container(
                  width: double.infinity,
                  margin: const pw.EdgeInsets.only(bottom: 5),
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 9, vertical: 6),
                  decoration: const pw.BoxDecoration(
                    color: _redPale,
                    border: pw.Border(
                        left: pw.BorderSide(color: _red, width: 2.5)),
                    borderRadius: pw.BorderRadius.only(
                        topRight: pw.Radius.circular(6),
                        bottomRight: pw.Radius.circular(6)),
                  ),
                  child: pw.RichText(
                      text: pw.TextSpan(children: [
                    pw.TextSpan(
                        text: '${f.label}  -  ',
                        style: pw.TextStyle(
                            fontSize: 8.5,
                            fontWeight: pw.FontWeight.bold,
                            color: _redDark)),
                    pw.TextSpan(
                        text: '"${f.answerText}" (${f.value}/5)',
                        style: const pw.TextStyle(
                            fontSize: 8.5, color: _redDark)),
                  ])),
                )),

          // ── TREND ──────────────────────────────────────────────
          _sec('Score trend - last ${last5.length} assessment'
              '${last5.length == 1 ? '' : 's'}'),
          pw.Container(
            height: 64,
            padding: const pw.EdgeInsets.only(top: 12),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                for (int i = 0; i < last5.length; i++) ...[
                  pw.Expanded(
                    child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Text('${last5[i].overall}',
                              style: pw.TextStyle(
                                  fontSize: 7.5,
                                  color: _muted,
                                  fontWeight: i == last5.length - 1
                                      ? pw.FontWeight.bold
                                      : pw.FontWeight.normal)),
                          pw.SizedBox(height: 2),
                          pw.Container(
                            height:
                                (last5[i].overall.clamp(4, 100)) * 0.40,
                            decoration: pw.BoxDecoration(
                              color: i == last5.length - 1
                                  ? _purple
                                  : _purplePale,
                              borderRadius: const pw.BorderRadius.only(
                                  topLeft: pw.Radius.circular(3),
                                  topRight: pw.Radius.circular(3)),
                            ),
                          ),
                        ]),
                  ),
                  if (i != last5.length - 1) pw.SizedBox(width: 6),
                ],
              ],
            ),
          ),

          pw.Spacer(),

          // ── DISCLAIMER + FOOTER ───────────────────────────────
          pw.Divider(color: _border, thickness: .8),
          pw.Text(
            'This report presents self-reported responses to the NeuralCalm(TM) '
            'wellbeing questionnaire and derived scores. It is a wellness coaching '
            'instrument, not a clinical assessment, and does not constitute a medical '
            'diagnosis. Flagged items follow NeuralCalm safeguarding thresholds and '
            'are provided to support professional judgement.',
            style: const pw.TextStyle(
                fontSize: 7, color: _muted, lineSpacing: 2),
          ),
          pw.SizedBox(height: 6),
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Generated by the NeuralCalm app',
                    style: const pw.TextStyle(fontSize: 7, color: _muted)),
                pw.Text('neuralcalm.com',
                    style: pw.TextStyle(
                        fontSize: 7,
                        color: _purple,
                        fontWeight: pw.FontWeight.bold)),
              ]),
        ],
      ),
    ));

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename:
          'NeuralCalm-Report-${r.takenAt.toIso8601String().substring(0, 10)}.pdf',
    );
  }

  static pw.Widget _legendDot(PdfColor c, String t) => pw.Row(children: [
        pw.Container(
            width: 6,
            height: 6,
            decoration: pw.BoxDecoration(color: c, shape: pw.BoxShape.circle)),
        pw.SizedBox(width: 3),
        pw.Text(t, style: const pw.TextStyle(fontSize: 7, color: _muted)),
      ]);
}
