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

## Design principles

- **Single Responsibility Principle.** Keep domain entities, use-cases, and adapters separate — each class/module should have one reason to change. Don't fold validation, persistence, and UI logic into the same class.
- **Dependency Inversion.** This is what the ports-and-adapters split above enforces in practice: business logic depends on the domain-layer interfaces (`AuthRepository`, `SurveyRepository`, `NotificationSender`, `MapProvider`), never on the concrete Supabase/OneSignal/MapLibre implementations. If a class is hard to unit test without a fake, that's a signal the abstraction is leaking, not a reason to reach for a live dependency in the test.

## Testing approach

Follow a standard testing pyramid — many fast unit tests, fewer component tests, fewer still contract tests — rather than relying on end-to-end tests for coverage.

- **Tests evolve with the feature.** Add and update tests as each vertical slice/story is built, not as a follow-up pass afterwards — a story isn't done until its tests exist and pass alongside it. When a model or behaviour changes, its existing tests must be updated in the same change, not left stale.
- **Unit tests** (bulk of the suite): domain logic and use-cases tested in isolation against fake implementations of the four core interfaces. Possible only because of the dependency inversion above.
- **Entity lifecycle tests.** For every model in the domain (member, field record, photo, news article, etc.), cover its full lifecycle — create, update, delete — and do this throughout the model hierarchy, not just at the root: relationship changes (e.g. a member's region reassignment, a field record's type change) and child record changes (e.g. deleting/updating a field record's attached photos, cascading effects where a parent-child relationship exists) all need their own tests, not just the parent entity in isolation.
- **Component tests**: Flutter widget tests for individual screens/widgets, run locally against the same fakes — no real backend involved.
- **Contract tests**: verify each concrete adapter (Supabase, OneSignal, MapLibre) actually satisfies its domain interface's contract, run against the local Supabase stack (`supabase start`) rather than a live project.
- **Priority coverage** — areas the design doc flags as likely to fail silently rather than crash:
  - Offline save/sync: explicitly test save-offline → reconnect → sync, never assume it works.
  - Region/role-based RLS: assert that cross-region and cross-role access is *denied*, not just that same-role access succeeds.
  - Location generalisation: precise coordinates vs grid-square/region on any public or aggregate view.
- **CI** runs the fully localised suite (unit + component + contract tests against local Supabase) on every push — nothing that depends on a live/hosted service.
- **CD** runs a small smoke-test suite against the deployed environment after release — critical paths only (login, submit a field record, receive a notification) — as a release gate, not a substitute for the pyramid above.
- **Test data**: fixtures and test accounts must be synthetic. Real member data must never appear in tests, fixtures, or CI, consistent with the GDPR stance in design doc section 8.

## Local development

Develop against a local Supabase stack (`supabase start`, via Docker) rather than a live project. Schema changes are tracked as version-controlled migrations. Only connect to a real hosted Supabase project once testing needs genuine network conditions or the app needs to be shared with others.

Build order: scaffold the Flutter project with the layered folder structure → run the local Supabase stack → write domain interfaces → implement Supabase/OneSignal adapters behind them.
