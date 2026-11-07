# Changelog

All notable changes to the HukumIn project are documented below.

## [1.0.0] - 2026-11-06

### Architecture & Foundation
- Restructured into clean feature-first architecture (`core`, `data`, `features`, `shared`).
- Integrated `go_router` with declarative named routes, typed parameters, and smooth 300ms ease-out page transitions.
- Integrated `flutter_riverpod` for clean state management across chat messages, typing status, saved items, unread notifications, and booking draft.
- Consolidated all user-facing copy into `AppStrings` for localization readiness.
- Set up mock repositories (`LawyerRepository`, `NotificationRepository`) with `Future.delayed` for future backend integration.

### New Features & Screens
- **Lawyer Profile Screen**: 96px avatar with verified badge, 3-column stats card (Rating, Experience, Cases), practice areas chips, client reviews with star rows, and sticky bottom bar with hourly rate and "Book consultation" action.
- **Book Consultation Screen**: Horizontal 7-day date selector pills, 3-column time slot grid with disabled slot support, consultation type selector (Video / Voice / In person), optional note field, live price summary card, and smart validation disabling booking until date and time are selected.
- **Booking Confirmed Screen**: Full-screen confirmation featuring a prominent check circle, headline, ticket-style card with dashed divider line, "Add to calendar" button, and "Back to home" navigation.
- **Voice Input Sheet**: Bottom sheet with 28px top radius, concentric pulsing radar animation with microphone, live transcript simulation, and automatic composer population.
- **AI Legal Document Screen**: Accessible from suggested topics, featuring paper-style preview card, "AI generated" chip, in-place document editing toggle, and PDF download action.
- **Saved Screen**: Segmented control switching between Saved Chats and Saved Lawyers, full swipe-to-delete with undo SnackBar, and clean empty state with direct action to start a chat.
- **Notifications Screen**: Notification list with unread indicators, category icons, timestamp, and "Mark all as read" capability that synchronizes with the home notification bell dot.
- **Chat Enhancements**: Multi-turn message history persistence while the app is running, animated 3-dot bouncing typing indicator, auto-scrolling to bottom on new messages, copy-on-long-press for bubbles, and quick-reply chips under AI messages ("Show more lawyers", "Draft a letter").

### Polish & Quality Gates
- **Device Frame**: Desktop and Web builds feature an authentic mobile device container with iOS status bar (`9:41`) and home indicator.
- **Image Fallbacks**: Integrated `cached_network_image` with elegant initials avatar fallbacks and a custom vector `ScalesPainter` for Lady Justice.
- **Responsive & Accessible**: Strict 44px minimum tap targets, screen scrolling across compact widths without overflow, and Semantics labels on icon buttons.
- **Quality Gates**: `flutter analyze` passing with 0 issues, `dart format` applied across the entire codebase, and all 4 comprehensive widget tests passing.

