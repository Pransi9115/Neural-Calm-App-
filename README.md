# NeuralCalm — Flutter app (iOS + Android)

Wellbeing app matching neuralcalm.com: lavender theme, Fraunces italic + Inter,
outlined Lucide icons. One shared codebase builds both iOS and Android.

## What works now
- Sign Up + Sign In (email & password) with forgot-password
  - Real Firebase accounts once lib/firebase_options.dart is filled in (5-min setup below)
  - Local mode until then, so the app is always usable
- Full 6-section assessment → Neural Calm Score 0-100, breakdown + focus-area insight
- Score history saved per account (survives app restarts)
- Marcus chat — becomes a REAL AI once an Anthropic API key is pasted into
  lib/services/ai_service.dart (get one at console.anthropic.com)
- Profile linked to the account: email, assessments taken, focus area, sign out
- Branded app: launcher icon auto-generated from assets/icon/app_icon.png,
  sign-in logo from assets/logo/neuralcalm_logo.png

## Connect real accounts (Step 4, one time, ~5 min)
1. console.firebase.google.com → Add project → "NeuralCalm" → Create (Analytics off is fine)
2. Build → Authentication → Get started → Sign-in method → Email/Password → Enable → Save
3. Gear → Project settings → General → Your apps → Android
   → package name: com.neuralcalm.neuralcalm → Register → download google-services.json
4. Open google-services.json in Notepad; copy 4 values into lib/firebase_options.dart:
   - projectId = project_info.project_id
   - messagingSenderId = project_info.project_number
   - appId = client[0].client_info.mobilesdk_app_id
   - apiKey = client[0].api_key[0].current_key
5. git push — the new APK has real accounts.

## Bring Marcus to life (Step 6, ~2 min)
1. console.anthropic.com → API keys → Create key
2. Paste it into `apiKey` in lib/services/ai_service.dart → git push
3. (Before a PUBLIC store release the key must move behind a server — planned at store prep.)

## Use your official logo
- Sign-in screen: save https://www.neuralcalm.com/assets/neural-calm.png
  over assets/logo/neuralcalm_logo.png
- App icon: replace assets/icon/app_icon.png with any square 1024x1024 PNG

## Build (GitHub + Codemagic — no local Flutter)
Push to main → "Android debug APK" builds automatically → install APK from Artifacts.
Other workflows (manual): Android release AAB, iOS build check.

## Files your team edits most
- lib/constants/questions.dart — the question set
- lib/services/scoring_service.dart — score formula & weightings
- lib/firebase_options.dart — Firebase values (Step 4)
- lib/services/ai_service.dart — Marcus AI key + persona (Step 6)

## Next: Step 5 — health data
lib/services/health_service.dart is the ready seam; the `health` package
(HealthKit + Health Connect in one API) plus permissions lands next.
