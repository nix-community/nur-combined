---
name: ac:changelog
description: Produce evidence-based, user-facing release notes from a selected Git range and synchronize them across the repository's existing changelog targets without releasing or publishing.
---

# `/ac:changelog` — User-Facing Release Notes

Translate shipped behavior into clear release notes. Git history and the complete diff are evidence; commit wording is input, not final copy.

## Usage

```
/ac:changelog [from..to | version]
```

Without a range, infer the repository's next/latest release boundary from tags and the current changelog. If more than one interpretation is plausible, ask rather than selecting silently.

## Tone & Style

- Professional, clear, and upbeat.
- No emojis. Use plain text bullet points for multiple updates.
- Focus on the **benefit** to the user, not the technical implementation.
- **Prohibited jargon** in user-facing notes: API, backend, refactor, null pointer, latency, SQL, cache, and similar internals.

| Technical | User-Friendly |
| --- | --- |
| Optimized SQL queries for local DB | The app now loads your data more quickly |
| Resolved crash on deep-link intent | Improved stability when opening the app from links |
| Migrated auth flow to PKCE | Your login experience is now more secure |

Developer-facing changelogs (libraries, SDKs, CLIs) keep precise technical terms — the jargon ban applies to end-user release notes.

## Workflow

Activate `git-workflow` in `HISTORY`/`STATUS` mode and `technical-writing` for the notes themselves.

### 1. Resolve release evidence

Inspect release instructions, versioning policy, tags, the selected commit range, linked issues/PRs available locally or through the authorized Git host, and the full diff. Group changes by observable user impact. Exclude merge noise, generated-only churn, test-only refactors, and internal changes with no user-facing effect unless the project convention includes them.

### 2. Preserve the project's format

If `CHANGELOG.md` exists, follow its established format. When it uses Keep a Changelog, place entries only under **Added**, **Changed**, **Deprecated**, **Removed**, **Fixed**, or **Security**. Preserve headings, link references, ordering, version/date style, and unreleased sections.

### 3. Write benefit-driven copy

State what users can now do, what is more reliable, or what changed in a migration-relevant way. Avoid implementation jargon unless the audience is explicitly developer-facing. Do not claim performance, security, compatibility, or bug fixes without evidence in the range.

### 4. Synchronize existing platform targets

Detect rather than assume platform metadata:

- Android Fastlane: latest base-locale `changelogs/<version>.txt`, respecting the repository/store character limit (500 when no stricter local rule exists).
- iOS Fastlane locale `release_notes.txt` files.
- Existing `RELEASES.md`, appcast, package, or store metadata conventions.

Keep the same value proposition across targets. Translate only into locales you can render faithfully; otherwise retain the base language and report the gap.

### 5. Verify

Compare every claim against the selected range, check format and character limits, validate links, and review the final diff for duplicate or omitted material changes.

## Output

Report the resolved release range, changed files, categorized notes, excluded internal-only changes, validation performed, and localization gaps.

## Next Step

Close the turn by naming the delivery step, without performing it:

- Notes are complete and the branch is ready → `/ac:verify`, then `/ac:pr`
- Notes reference unverified claims → name them and stop
- Release requires tagging or publishing → state that this needs explicit authorization

Name exactly one recommendation. Never tag, publish, or release from this command.

## Boundaries

- Do not invent benefits, dates, versions, issue links, or release status.
- Do not create tags, bump versions, commit, push, publish, or release.
- Do not rewrite historical entries outside the selected release unless explicitly requested.
