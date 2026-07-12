# CLAUDE.md

Guidance for working in this repository. Full context: [documents/BDS_Mobile_App_Technical_Design_Overview.md](documents/BDS_Mobile_App_Technical_Design_Overview.md).

## Project

Mobile app for the British Deer Society: membership/auth, news and notifications, deer survey/observation/stalking reports, GPS tagging, and reporting for cull and deer management insight. National body organised into regions — region is a first-class field on members and on every submission.

## Confirmed stack

- **Mobile:** Flutter (not React Native — decided ahead of picking a dev partner, so factor Flutter availability into that search)
- **Backend:** Supabase (Postgres + PostGIS)
- **Push notifications:** OneSignal (sits on top of FCM/APNs — do not build custom sending logic against the raw FCM API)
- **Maps:** MapLibre / OpenStreetMap (not Google Maps, on cost grounds)

## Architecture rules

- **Offline-first is a hard requirement, not an afterthought.** Survey, observation, and stalking report forms must work fully offline (local SQLite/Drift store) and sync once connectivity returns. Design storage and sync with this from the start.
- **Ports-and-adapters split.** Supabase, OneSignal, and the mapping library must never be referenced directly from UI or business logic. Define domain-layer interfaces first — `AuthRepository`, `SurveyRepository`, `NotificationSender`, `MapProvider` — before writing any Supabase/OneSignal-specific code. Concrete adapters live in a separate data layer, wired via `get_it` or Riverpod.
- **Region-based access control.** Three roles: member (own submissions only), regional coordinator (own region), national admin (everything). Enforce via Supabase/Firebase row-level security, not application-level checks alone.
- **Location data is sensitive by default.** Precise coordinates are visible only to the submitting member and relevant regional/national staff. Any public or aggregate view (e.g. population heatmap) must generalise to a grid square or region, never an exact point.

## Local development

Develop against a local Supabase stack (`supabase start`, via Docker) rather than a live project. Schema changes are tracked as version-controlled migrations. Only connect to a real hosted Supabase project once testing needs genuine network conditions or the app needs to be shared with others.

Build order: scaffold the Flutter project with the layered folder structure → run the local Supabase stack → write domain interfaces → implement Supabase/OneSignal adapters behind them.
