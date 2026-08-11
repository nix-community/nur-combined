---
name: ac:changelog
description: "Rewrite release notes into user-friendly language across CHANGELOG.md and platform-specific changelogs (Fastlane, etc.)."
category: workflow
complexity: standard
mcp-servers: []
personas: []
---

# `/ac:changelog` - User-Friendly Release Notes

Rewrite technical engineering logs into professional, benefit-driven release notes for end
users, across `CHANGELOG.md` and platform-specific changelogs (Fastlane, etc.).

## Usage

```bash
/ac:changelog   # scans project root and platform changelog dirs; rewrites the latest entry
```

## Tone & Style

* Professional, clear, and upbeat.
* No emojis. Use plain text bullet points for multiple updates.
* Focus on the **benefit** to the user, not the technical implementation.
* **Prohibited jargon:** API, Backend, Refactor, Null Pointer, latency, SQL, cache, etc.

| Technical | User-Friendly |
|---|---|
| Optimized SQL queries for local DB | The app now loads your data more quickly |
| Resolved crash on deep-link intent | Improved stability when opening the app from links |
| Migrated auth flow to PKCE | Your login experience is now more secure |

## Workflow

### 1. Improve CHANGELOG.md
If a `CHANGELOG.md` exists in the project root:
- Rewrite the latest version entry with user-friendly language.
- Follow the [Keep a Changelog](https://keepachangelog.com) specification strictly.
- Organize every change under the correct section: **Added**, **Changed**, **Deprecated**, **Removed**, **Fixed**, **Security**.
- Do not introduce new categories or deviate from the standard format.

### 2. Improve Platform-Specific Changelogs
Scan the project for platform-specific changelog directories. Detect the base locale from
the existing directory structure rather than assuming a fixed one; if none is found, skip
this step.

#### Fastlane (Android)
If `fastlane/metadata/android/` exists:
- Find the latest version file under the base-locale `changelogs/` directory (highest
  number, e.g. `102.txt`).
- Rewrite its content into user-friendly language.
- Keep content under 500 characters for mobile screen readability.
- Replicate the rewritten text across the other locale directories, translating naturally.
  Only translate into locales you can render faithfully; leave unfamiliar locales in the
  base language rather than guessing.

#### Fastlane (iOS)
If `fastlane/metadata/` contains iOS locale directories (e.g. `release_notes.txt`):
- Apply the same rewriting and localization strategy, detecting the base locale as above.

#### Other Platforms
If any other changelog format is detected (e.g. `.appcast.xml`, `RELEASES.md`), apply the same user-friendly rewriting principles.

### 3. Consistency Check
Ensure the messaging is consistent across all changelog targets. The same release should communicate the same value propositions everywhere.
