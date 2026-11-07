# OpenCode OMO ahmet-cetinkaya configuration

The configuration has three relevant paths:

- Canonical source: `~/Configs/agent-ctrl/settings/omo/`
- Live target directory: `~/.config/opencode/.omo/`
- Compatibility link: `~/.omo/` -> `~/.config/opencode/.omo/`

`omo` is not an `agent-ctrl apply` platform (it lives outside `settings/opencode/` on purpose, since it configures the separate `oh-my-openagent` plugin, not OpenCode's own config), so its two tracked artifacts are symlinked directly into the live target instead of being copied by `agent-ctrl apply`:

- `~/.config/opencode/.omo/omo.jsonc` -> `~/Configs/agent-ctrl/settings/omo/omo.jsonc`
- `~/.config/opencode/.omo/custom_prompts` -> `~/Configs/agent-ctrl/settings/omo/custom_prompts`

Edit the canonical source directly; changes take effect immediately through the symlinks, no apply step needed. Everything else under `~/.config/opencode/.omo/` (`agent/`, `codegraph/`, `lsp-daemon/`, `memory/`, `prompts/`, `sessions/`, `settings.json`, `omo.jsonc.bak*`, etc.) is live runtime state for the standalone OMO CLI, not tracked in this repo, and must never be replaced by a symlink or overwritten. Restart OpenCode after changing agent prompts because config-time files are loaded at startup.

## Scope

The configuration is intentionally limited to `[opencode]` settings:

- Agent and category orchestration, including OmniRoute model routes.
- Complete local Sisyphus, Atlas, Explore, and Librarian prompts under `custom_prompts/`, pinned to the OMO version recorded in each file.
- Their `agents.<name>.prompt` settings use portable `file://~/.config/opencode/.omo/custom_prompts/` URIs and replace the corresponding upstream prompts rather than appending potentially conflicting instructions.
- `claude_code` disables importing Claude Code MCPs, commands, skills, hooks, and plugins.
- `git_master` prevents commit footers and `Co-authored-by` lines.
- `notification.force_enable` keeps OMO session notifications enabled.

## Backups and rollback

Existing global backups remain at `~/.omo/omo.jsonc.bak-*`. To roll back the active configuration, restore a chosen backup as `~/.omo/omo.jsonc`; keep the canonical source intact unless it is also being intentionally reverted.

## Local agent prompt customizations

The local prompts are complete replacements based on Oh My OpenAgent `v4.19.4` (`b072d279110bdda2c6ac2525d0d24dc54d16148a`). The goal is to preserve each agent's specialist responsibilities and quality gates while removing instructions that caused unnecessary delegation, broad searches, repeated reads, and redundant verification.

### Sisyphus

File: `custom_prompts/SISYPHUS.md`

Upstream baseline: the Claude Opus 5 Sisyphus prompt from `packages/omo-opencode/src/agents/sisyphus/claude-opus-5.ts`.

Changes:

- Replaced the general bias toward delegation with a smallest-sufficient-path decision: bounded, fully understood work is executed directly, while specialist domains and sizeable independent tracks are delegated.
- Removed automatic exploration based only on broad triggers such as mentioning an external library or touching multiple modules. Search and delegation now require a concrete information gap or meaningful parallel benefit.
- Added explicit stop conditions for exploration: stop when enough evidence exists, results repeat, a direct answer is found, or two iterations add no actionable information.
- Prevented duplicate research after an Explore or Librarian delegation and prohibited rereading unchanged files without a concrete reason.
- Reconciled verification into one risk-proportional pass against the stable delivered state. Passing diagnostics, tests, builds, and manual QA are reused while their scope and state remain valid.
- Removed verification-only subagent creation and repeated confirmation after green gates.
- Tightened scope control so the agent does not add speculative features, compatibility paths, unrelated refactors, or defensive code.
- Reduced routine narration to meaningful phase changes, blockers, and final evidence.

Preserved guarantees:

- Frontend and visual work still routes to the visual specialist.
- Architecture and multi-system trade-offs still require Oracle.
- Security, debugging, git, and other mandatory workflows still load their relevant skills.
- Multi-step implementation still uses a Plan Agent unless an approved Prometheus plan already exists.
- Approved plans, acceptance criteria, dependencies, and Final Verification Waves remain intact.
- Diagnostics, relevant tests, build/config validation, and real-surface QA remain completion gates where applicable.

### Atlas

File: `custom_prompts/ATLAS.md`

Upstream baseline: the Atlas `default` prompt from `packages/prompts-core/prompts/atlas/default.md`, selected by the configured Claude Sonnet 5 primary model.

Changes:

- Preserved Atlas as a delegation-only plan executor, but replaced indiscriminate parallel fan-out with dependency-aware batching. Tasks sharing files, decisions, or named inputs are serialized.
- Removed the minimum delegation-prompt length rule. Delegations still contain all six required contract sections, but their length now follows task complexity.
- Changed notepad handling from rereading before every delegation to reading relevant entries once per batch and passing only applicable inherited wisdom.
- Changed plan progress verification from a full plan reread after every task to one targeted read or checkbox count after each completed batch.
- Replaced project-wide diagnostics after every delegation with diagnostics on changed source files unless the plan or shared-interface risk requires broader coverage.
- Allowed one shared build or test run to satisfy multiple tasks in a stable batch when its scope covers all affected behavior.
- Added explicit reuse of valid verification evidence. Checks rerun only after relevant edits, failures, invalidated state, or an explicit fresh-run requirement.
- Added bounded failure recovery so repeated attempts must use new evidence and materially different approaches instead of retrying indefinitely.
- Added a strict completion stop: after all implementation tasks and the Final Verification Wave pass, Atlas does not launch optional agents, reread unchanged files, or rerun green checks.

Preserved guarantees:

- Atlas does not write application code, tests, documentation, or git changes itself.
- The approved Prometheus plan, acceptance criteria, dependency order, and Final Verification Wave remain authoritative.
- Each delegated task is checked against its own acceptance criteria before its top-level plan checkbox is marked complete.
- Changed files, diagnostics, tests, builds, and hands-on QA are still required at the depth appropriate to the change.
- Failed tasks remain incomplete and are resumed with their original continuation session ID and actual failure evidence.
- All required Final Verification Wave reviewers must approve.

### Explore

File: `custom_prompts/EXPLORE.md`

Upstream baseline: `packages/omo-opencode/src/agents/explore.ts`.

Changes:

- Removed the requirement to launch at least three tools in the first action.
- Removed the instructions to flood parallel calls and cross-validate every clear finding with multiple tools.
- Replaced the unconditional requirement to find every match with scoped retrieval. Exhaustive coverage is used only when requested or required for a migration, blast-radius analysis, or complete caller inventory.
- Added query-shape routing: CodeGraph or LSP for symbols and flows, text search for exact strings and configuration, ast-grep for syntax shapes, direct reads for known files, and git only for requested history.
- Added a single-tool fast path for known files, symbols, errors, and exact strings.
- Added a second-method gate: another search method is used only when the first result is incomplete, ambiguous, stale, or contradictory.
- Added explicit stop conditions after sufficient evidence, repeated results, or two unproductive iterations.
- Simplified output to relevant absolute paths, a direct answer or flow explanation, and material uncertainty only when one remains.

Preserved guarantees:

- Explore remains read-only and cannot implement or delegate work.
- It still cites concrete files and line ranges, distinguishes evidence from inference, and explains why each returned file matters.
- It can still perform exhaustive searches when the caller genuinely requires complete coverage.
- Negative results still identify the searched scope and patterns.

### Librarian

File: `custom_prompts/LIBRARIAN.md`

Upstream baseline: `packages/omo-opencode/src/agents/librarian.ts`.

Changes:

- Removed fixed four-call and six-call research quotas and the requirement to use all source channels for broad request categories.
- Replaced automatic documentation discovery plus web and GitHub searches with source-routed lookup.
- API, configuration, migration, and best-practice questions now use Context7 first and stop when it provides a clear current answer.
- Library-internals questions go directly to authoritative upstream source and stable commit permalinks.
- History and rationale questions use the relevant changelog, release, commit, issue, or pull request without cloning or surveying the whole repository by default.
- Public GitHub examples are searched only when requested, when official documentation is insufficient, or when real integration behavior must be demonstrated.
- Exact library IDs, URLs, repositories, versions, and commits supplied by the caller are reused instead of rediscovered.
- Removed mechanical current-year terms from every search; dates are used only when recency affects the answer.
- Added a one-source fast path, a concrete evidence-gap requirement before adding another channel, and a two-unproductive-iteration stop condition.
- Reduced output to a direct answer, necessary evidence, and material caveats only.

Preserved guarantees:

- Librarian remains read-only and focused on external libraries and open-source evidence.
- Version-matched official documentation remains the preferred source for public APIs.
- Source-level claims still use stable GitHub permalinks with commit SHAs and line ranges.
- Documented behavior, source-derived inference, and community convention remain explicitly distinguished.
- Multiple independent sources are still used for explicit comprehensive research, conflicting evidence, or questions one source cannot establish.

## Model variants and upgrades

A full `prompt` override is intentionally static. Runtime fallback models receive the same optimized local prompt instead of OMO selecting another model-family prompt. This has the largest compatibility implication for Sisyphus and Atlas, whose upstream prompts have model-specific variants; Explore and Librarian use more model-neutral specialist contracts.

Before upgrading OMO:

1. Compare the four local prompts with their recorded upstream sources at the new version.
2. Incorporate new safety, tool, and workflow contracts that still apply.
3. Reconcile new upstream instructions with the bounded-search and verification policies rather than appending another prompt.
4. Run `opencode debug agent` for all four agents and verify that the resolved prompts contain one coherent instruction set.

## Validate after editing

Run this from any shell to parse the JSONC without modifying it:

`npx --yes prettier "$HOME/Configs/agent-ctrl/settings/omo/omo.jsonc" >/dev/null && echo "Valid JSONC"`
