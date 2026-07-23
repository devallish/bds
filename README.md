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
- [Podman](https://podman.io/) (container engine for running Supabase locally — see note below; Docker Desktop works too if you prefer it)
- [Supabase CLI](https://supabase.com/docs/guides/cli)
- A OneSignal account (for push notification integration)

### Container engine: Podman

This project runs its local Supabase stack (Postgres, Auth, Storage, Realtime, Studio, Kong) on Podman rather than Docker Desktop, to keep local dev free of Docker Desktop's licensing/resource footprint. `supabase start` talks to whatever container engine is reachable at the default Docker API socket (`$DOCKER_HOST`, or `/var/run/docker.sock` if unset) — it doesn't need Docker Desktop itself, only something that speaks the same API, which Podman does.

Setup on a fresh machine:

```bash
brew install podman
podman machine init
podman machine start
podman-mac-helper install   # symlinks /var/run/docker.sock -> the Podman machine socket
```

After `podman-mac-helper install` (and a restart of the podman machine), `supabase start` works with no further environment changes — it picks up Podman automatically via the default socket. If you'd rather not install the helper, set `DOCKER_HOST` to Podman's socket manually before running any `supabase` command:

```bash
export DOCKER_HOST="unix://$(podman machine inspect --format '{{.ConnectionInfo.PodmanSocket.Path}}')"
```

### Database schema diagram

[documents/BDS_Mobile_App_Database_Schema.md](documents/BDS_Mobile_App_Database_Schema.md) is an auto-generated Mermaid ER diagram of the actual local schema, produced by [mermerd](https://github.com/KarnerTh/mermerd). It is not hand-maintained — regenerate it after any migration change:

```bash
supabase start   # if not already running
supabase/scripts/generate-schema-diagram.sh
```

mermerd isn't reliably available via its Homebrew tap at the moment; install it from a [GitHub release](https://github.com/KarnerTh/mermerd/releases) instead — download the `darwin_arm64` (or matching platform) tarball, extract it, and put the `mermerd` binary on your `PATH`.

## Getting started

See section 14 of the design doc for the recommended build order: scaffold the Flutter project with a layered (domain/data) folder structure, run `supabase start` locally, write domain interfaces first, then implement the Supabase and OneSignal adapters behind them.
