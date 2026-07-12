# British Deer Society Mobile App

Planning and design repository for a mobile app covering membership/authenticated access, news and notifications, deer survey and stalking data collection, GPS tagging, and reporting/analysis for cull and deer management insight.

**Status:** Design/scoping stage — no application code yet. See [documents/BDS_Mobile_App_Technical_Design_Overview.md](documents/BDS_Mobile_App_Technical_Design_Overview.md) for the full technical design, confirmed decisions, and suggested build order.

## Confirmed stack

- **Mobile:** Flutter
- **Backend:** Supabase (Postgres + PostGIS)
- **Push notifications:** OneSignal
- **Maps:** MapLibre / OpenStreetMap

## Prerequisites for local development

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (for running Supabase locally)
- [Supabase CLI](https://supabase.com/docs/guides/cli)
- A OneSignal account (for push notification integration)

## Getting started

See section 14 of the design doc for the recommended build order: scaffold the Flutter project with a layered (domain/data) folder structure, run `supabase start` locally, write domain interfaces first, then implement the Supabase and OneSignal adapters behind them.
