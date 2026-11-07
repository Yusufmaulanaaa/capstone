# HukumIn — AI Legal Consultation & Lawyer Matching App

HukumIn is a production-quality, minimal monochrome Flutter application designed for AI-driven legal consultations and lawyer matching.

---

## 🎨 Design System

The application strictly adheres to the monochrome design system specified in the reference:

| Token | Hex | Usage |
|---|---|---|
| **Ink** | `#0A0A0F` | Primary text, primary black buttons, active chips |
| **White** | `#FFFFFF` | Scaffolds, cards, bubble highlights |
| **Gray** | `#6B7280` | Secondary text, subtle metadata |
| **Line** | `#E8E9ED` | 1px hairline borders, dividers |
| **Card** | `#F7F7F8` | Bubble background, card containers |
| **Outer** | `#EDEEF1` | Background canvas for desktop/web device frame |
| **Red** | `#EF4444` | Notification dot, destructive/swipe actions |
| **Gold** | `#F5B301` | Star ratings, verified badges |

- **Typography**: Urbanist (via `google_fonts`) at weights 400 (regular), 500 (medium), 600 (semi-bold), 700 (bold), 800 (extra-bold).
- **Layout**: 8pt grid, 20px screen side padding, fully rounded pills and circles (radius 20–30px), 1px hairline borders (`C.line`).
- **Device Frame**: On wide screens (web / desktop), renders inside an iOS-style mobile container with status bar (`9:41`) and bottom home indicator.

---

## 📂 Project Architecture

```
lib/
├── core/
│   ├── colors.dart          # Palette constants (C.ink, C.white, C.gray, etc.)
│   ├── strings.dart         # AppStrings for all user-facing copy & localization
│   ├── theme.dart           # ThemeData (Urbanist font, Material 3, monochrome)
│   ├── router.dart          # GoRouter with named routes, typed extras, 300ms transitions
│   └── providers.dart       # Riverpod state management (chat, saved, booking, notifs)
├── data/
│   ├── models/
│   │   ├── lawyer_model.dart  # LawyerModel, ReviewModel, TopicModel
│   │   ├── booking_model.dart # BookingModel, ConsultationType enum
│   │   └── chat_model.dart    # ChatMessage, SavedChat, NotificationModel
│   └── repositories/
│       └── mock_repository.dart # Mock repository using Future.delayed for API swapping
├── features/
│   ├── onboarding/
│   │   └── screens/
│   │       └── onboarding_screen.dart # Hero with ScalesPainter fallback
│   ├── home/
│   │   ├── screens/
│   │   │   └── home_screen.dart       # Search, greeting, suggested topics, voice trigger
│   │   └── widgets/
│   │       └── topic_card.dart        # Reusable topic card with icons
│   ├── chat/
│   │   ├── screens/
│   │   │   └── chat_screen.dart       # Multi-turn AI chat, horizontal lawyer carousel
│   │   └── widgets/
│   │       ├── chat_bubbles.dart      # UserBubble, AiBubble, quick-reply chips
│   │       └── typing_indicator.dart  # 3-dot animated bouncing indicator
│   ├── lawyer/
│   │   └── screens/
│   │       └── lawyer_profile_screen.dart # 96px avatar, 3-stat card, reviews, sticky bottom
│   ├── booking/
│   │   └── screens/
│   │       ├── book_consultation_screen.dart # 7-day selector, 3-col slots, type, notes
│   │       └── booking_confirmed_screen.dart # Check icon, ticket card, dashed line
│   ├── document/
│   │   └── screens/
│   │       └── document_screen.dart   # Paper card, editable text, PDF download
│   ├── saved/
│   │   └── screens/
│   │       └── saved_screen.dart      # Segmented Chats/Lawyers, swipe-to-delete + undo
│   └── notifications/
│       └── screens/
│           └── notifications_screen.dart # List, unread badges, "Mark all as read"
├── shared/
│   └── widgets/
│       ├── widgets.dart               # CircleBtn, BlackButton, Composer, Avatar, AppBar
│       └── lawyer_card.dart           # Reusable LawyerCard with booking button
├── main.dart                          # App entry point, ProviderScope, DeviceFrame
├── theme.dart                         # Backward-compatible re-export
├── widgets.dart                       # Backward-compatible re-export
└── data.dart                          # Backward-compatible re-export
```

---

## 🔌 How to Swap Mock Repositories for a Real API

All remote data interactions are encapsulated in `lib/data/repositories/mock_repository.dart`.

To switch to a live REST / GraphQL backend:

1. Create an abstract repository interface or implement an API client:
   ```dart
   abstract class ILawyerRepository {
     Future<List<LawyerModel>> fetchLawyers();
     Future<LawyerModel> fetchLawyer(String id);
   }
   ```
2. Replace `Future.delayed` with an HTTP client (e.g., `http` or `dio`):
   ```dart
   class HttpLawyerRepository implements ILawyerRepository {
     final Client client;
     HttpLawyerRepository(this.client);

     @override
     Future<List<LawyerModel>> fetchLawyers() async {
       final response = await client.get(Uri.parse('https://api.hukumin.com/lawyers'));
       if (response.statusCode == 200) {
         final List jsonList = jsonDecode(response.body);
         return jsonList.map((j) => LawyerModel.fromJson(j)).toList();
       }
       throw Exception('Failed to load lawyers');
     }
   }
   ```
3. Expose the repository through Riverpod:
   ```dart
   final lawyerRepositoryProvider = Provider<ILawyerRepository>((ref) {
     return HttpLawyerRepository(Client());
   });
   ```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `>=3.3.0`
- Dart SDK `>=3.3.0`

### Setup & Run
```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run static analysis (0 issues)
flutter analyze

# 3. Run widget tests
flutter test

# 4. Run on Chrome Web
flutter run -d chrome

# 5. Run on Windows Desktop
flutter run -d windows
```
