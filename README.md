# NeuralCalm™ — Flutter app (iOS + Android) · v0.3

The approved v5 design: navy #1E1148 chrome, lavender #F5F2FC pages,
vivid purple #7E5CE6, Cormorant Garamond + Outfit, white-Neural wordmark.

## What this version does
- Sign Up (full name + email + password) / Sign In / forgot password — Firebase (LIVE, values included)
- The REAL questionnaire: 6 domains × 5 questions, exact coach-tool wording & answer labels
- Backend-identical scoring: weighted domains, LOWER = calmer,
  zones Optimal 0–35 · Moderate 36–60 · Elevated 61–100, clinical flags
- Auto-save + resume: leave mid-assessment, continue later
- Safeguarding support card on the Mood & Wellbeing self-harm question
- Professional report opens on completion — letterhead, ring, domain table,
  flagged responses with exact answer text, trend — Share as PDF
- Marcus AI (Gemini/Anthropic key via Codemagic env vars, unchanged)
- PHP backend sync: see php-backend-api/README.md, then set
  lib/services/backend_service.dart (backendUrl + apiKey)

## Update workflow (IMPORTANT)
1. DELETE the old `lib` folder in your project first (old files would conflict).
2. Copy in everything from this package (lib/, assets/, pubspec.yaml, codemagic.yaml).
3. git add . && git commit -m "v0.3 final design + real questionnaire" && git push

## Files your team edits most
- lib/constants/questions.dart — the questionnaire (single source of truth)
- lib/services/scoring_service.dart — weights & zones (matches score.php)
- lib/services/backend_service.dart — PHP backend URL + API key
- lib/services/ai_service.dart — Marcus persona (keys stay in Codemagic vault)

## Next step
Health data (HealthKit + Health Connect) pre-filling the Biometric Data domain.
