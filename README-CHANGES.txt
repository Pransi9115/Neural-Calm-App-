NEURAL CALM — APP UPDATE
========================

WHAT CHANGED
  1. Logo      -> now uses your brand PNG instead of styled text
  2. Nav bar   -> also shown on Assessment and Report pages
  3. "Marcus"  -> renamed to "Calm Coach" everywhere
  4. "Body"    -> renamed to "Monitoring"

FILES TO UPLOAD TO GITHUB
--------------------------
NEW    lib/widgets/calm_nav_bar.dart
NEW    assets/logo/neural-calm.png
EDIT   lib/widgets/wordmark.dart
EDIT   lib/screens/main_shell.dart
EDIT   lib/screens/chat_screen.dart
EDIT   lib/screens/body_screen.dart
EDIT   lib/services/ai_service.dart
EDIT   lib/services/backend_service.dart   (comment only)
EDIT   lib/screens/assessment/assessment_screen.dart
EDIT   lib/screens/assessment/report_screen.dart

*** ONE MANUAL EDIT — pubspec.yaml ***
--------------------------------------
The logo will NOT appear unless you register the folder.
Find this near the bottom of pubspec.yaml:

flutter:
  uses-material-design: true
  assets:
    - assets/icon/

and change it to:

flutter:
  uses-material-design: true
  assets:
    - assets/icon/
    - assets/logo/

Indentation matters: four spaces before "- assets/logo/".
