# NeuralCalm — Flutter app (iOS + Android)

Wellbeing app matching neuralcalm.com: lavender theme, Fraunces italic + Inter,
outlined Lucide icons. One shared codebase builds both iOS and Android.

## What works now (Step 2 foundation)
- Sign-in gate — Apple button on iOS, Google on Android (local for now; Firebase in Step 4)
- Full 6-section assessment: Stress, Anxiety, Sleep, Mood & Wellbeing, Overwhelm, Biometric Data (optional)
- Real scoring engine → Neural Calm Score 0–100 with category breakdown + focus-area insight
- 5 tabs: Home, Assess, Marcus (chat shell, score-aware placeholder), Body (health empty state), Profile

## Build WITHOUT installing Flutter (GitHub + Codemagic)
1. Create a new GitHub repo and upload everything in this folder to the repo ROOT
   (codemagic.yaml, pubspec.yaml, README.md, lib/). You can do this entirely in the
   browser: repo page → Add file → Upload files.
2. In Codemagic: **Add application** → pick the repo → it detects `codemagic.yaml`.
3. Run the **Android debug APK** workflow. First build ≈ 12–15 min.
4. Download `app-debug.apk` from the build page onto your Android phone
   (or scan the QR code Codemagic shows), allow "install from unknown sources", open the app.
5. Every push to `main` builds a fresh APK automatically.
6. iOS: run the **iOS build check** workflow any time to verify the iOS build compiles.
   Installing on iPhones / App Store needs an Apple Developer account ($99/yr)
   connected in Codemagic — done at store-prep time. No Mac required.

## Build locally (optional, faster iteration later)
```
flutter create . --org com.neuralcalm --project-name neuralcalm
flutter pub get
flutter run
```

## Files your team will edit most
- `lib/constants/questions.dart` — the question set (edit here only; UI + scoring adapt)
- `lib/services/scoring_service.dart` — score formula and weightings, fully commented

## Roadmap seams already in place
- Step 4: `lib/services/auth_service.dart` + commented Firebase packages in pubspec
- Step 5: `lib/services/health_service.dart` + commented `health` package (HealthKit + Health Connect in one API)
- Step 6: Marcus replies in `lib/providers/app_state.dart` → real AI backend
