/// ─────────────────────────────────────────────────────────────
/// THE NEURALCALM QUESTIONNAIRE — extracted 1:1 from the coach
/// tool / PHP backend (pages/d0–d5). 6 domains × 5 questions,
/// each with its own 5 answer labels, scored 0–4.
/// Weights and flag thresholds identical to index.php/score.php.
/// Domain 6 wording adapted to first person for the consumer app.
/// EDIT HERE ONLY — scoring, UI and the report adapt automatically.
/// ─────────────────────────────────────────────────────────────

class Question {
  final String text;
  final List<String> options; // exactly 5, index 0..4
  /// Answer value (0–4) at or above which this response is flagged.
  /// 99 = never flagged.
  final int flagThreshold;
  const Question(this.text, this.options, {this.flagThreshold = 99});
}

class Domain {
  final String id;
  final String title;
  final double weight;
  final List<Question> questions;
  const Domain(this.id, this.title, this.weight, this.questions);
}

/// The Mood & Wellbeing self-harm question triggers the in-app
/// safeguarding support card at this answer value or above.
const safeguardDomainId = 'd3';
const safeguardQuestionIndex = 4;
const safeguardThreshold = 2;

const domains = <Domain>[
  Domain('d0', 'Stress', 1.2, [
    Question(
      'How would you rate your overall stress level over the past two weeks?',
      ['Very low — feeling relaxed', 'Low — manageable', 'Moderate — noticeable', 'High — significant', 'Overwhelming — barely coping'],
      flagThreshold: 3,
    ),
    Question(
      'Do you find yourself constantly thinking about problems or worries, even when you try to switch off?',
      ['Never — mind is clear', 'Rarely', 'Sometimes — comes and goes', 'Often — most evenings', 'Almost always — cannot switch off'],
    ),
    Question(
      'How often do you feel like you have more than you can cope with?',
      ['Never', 'Rarely', 'Sometimes', 'Often', 'Nearly always'],
      flagThreshold: 3,
    ),
    Question(
      'When stress hits, how quickly do you return to feeling calm and normal?',
      ['Very quickly — within minutes', 'Within a few hours', 'Takes a day or two', 'Takes several days', 'Rarely feel I fully recover'],
    ),
    Question(
      'How effective are any strategies you currently use to manage stress?',
      ['Very effective', 'Mostly effective', 'Somewhat effective', 'Rarely effective', 'I do not have any / nothing works'],
    ),
  ]),
  Domain('d1', 'Anxiety', 1.2, [
    Question(
      'How often have you felt anxious, nervous, or on edge without a clear reason?',
      ['Never', 'Several days', 'More than half the days', 'Nearly every day', 'Constantly throughout the day'],
      flagThreshold: 3,
    ),
    Question(
      'Do you experience physical symptoms of anxiety — racing heart, chest tightness, shakiness, breathlessness?',
      ['Never', 'Occasionally', 'Sometimes', 'Regularly', 'Very frequently — it disrupts daily life'],
      flagThreshold: 3,
    ),
    Question(
      'How much does anxiety interfere with your daily life, work, or relationships?',
      ['Not at all', 'Very little — minor inconvenience', 'Somewhat — noticeable impact', 'Quite a lot — affects functioning', 'Severely — significantly limits life'],
      flagThreshold: 3,
    ),
    Question(
      'Do you avoid situations, people, or activities because of anxiety?',
      ['Never', 'Occasionally — minor avoidance', 'Sometimes', 'Often — noticeable pattern', 'Frequently — significantly limits life'],
    ),
    Question(
      'How well are you able to calm yourself down when you feel anxious?',
      ['Very well — quickly and effectively', 'Fairly well', 'Moderately — takes effort', 'Poorly — takes a long time', 'Very poorly — cannot self-regulate'],
    ),
  ]),
  Domain('d2', 'Sleep', 1.0, [
    Question(
      'How would you rate your overall sleep quality over the past two weeks?',
      ['Very good — rested and refreshed', 'Good — mostly well rested', 'Fair — OK but not great', 'Poor — frequently disrupted', 'Very poor — severely disrupted'],
    ),
    Question(
      'How long does it typically take you to fall asleep?',
      ['Under 15 minutes', '15–30 minutes', '30–60 minutes', '1–2 hours', 'Over 2 hours or cannot sleep'],
    ),
    Question(
      'Do you wake during the night — and how difficult is it to get back to sleep?',
      ['Never or very rarely', 'Wake briefly but return quickly', 'Sometimes wake and take time to settle', 'Often wake and struggle to sleep', 'Wake frequently and cannot get back to sleep'],
      flagThreshold: 3,
    ),
    Question(
      'How rested and refreshed do you feel when you wake up in the morning?',
      ['Very rested — ready for the day', 'Fairly rested', 'Somewhat tired', 'Quite tired — takes time to feel OK', 'Exhausted — never feel recovered'],
    ),
    Question(
      'How much does poor sleep affect your mood, focus, and ability to cope during the day?',
      ['Not at all — no daytime impact', 'Very little impact', 'Moderate impact', 'Quite a lot — affects daily functioning', 'Severely — significantly impairs daily life'],
    ),
  ]),
  Domain('d3', 'Mood & Wellbeing', 1.3, [
    Question(
      'Over the past two weeks, how often have you felt low, sad, or hopeless?',
      ['Not at all', 'Several days', 'More than half the days', 'Nearly every day', 'Every day — persistent and severe'],
      flagThreshold: 3,
    ),
    Question(
      'Have you noticed a loss of interest or pleasure in things you usually enjoy?',
      ['Not at all', 'Very slight change', 'Some loss of interest', 'Significant loss', 'Almost nothing brings pleasure now'],
      flagThreshold: 3,
    ),
    Question(
      'How would you rate your emotional resilience — your ability to cope when things go wrong?',
      ['Very resilient — bounce back quickly', 'Fairly resilient', 'Variable — good days and bad', 'Low — take a long time to recover', 'Very low — small setbacks significantly affect me'],
    ),
    Question(
      'Do you feel a sense of purpose and meaning in your daily life?',
      ['Very much so — strong sense of purpose', 'Mostly yes', 'Sometimes — varies', 'Rarely', 'Not at all — life feels empty or pointless'],
      flagThreshold: 3,
    ),
    Question(
      'Have you had any thoughts of harming yourself, or felt that things would be better without you?',
      ['No — not at all', 'Very rarely — a passing thought quickly dismissed', 'Occasionally', 'Regularly', 'Frequently or with intent'],
      flagThreshold: 2,
    ),
  ]),
  Domain('d4', 'Overwhelm', 1.0, [
    Question(
      'How often do you feel overwhelmed by everything you have to do or think about?',
      ['Rarely — life feels manageable', 'Occasionally', 'Sometimes — certain days', 'Often — most days', 'Almost constantly — cannot see a way through'],
      flagThreshold: 3,
    ),
    Question(
      'How is your ability to concentrate and focus on tasks right now?',
      ['Excellent — sharp and focused', 'Good — mostly fine', 'Variable — up and down', 'Poor — frequently distracted', 'Very poor — cannot sustain focus'],
    ),
    Question(
      'Do you experience decision fatigue — finding it hard to make even small decisions?',
      ['Not at all', 'Occasionally — minor', 'Sometimes', 'Regularly — noticeable', 'Very frequently — even trivial decisions are hard'],
    ),
    Question(
      'How supported do you feel in your life right now — by people around you?',
      ['Very supported — strong network', 'Mostly supported', 'Somewhat supported', 'Poorly supported', 'Very isolated or alone'],
      flagThreshold: 3,
    ),
    Question(
      'How much energy do you have left for yourself at the end of a typical day?',
      ['A lot — still energised', 'Quite a bit', 'Some — variable', 'Very little', 'Nothing — completely depleted'],
    ),
  ]),
  Domain('d5', 'Biometric Data', 0.8, [
    Question(
      'How does your HRV trend compare to your personal baseline this week?',
      ['Well above baseline — significant improvement', 'Slightly above baseline', 'At or near baseline', 'Slightly below baseline', 'Well below baseline — significant decline'],
    ),
    Question(
      'How many EDA stress events did your band log in the past 7 days?',
      ['0–3 events — very calm', '4–6 events — low', '7–12 events — moderate', '13–20 events — high', '20+ events — very high stress activation'],
    ),
    Question(
      'What is your average deep sleep percentage over the past week?',
      ['Above 25% — excellent', '20–25% — good', '15–20% — adequate', '10–15% — below optimal', 'Under 10% — significantly low'],
    ),
    Question(
      'Is your Neural Calm Score trending upward, flat, or downward?',
      ['Clear upward trend — improving weekly', 'Slight improvement', 'Flat — no meaningful change', 'Slight decline', 'Clear downward trend — concern'],
      flagThreshold: 3,
    ),
    Question(
      'How consistently have you taken Anandanol™ this week?',
      ['Every day — full adherence', '6 out of 7 days', '4–5 out of 7', '2–3 out of 7', 'Rarely or not at all'],
    ),
  ]),
];

int get totalQuestions =>
    domains.fold(0, (n, d) => n + d.questions.length);
