# British Deer Society Mobile App — Cost and Funding Overview

*Prepared for scoping purposes. Figures reflect pricing and grant information available as of July 2026 — verify current rates and deadlines before committing budget, as vendor pricing and grant windows both change.*

## 1. Purpose and framing

This document captures the financial picture that sits alongside the technical design in [BDS_Mobile_App_Technical_Design_Overview.md](BDS_Mobile_App_Technical_Design_Overview.md): what the app is likely to cost to run once live, what it's likely to cost to build, what a sensible contractual arrangement with a development partner looks like, and what charity-specific discounts or grant funding might offset either side.

## 2. Baseline monthly running cost (excluding development time)

| Item | Standard cost | Notes |
|---|---|---|
| Apple Developer Program | ~£6.50/month (£99/year) | Unavoidable if publishing to the App Store, unless waived — see §4 |
| Google Play | ~£0/month | $25 **one-time** registration, not recurring |
| Supabase | £0–£20/month | Free tier likely covers early launch; Pro tier (~£20/mo, $25) buys no project-pausing, backups, and headroom past free-tier limits (8GB DB, 100k MAU, 100GB storage) |
| OneSignal | £0/month | Free tier covers unlimited mobile push at charity scale |
| Maps (MapLibre/OpenStreetMap) | £0/month | Self-hosted/open tiles, no per-load billing — the reason Google Maps was ruled out |
| Photo storage | £0/month | Included inside Supabase's free/Pro storage allowance at this scale |

**Standard baseline: ~£0–£30/month.** The only cost that's genuinely hard to avoid without a waiver is the Apple Developer fee.

## 3. Development (build) cost

This is the dominant cost, not infrastructure. No confident figure can be given without a partner and finalised scope — a UK Flutter build of this shape (offline-first forms, RLS-secured regional access, GPS/maps, per the phased MVP in the design doc's §11) commonly lands in the tens of thousands of pounds for a small studio, with the actual number depending heavily on team seniority and how much of the offline-sync/RLS work is genuinely custom versus boilerplate. Get 2–3 quotes against the phase-1 MVP scope once a Flutter-capable partner shortlist exists, rather than budgeting from a rule of thumb.

## 4. Charity discounts on running costs

| Item | Charity option | Effect |
|---|---|---|
| Apple Developer Program | **Fee waiver** for eligible nonprofits/charities/government/education orgs (UK is an eligible region). Request at enrollment; must be reconfirmed annually. Disqualified if the app sells digital goods/services or uses in-app purchases — BDS's design (membership payments handled via the existing CRM, not in-app) should keep this eligible. | Removes the £6.50/month entirely |
| Supabase | Nonprofit program discount, commonly **40–80% off**, with proof of registered charity status | Turns ~£20/month Pro tier into roughly £4–£12/month, or free tier may suffice |
| Google Play, OneSignal, MapLibre | No further charity-specific discount found — already £0 or a one-off £20 | No change |

**Realistic post-discount baseline: ~£0–£10/month.** Register with **TechSoup UK** first — it's the standard gateway several providers (Microsoft, Google Workspace) use to verify UK charity status, and is a useful adjacent resource even beyond this stack.

## 5. Funding avenues for the build cost

No direct waiver exists for custom development labour, but a few avenues are worth pursuing in parallel with getting quotes:

- **WCIT Charity Grants for IT and Digital Projects** — funds this kind of work directly, but reported success rate is under 2%. Next deadline (as of writing) 14 August 2026.
- **Digital Inclusion Innovation Fund** — larger grants (£25k–£500k) but with a delivery deadline (31 March 2026 at time of writing) that may already be too tight to be workable.
- **Fat Beehive Foundation Grants** — up to £2,500, only fits if BDS's annual income is under £1m, and only covers a fraction of a full build.
- **Pro-bono/discounted development** — some UK digital agencies (e.g. Reason Digital, Fat Beehive) run charity/nonprofit rate cards; worth asking any shortlisted partner directly rather than assuming standard commercial pricing.
- **Corporate pro-bono placements** — some companies release developers for charity projects via CSR programmes; worth checking whether any BDS corporate partners or trustees have this available.

Treat the running-cost savings in §4 as close to guaranteed (no downside to applying). Treat grant funding for the build as worth attempting but not something to plan the budget around, given the odds and deadlines involved.

## 6. Contractual setup for delivering this to BDS

Whether the work is delivered by an external partner or by whoever is scoping this directly, the contract (or, if unpaid, a documented agreement) should cover:

- **Statement of Work per phase**, not one contract for the whole roadmap — tie payment milestones to the phase-1 MVP scope (auth, news, offline forms, point GPS tagging) rather than committing to phase-2 reporting/tracking before it's scoped.
- **Fixed price per phase** over time-and-materials, given BDS's charity budget needs cost certainty — T&M is more defensible only for genuinely open questions (e.g. whether continuous GPS tracking is needed for phase one).
- **IP assignment** — all code/design IP assigned to BDS on payment, not retained by the developer.
- **Data Processing Agreement** — non-optional given the GDPR stance and location-data sensitivity in the design doc's §8; must name Supabase/OneSignal as sub-processors, confirm EU/UK data residency, and set retention/deletion terms.
- **Acceptance criteria tied to the testing approach already adopted** — a phase isn't done (and its payment milestone isn't hit) until its tests exist and pass, not just when a demo looks right.
- **Separate maintenance/support agreement** post-launch, distinct from the build contract — OS updates, Flutter version bumps, and app store policy churn are recurring costs.
- **Warranty period** (commonly 30–90 days) covering post-launch defect fixes at no extra charge.
- If any part of the build is done by someone with another role at BDS (trustee, volunteer): a simple written IP-assignment/volunteer agreement even when unpaid, plus a conflict-of-interest disclosure if relevant.

None of the above is legal advice — have the actual contract, and especially the DPA, reviewed by a charity-sector-experienced solicitor before signature.
