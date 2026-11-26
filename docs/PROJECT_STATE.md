# Balance — current handoff
Updated 2026-11-25. Repository jonnyzavala/balance, main. URL https://jonnyzavala.github.io/balance/. User confirmed initial Pages deployment appeared; subsequent v0.4 live rendering is not independently verified (web open inaccessible).

## Committed v0.4 local release
- 2af3535f370155f55963d8942a367a827d16962e: bullet changelog, latest release visible, local/offline red sync indicator. CSS also defines flashing yellow/green syncing and solid green synced, but there is NO cloud client yet; green is not displayed falsely.
- 4589fae04dcfff3cb945007612c789f3cc427356: full/reduced/recovery foundation modes; configurable routines; once-per-day canonical activity records; household ownership five-stage workflow with optional repeat interval, next date and explicit restart.
- f83e9da3a02961cea9923c0b66005d43788159ef: rituals editable, pausable, snoozable for three days; suppressed on Today while paused/snoozed, still manageable in rituals tab.
- e3b8ed04820332513104a22a804c9bf92f4532ec: estimated cost/time/energy/indoor-outdoor adventure filters, existing inbox and calendar plan form retained; manual solar arc, home-before-dark buffer, five-second glow, Jasmine Dragon rain label, optional original chime.
- 5952fba96e097c2b3a2424b27aca5fbbb4549c41: White Lotus 19 functional milestone rules across all agreed fandoms; explicit optional SAROS reflection acknowledgment, no automatic inference of recovery; permanent awards in local state except undo of earning transaction/reset. Descriptive category counts and estimated sleep charts in Insights. Additional quick activities.
- 9dc6e117cbf2ffc4063353a9def6ae274780e152: offline cache version bumped to v0.4.
- a7b95f08e9e89a73f56b6da70eb91f3691bba659: spec updated for sync states and bullet changelogs.

## Verification
Simulated JavaScript DOM/storage checks passed: routine no duplicates, responsibility no duplicates, foundation/home render; ritual pause/snooze/edit and dashboard filtering; adventure constraints, plan/inbox retention, solar labeling, preferences and all tabs render; achievement earn/persistence, manual-only restoration, collection and insights render and all nine tabs. These are not real-browser end-to-end tests. Initial larger patch failed syntax validation before commit and was replaced by smaller passing patches. Existing local data key preserved and missing new fields defaulted. Actual browser, iPhone install, sound playback, offline reload and deployment of v0.4 still need testing.

## Backend blocker
Supabase list_projects returned only nauvis-command-center. Never use that database for Balance. Need a separate Balance project and explicit organization selection/cost authorization if creating through connector. No sync credentials, backend schema, cloud client, device registration or revocation implemented yet. No private journal until tested access controls; do not enter sensitive data into this prototype.

## Next priorities
1. Verify release in browser/mobile, check actual Pages source and service-worker update, fix any issues. 
2. Dedicated Supabase project, design/test owner-only access, device pairing/revocation and optimistic conflict handling with fictional data, then optional separately authorized partner-shared records. Wire actual server-confirmed sync status and offline recovery. Test isolation and revocation before sensitive use.
3. Real local astronomical calculation/city timezone and consented weather integration; better countdown/plan editing and home recurrence; more daily dashboard and custom activity controls.
4. Final koi artwork and faithful icon renders; archive versions. Existing v0.3 master and icon.svg use continuous spectrum exact cardinal colors, earlier PNGs provisional.
5. Pixel world customization/animation/export, richer achievements and collectible environments, additional insights and private Sanctuary, AI inbox and health/calendar integrations. Current pixel world is simple; no advanced animation, AI, live weather, health integrations or private journal.

Maintain documentation after meaningful sessions and verify actual source/runtime before claims. Public repository must contain no personal history or credentials.
