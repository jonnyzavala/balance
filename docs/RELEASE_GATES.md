# Release gates and mobile verification

## Every release
- Use fictional records in tests; never include a live owner key, session or personal records in source, logs, screenshots or fixtures.
- Run both Chromium and WebKit at 320/360/375/390/430 CSS-pixel phone widths, landscape, tablet and desktop; light/dark themes. Check document and form bounds, close controls, horizontal navigation, and interaction regressions. Keep the release marker, service-worker cache name, and UI version consistent.
- Test saved records and in-memory drafts separately. Drafts survive rerenders but not a killed browser process. Never silently replace unreadable storage or automatically resolve a conflict. Validate backups before replacement; make destructive actions explicit.
- Never report successful sync unless the server has confirmed the revision. Offline and revoked devices must not be described as synchronized.

## Native iPhone manual acceptance (not covered by desktop WebKit)
1. Open installed app from Home Screen, cold launch and foreground resume. Verify the top status strip, notch/Dynamic Island and home-indicator area in light/dark/automatic themes; rotate with a menu open. Native chrome is controlled partly by iOS.
2. With a long form open, show/hide keyboard, use date/time and numeric pickers, switch tabs and themes, then return. Confirm fields do not zoom unexpectedly or extend outside cards and unsaved text remains.
3. Save a fictional activity offline, fully close/reopen while offline, then reconnect. Verify cached shell, retained local event, pending state and confirmed sync. Verify a clean update after a new release; never delete the installation or clear site data to force it.
4. With two test devices, confirm pair/recover, distinct device list, offline conflict, explicit keep/load, revoke, and failed access after revocation. Verify the saved key privately in a password manager, never paste it into logs.
5. Export a fictional backup and island image using iOS share/save sheets; restore the backup only into a separate disconnected test context. Check reduced motion, large text, narrow screen and VoiceOver navigation.

## Privacy-sensitive feature gate
Current devices are owner-equivalent and local browser storage is not encrypted by Balance. A public source repository and separate Supabase project do not establish confidential clinical storage. Keep Sanctuary, sensitive journal entries, health integrations and partner-sharing UI disabled until boundaries are verified.
- Origin separation: deploy private-data UI to its own trusted origin (not merely another path under the same Pages origin). Existing local records and paired sessions require a deliberate export/recovery migration; never clear them automatically.
- Data separation: distinct owner-private and explicitly shared collections. A partner credential must be different from an owner pairing/recovery credential; the server derives authorization from verified identity, not a client-supplied role. Shared access should default to read-only and explicit grants. No complete owner snapshot or private fields in partner responses, even if UI hides them.
- Recovery and threat model: document loss/theft, shared-device access, XSS, revocation, session renewal, export sensitivity, and offline copies that cannot be remotely erased. Do not call storage encrypted unless encryption and key handling are implemented and tested. Avoid automated clinical interpretation.
- Verify with isolated synthetic accounts and negative server tests: unpaired access, revoked access, cross-workspace identifiers, partner attempting owner-only RPCs, private reads/writes, expired invitations and stale revisions. Never perform exploratory destructive testing against user records. Review security advisor findings and document residual risk.

## Provider features
City lookup/forecast and future calendar or health integrations require explicit user action and minimum necessary data. Browser fixture tests do not prove a live provider is reachable. Optional integrations should fail gracefully to manual operation; never use precise GPS or send journal data by default.
