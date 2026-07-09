import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/zones.dart';
import '../../models/assessment_result.dart';
import '../../providers/app_state.dart';
import '../../services/report_pdf.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/score_ring.dart';
import '../../widgets/trend_bars.dart';
import '../../widgets/wordmark.dart';

String _fmtDate(DateTime d) {
  const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  return '${d.day.toString().padLeft(2, '0')} ${m[d.month - 1]} ${d.year}';
}

/// The Professional Report — opens directly when an assessment is
/// completed, and for any past assessment. Shareable as PDF.
class ReportScreen extends StatelessWidget {
  final AssessmentResult result;
  final bool isNew;
  const ReportScreen({super.key, required this.result, this.isNew = false});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final trend = state.history
        .where((r) => !r.takenAt.isAfter(result.takenAt))
        .map((r) => r.overall)
        .toList();
    final lastFive =
        trend.length > 5 ? trend.sublist(trend.length - 5) : trend;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Professional report'),
        automaticallyImplyLeading: !isNew,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(_fmtDate(result.takenAt),
                  style:
                      const TextStyle(color: AppColors.onNavy, fontSize: 12)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── the document ──
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // letterhead
                  Container(
                    color: AppColors.navy,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Wordmark(fontSize: 15),
                        Text(
                          'WELLBEING ASSESSMENT REPORT\nFOR HEALTH PROFESSIONAL REVIEW',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontSize: 7.5,
                              height: 1.5,
                              letterSpacing: .5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onNavy),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _metaGrid(state),
                          const SizedBox(height: 12),
                          Center(
                              child:
                                  ScoreRing(score: result.overall, size: 118)),
                          const SizedBox(height: 8),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: result.zone.paleColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${result.zone.label.toUpperCase()} ZONE (${_zoneRange(result.zone)})',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: result.zone.textColor),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Center(
                            child: Text(
                              'Lower = calmer · Optimal 0–35 · Moderate 36–60 · Elevated 61–100',
                              style: TextStyle(
                                  fontSize: 9.5, color: AppColors.muted),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text('DOMAIN RESULTS', style: secLabel()),
                          const SizedBox(height: 6),
                          _domainTable(),
                          const SizedBox(height: 12),
                          Text('FLAGGED RESPONSES', style: secLabel()),
                          const SizedBox(height: 6),
                          if (result.flags.isEmpty)
                            const Text('None.',
                                style: TextStyle(
                                    fontSize: 12, color: AppColors.muted))
                          else
                            ...result.flags.map(_flagLine),
                          if (lastFive.length >= 2) ...[
                            const SizedBox(height: 12),
                            Text(
                                'SCORE TREND — LAST ${lastFive.length} ASSESSMENTS',
                                style: secLabel()),
                            const SizedBox(height: 6),
                            TrendBars(scores: lastFive),
                          ],
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 8),
                          const Text(
                            'This report presents self-reported responses to the NeuralCalm™ wellbeing questionnaire and derived scores. It is a wellness coaching instrument, not a clinical assessment, and does not constitute a medical diagnosis. Flagged items follow NeuralCalm safeguarding thresholds and are provided to support professional judgement. Generated by the NeuralCalm app.',
                            style: TextStyle(
                                fontSize: 8.5,
                                height: 1.5,
                                color: AppColors.muted),
                          ),
                        ]),
                  ),
                ]),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'Share as PDF',
            onPressed: () async {
              try {
                await ReportPdf.share(result,
                    clientName: state.name ?? 'NeuralCalm user',
                    email: state.email);
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content:
                          Text('Could not create the PDF — please try again.')));
                }
              }
            },
          ),
          PrimaryButton(
            label: 'Done',
            ghost: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  String _zoneRange(Zone z) => switch (z) {
        Zone.optimal => '0–35',
        Zone.moderate => '36–60',
        Zone.elevated => '61–100',
      };

  Widget _metaGrid(AppState state) {
    TextStyle k = const TextStyle(fontSize: 11, color: AppColors.muted);
    TextStyle v =
        const TextStyle(fontSize: 11, fontWeight: FontWeight.w600);
    return Column(children: [
      Row(children: [
        Expanded(
            child: Text.rich(TextSpan(children: [
          TextSpan(text: 'Client:  ', style: k),
          TextSpan(text: state.name ?? '—', style: v),
        ]))),
        Expanded(
            child: Text.rich(TextSpan(children: [
          TextSpan(text: 'Date:  ', style: k),
          TextSpan(text: _fmtDate(result.takenAt), style: v),
        ]))),
      ]),
      const SizedBox(height: 3),
      Row(children: [
        Expanded(
            child: Text.rich(TextSpan(children: [
          TextSpan(text: 'Assessment:  ', style: k),
          TextSpan(text: '#${result.number} (self-reported)', style: v),
        ]))),
        Expanded(
            child: Text.rich(TextSpan(children: [
          TextSpan(text: 'Zone:  ', style: k),
          TextSpan(
              text: result.zone.label,
              style: v.copyWith(color: result.zone.textColor)),
        ]))),
      ]),
    ]);
  }

  Widget _domainTable() {
    return Column(children: [
      for (final e in result.domainScores.entries)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: const BoxDecoration(
            border:
                Border(bottom: BorderSide(color: Color(0xFFF3F0FB))),
          ),
          child: Row(children: [
            Expanded(
                flex: 5,
                child: Text(e.key,
                    style: const TextStyle(fontSize: 12))),
            Expanded(
                flex: 2,
                child: Text('${e.value}',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700))),
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: zoneFor(e.value).paleColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(zoneFor(e.value).label,
                      style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: zoneFor(e.value).textColor)),
                ),
              ),
            ),
          ]),
        ),
    ]);
  }

  Widget _flagLine(Flag f) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: const BoxDecoration(
        color: AppColors.redPale,
        border: Border(left: BorderSide(color: AppColors.red, width: 3)),
        borderRadius: BorderRadius.horizontal(right: Radius.circular(8)),
      ),
      child: Text.rich(TextSpan(children: [
        TextSpan(
            text: '${f.label} — ',
            style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.redDark)),
        TextSpan(
            text: '"${f.answerText}" (${f.value}/5)',
            style: const TextStyle(
                fontSize: 11.5, color: AppColors.redDark)),
      ])),
    );
  }
}
