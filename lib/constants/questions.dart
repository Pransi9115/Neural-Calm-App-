import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// ─────────────────────────────────────────────────────────────
/// EDIT THIS FILE when the final NeuralCalm question set is
/// approved. Add/remove questions or whole sections here —
/// scoring, progress, and the UI all adapt automatically.
/// ─────────────────────────────────────────────────────────────

class Question {
  final String id;
  final String text;

  /// reverse = a "positive" item: answering Always is GOOD.
  /// The scoring engine flips it (4 - value) before totalling.
  final bool reverse;

  const Question(this.id, this.text, {this.reverse = false});
}

class Section {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Question> questions;

  const Section({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.questions,
  });
}

/// Answer scale shown as pills. Index 0..4 is the stored value.
const answerLabels = ['Never', 'Rarely', 'Sometimes', 'Often', 'Always'];

const sections = <Section>[
  Section(
    id: 'stress',
    title: 'Stress',
    subtitle: 'Over the last two weeks…',
    icon: LucideIcons.activity,
    questions: [
      Question('s1', 'I feel tense or on edge'),
      Question('s2', 'Small problems feel harder to handle than they should'),
      Question('s3',
          'I notice physical signs of stress (tight shoulders, headaches, jaw)'),
      Question('s4', 'I find it hard to switch off after work or study'),
    ],
  ),
  Section(
    id: 'anxiety',
    title: 'Anxiety',
    subtitle: 'Over the last two weeks…',
    icon: LucideIcons.brain,
    questions: [
      Question('a1', 'I worry about things even when everything is fine'),
      Question('a2', 'My thoughts race and are hard to slow down'),
      Question('a3', 'I avoid situations because they make me anxious'),
      Question('a4', "I feel restless, like I can't sit still"),
    ],
  ),
  Section(
    id: 'sleep',
    title: 'Sleep',
    subtitle: 'Thinking about a typical night…',
    icon: LucideIcons.moon,
    questions: [
      Question('sl1', 'I fall asleep within 20 minutes of going to bed',
          reverse: true),
      Question('sl2',
          'I wake up during the night and struggle to fall back asleep'),
      Question('sl3', 'I wake up feeling rested', reverse: true),
      Question('sl4', 'I use my phone in bed right before sleeping'),
    ],
  ),
  Section(
    id: 'mood',
    title: 'Mood & Wellbeing',
    subtitle: 'Over the last two weeks…',
    icon: LucideIcons.smile,
    questions: [
      Question('m1', 'I feel positive about my day ahead', reverse: true),
      Question('m2', 'I enjoy the things I usually enjoy', reverse: true),
      Question('m3', 'I feel connected to the people around me',
          reverse: true),
      Question('m4', 'I feel down or flat for no clear reason'),
    ],
  ),
  Section(
    id: 'overwhelm',
    title: 'Overwhelm',
    subtitle: 'Over the last two weeks…',
    icon: LucideIcons.layers,
    questions: [
      Question('o1', 'My to-do list feels impossible to finish'),
      Question('o2',
          'I struggle to focus because too much is happening at once'),
      Question('o3', 'I say yes to things even when I have no capacity'),
      Question('o4', "I feel like I'm always behind, no matter what I do"),
    ],
  ),
];

/// Insight copy shown on the results screen for the lowest-scoring area.
const focusInsights = <String, String>{
  'Stress':
      'Your answers point to stress as your biggest lever right now. Short, regular decompression — a 5-minute walk between tasks, a hard stop time in the evening — tends to move this score fastest.',
  'Anxiety':
      'Anxiety is currently your focus area. Naming worries on paper and scheduling a fixed daily "worry window" are two simple techniques with strong evidence behind them.',
  'Sleep':
      'Sleep is your focus area. A consistent wake time and keeping the phone out of bed for one week typically produce a measurable improvement.',
  'Mood & Wellbeing':
      'Mood & wellbeing is where you have the most room to grow. One small enjoyable activity per day, planned in advance, is the most reliable starting point.',
  'Overwhelm':
      'Overwhelm is your focus area. Try capturing everything into one list, then choosing only three items per day — protecting capacity beats adding productivity.',
};
