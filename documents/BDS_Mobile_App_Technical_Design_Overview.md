# British Deer Society Mobile App — Technical Design Overview

*Prepared for initial scoping purposes. Assumes a small-charity budget with a national, regionally-structured membership.*

## 1. Purpose and framing

This document sets out the technical shape of a mobile application for the British Deer Society, covering membership and authenticated access, news and notifications, deer survey and observation data collection, stalking reports, GPS tagging and tracking, and the reporting/analysis layer that turns member-submitted data into cull and deer management insight. The functional detail is intentionally kept light, as requested — the focus here is the platform architecture, technology choices, and the trade-offs that keep recurring cost low while still supporting a national organisation operating through regional groups.

The single biggest design decision that shapes everything else is this: a charity of this scale should not build or run its own servers. Every recommendation below is chosen to minimise ongoing infrastructure and maintenance cost by leaning on managed platforms, and to avoid a large up-front build in favour of an MVP that can grow.

## 2. High-level architecture

The system has four layers: the mobile app itself, an authentication and membership layer, a managed backend handling data storage and business logic, and a reporting/analytics layer that runs on top of the same data rather than a separate system.

A cross-platform mobile framework (Flutter or React Native) rather than separate native iOS and Android codebases is the right call here. It roughly halves ongoing development cost since there is one codebase to maintain, and a charity of this size is very unlikely to need native-only capabilities that either framework can't reach. Flutter has a slight edge for offline-heavy, map-heavy apps like this one, but React Native is a reasonable alternative if the eventual development partner has stronger React Native skills — the choice should follow the developer, not the other way around.

For the backend, a Backend-as-a-Service (BaaS) platform such as Supabase or Firebase replaces the need for a custom server, database administration, and DevOps team. Both provide authentication, a managed database, file storage, and serverless functions for the bits of logic that don't fit a simple CRUD pattern (report generation, notification triggers, data validation). Supabase is built on Postgres, which is a genuine advantage here because the deer survey and stalking data is inherently relational and geospatial (Postgres's PostGIS extension is a strong fit for GPS/location data), and because it avoids vendor lock-in to the degree a proprietary NoSQL store like Firestore does. Firebase remains a fine choice if there's already institutional familiarity with it, and its push notification service (FCM) is best-in-class regardless of which BaaS is chosen for the rest of the stack.

## 3. Membership, authentication, and regional structure

Since BDS is a national body organised into regions, the data model needs a region as a first-class concept from day one, not retrofitted later. Each member record should carry a home region, and each survey, stalking report, or observation should carry the region it was submitted in (derived from GPS location, with a manual override) so that regional coordinators can see only their own area while national admins see everything rolled up. This is a permissions and row-level security question as much as a data modelling one — both Supabase and Firebase support row-level access rules, so a member only ever sees their own submissions, a regional coordinator sees their region's submissions and aggregate stats, and national staff see everything.

Authentication itself should use the BaaS provider's built-in auth (email/password plus optional social login) rather than a custom-built system — this is a solved problem and building it from scratch is pure unnecessary cost and risk. Membership status (paid/lapsed/renewal date) is likely to already live in whatever membership or CRM system BDS uses for payments today; rather than duplicating that system, the app's ideal integration is to sync membership status from the existing CRM via a scheduled job or webhook, so membership renewal and payment handling isn't rebuilt inside the app.

## 4. News and notifications

This is the most straightforward part of the system. A simple content model (articles with a title, body, image, region tag, and publish date) sits in the same database as everything else, editable by staff through a lightweight admin panel rather than a bespoke CMS. Push notifications route through Firebase Cloud Messaging regardless of which BaaS is chosen for the rest of the stack, since FCM is free at this scale and handles both iOS and Android delivery. Segmenting notifications by region (so a member only gets alerts relevant to their area) reuses the same region field described above.

## 5. Deer surveys, observations, and stalking reports

Functionally these are all variations on the same pattern: a structured form, a location, a timestamp, and optionally photos, submitted by a member and stored against their account and region. The technical design implication is that a single flexible "field record" data structure (with a type field distinguishing survey, observation, or stalking report) is more maintainable than three separate systems, even though the forms shown to the user will differ.

The most important technical requirement here is offline-first design. Members doing deer surveys or stalking reports will very often be in woodland or rural areas with poor or no mobile signal. The app must let a member fill in a full report offline, save it locally on the device, and sync automatically once connectivity returns — this cannot be an afterthought bolted on later, as it fundamentally shapes how data is stored and synced on the client. Both Flutter and React Native have mature local-database and sync libraries for this (e.g. a local SQLite/Drift store on the device paired with a sync layer to the backend), and Supabase and Firebase both have offline-capable client SDKs, though the offline behaviour still needs deliberate design and testing rather than being assumed to work automatically.

Photo capture and storage should compress images client-side before upload (to control storage costs and cope with poor signal) and use the BaaS provider's built-in object storage rather than a separate service.

## 6. GPS tagging and tracking

GPS falls into two distinct use cases that should be designed separately: a single location tag attached to a survey or stalking report (easy — just capture device location at the point of submission), and continuous tracking of a route or session (harder — requires background location permissions, battery management, and a "start/stop tracking" UX). Continuous background tracking is significantly more complex and battery-intensive than point capture, and it's worth confirming early whether it's actually required for the initial release or whether point-in-time location tags cover the real need — this alone can be the difference between a straightforward build and a substantially harder one.

For maps, OpenStreetMap-based mapping (via libraries like Mapbox's free tier or fully open-source alternatives like MapLibre) is considerably cheaper at scale than Google Maps, whose pricing is per-map-load and can become a meaningful recurring cost as usage grows. Given the low-cost priority, OpenStreetMap/MapLibre is the recommended default, with Google Maps only justified if BDS specifically needs its satellite imagery or a level of UI familiarity that outweighs the cost difference.

One consideration worth flagging early rather than late: location data about deer stalking activity is sensitive — both for member privacy and, potentially, for the safety of the animals and the land involved (precise stalking locations becoming public could create poaching or trespass risk). Location data should be treated as sensitive by default: precise coordinates visible only to the submitting member and relevant regional/national staff, with any public-facing or aggregate views (e.g. a population heatmap) deliberately generalised to a grid square or region rather than an exact point.

## 7. Data analysis and reporting

Because everything above funnels into one well-structured, region-tagged database, the reporting layer doesn't need to be a separate system — it's a set of queries and scheduled jobs running against the same data. For quarterly and annual population and cull/stalking reports, the practical low-cost approach is a scheduled serverless function (running monthly or quarterly) that aggregates the period's submissions by region and species, and generates a report — either a dashboard view in a lightweight BI tool (Metabase has a generous free/self-host tier and connects directly to Postgres, which is a strong fit if Supabase is chosen) or a generated PDF/document for circulation to regional coordinators and cull management stakeholders.

It's worth deciding early whether "data analysis" means descriptive reporting (counts, trends, regional comparisons — straightforward) or something more like population modelling or predictive estimates (a genuinely harder statistical problem, likely needing input from an ecologist or statistician on methodology, not just an engineering build). Most deer management reporting of this kind falls into the first category, which keeps this comfortably within reach of the low-cost stack described here.

## 8. Security, privacy, and compliance

As a UK charity handling personal member data and sensitive location data, GDPR compliance is a first-order concern rather than an add-on. Both Supabase and Firebase can be configured to keep data in EU/UK regions, which matters for compliance. A published privacy policy covering what location and personal data is collected, who can see it, and how long it's retained should exist before launch, not after. Role-based access (member / regional coordinator / national admin, as described in section 3) is the main technical control that keeps this manageable rather than needing a bespoke security review for every feature.

## 9. Recommended stack summary

| Layer | Recommendation | Why |
|---|---|---|
| Mobile app | Flutter (or React Native) | One codebase for iOS + Android, halves build/maintenance cost |
| Backend/BaaS | Supabase (Postgres + PostGIS) | Managed auth, database, storage, functions; strong fit for geospatial data; avoids custom server/DevOps cost |
| Auth | Supabase/Firebase built-in auth | Solved problem, don't build custom |
| Push notifications | Firebase Cloud Messaging | Free at this scale, cross-platform, works alongside Supabase for everything else |
| Maps | MapLibre/OpenStreetMap | Far cheaper at scale than Google Maps |
| Offline sync | Local SQLite/Drift + BaaS offline SDK | Essential for field use in poor-signal areas |
| Reporting/BI | Metabase (self-hosted or free tier) or scheduled report-generation function | Reuses existing data, avoids separate reporting system |
| Membership/payments | Existing BDS CRM, synced via webhook/scheduled job | Avoids duplicating solved payment/membership infrastructure |

## 10. Cost drivers to plan around

The main ongoing costs at charity scale are: BaaS hosting (free or low tens of pounds per month on Supabase/Firebase's paid tiers once past the free tier threshold), map tile/API usage (kept low by choosing OpenStreetMap/MapLibre over Google Maps), push notifications (free via FCM), app store developer accounts (a small annual/one-off fee for Apple and Google), and object storage for photos (scales with usage but is inexpensive per GB on both platforms). The largest real cost by far will be development time, not infrastructure — which is exactly why the BaaS-first, cross-platform approach matters: it minimises the engineering hours needed to reach a working product.

## 11. Suggested phasing

A sensible MVP scope for phase one is authenticated membership access, news/notifications, and the observation/survey forms with offline support and simple point-in-time GPS tagging — deliberately leaving continuous GPS tracking and the full reporting/BI layer for phase two, once real submission data exists to design meaningful reports around. Building the reporting layer before there's real data to report on tends to produce reports nobody asked for; better to get member-facing data collection right first, then build the analysis layer against actual usage patterns.

## 12. Open questions worth resolving before a build starts

A short list of decisions will materially affect cost and timeline, and are worth settling before development begins: whether continuous GPS tracking (not just point tagging) is genuinely required for phase one; whether BDS's existing membership/CRM system has a usable API or webhook for syncing status; what "data analysis" needs to produce in practice (a dashboard, a circulated PDF, or both); and who within BDS will own ongoing content (news posts) and data moderation once the app is live, since that's an operational cost as much as a technical one.

## 13. Decisions confirmed

Two decisions have been settled and are recorded here for reference.

Mobile framework: Flutter has been chosen over React Native. This was decided ahead of picking a development partner, so it's worth flagging that Flutter developer availability should be a factor when selecting who builds the app — the framework choice now constrains that search rather than following from it.

Push notifications: OneSignal (free tier) has been chosen over integrating directly with Firebase Cloud Messaging. OneSignal sits on top of FCM and APNs but provides its own dashboard for composing, scheduling, and segmenting notifications (for example, by region), which avoids writing custom sending logic against the raw FCM API from a Supabase Edge Function. The practical implication is one less piece of custom backend code to build and maintain, at the cost of a light dependency on OneSignal's platform rather than Firebase's. This supersedes the FCM recommendation in section 4 and the stack table in section 9.

## 14. Getting started: local development

The build itself should move out of this planning tool and into Claude Code (or an equivalent local coding environment), since it needs a real Flutter build/test/hot-reload loop and, eventually, an iOS/Android emulator or device — none of which this document-drafting session can run.

Most of the backend can be developed entirely on a local machine before any live cloud project exists. Supabase's CLI (`supabase start`) runs the full backend stack — Postgres, Auth, Storage, Edge Functions — in Docker, with schema changes tracked as version-controlled migrations. Development and testing happen against localhost throughout, and a real hosted Supabase project is only needed once the app is ready to be tested with genuine network conditions or shared with other people.

The app itself should be structured so that Supabase, OneSignal, and the mapping library are never referenced directly from the UI or business logic. A domain layer defines interfaces for each external dependency — an `AuthRepository`, `SurveyRepository`, `NotificationSender`, and `MapProvider` — and a separate data layer provides the concrete Supabase- and OneSignal-backed implementations, wired together with a dependency injection tool such as `get_it` or Riverpod. This ports-and-adapters split means any of these services can be faked for testing, or swapped later, without touching the rest of the app.

A practical build order follows from this: scaffold the Flutter project with that layered folder structure first, get the local Supabase stack running, write the domain interfaces before any Supabase-specific code (since they define the contract the rest of the app builds against), and only then implement the Supabase and OneSignal adapters behind them.
