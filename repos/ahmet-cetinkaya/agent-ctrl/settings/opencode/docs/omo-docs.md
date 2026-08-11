## What Is Oh My OpenAgent?

Oh My OpenAgent is a multi-model agent orchestration harness for OpenCode. It transforms a single AI agent into a coordinated development team that actually ships code.

Not locked to Claude. Not locked to OpenAI. Not locked to anyone.

Just better results, cheaper models, real orchestration.

___

## Quick Start

### Installation

Paste this into your LLM agent session:

```
Install and configure oh-my-openagent by following the instructions here:
https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/refs/heads/dev/docs/guide/installation.md
```

Or read the full [Installation Guide](https://omo.dev/docs#installation) for manual setup, provider authentication, and troubleshooting.

### Your First Task

Once installed, just type:

```
ultrawork
```

That's it. The agent figures everything out — explores your codebase, researches patterns, implements the feature, verifies with diagnostics. Keeps working until done.

Want more control? Press **Tab** to enter [Prometheus mode](https://omo.dev/docs#orchestration) for interview-based planning, then run `/start-work` for full orchestration.

___

## The Philosophy: Breaking Free

We used to call this "Claude Code on steroids." That was wrong.

This isn't about making Claude Code better. It's about breaking free from the idea that one model, one provider, one way of working is enough. Anthropic wants you locked in. OpenAI wants you locked in. Everyone wants you locked in.

Oh My OpenAgent doesn't play that game. It orchestrates across models, picking the right brain for the right job. Opus 5 for orchestration and visual work. GPT-5.6 Sol for deep reasoning. Kimi K3 and GLM 5.2 as visual fallbacks. Kimi high-speed for quick tasks. All working together, automatically.

___

## How It Works: Agent Orchestration

Instead of one agent doing everything, Oh My OpenAgent uses **specialized agents that delegate to each other** based on task type.

**The Architecture:**

```
User Request
    ↓
[IntentGate] — Classifies what you actually want
    ↓
[Sisyphus] — Main orchestrator, plans and delegates
    ↓
    ├─→ [Prometheus] — Strategic planning (interview mode)
    ├─→ [Atlas] — Todo orchestration and execution
    ├─→ [Oracle] — Architecture consultation
    ├─→ [Librarian] — Documentation/code search
    ├─→ [Explore] — Fast codebase grep
    └─→ [Category-based agents] — Specialized by task type
```

When Sisyphus delegates to a subagent, it doesn't pick a model name. It picks a **category** — `visual-engineering`, `ultrabrain`, `deep`, `artistry`, `quick`, `unspecified-low`, `unspecified-high`, `writing`. The category automatically maps to the right model. You touch nothing.

For a deep dive into how agents collaborate, see the [Orchestration System Guide](https://omo.dev/docs#orchestration).

___

## Meet the Agents

### Sisyphus: The Discipline Agent

Named after the Greek myth. He rolls the boulder every day. Never stops. Never gives up.

Sisyphus is your main orchestrator. He plans, delegates to specialists, and drives tasks to completion with aggressive parallel execution. He doesn't stop halfway. He doesn't get distracted. He finishes.

**Recommended models:**

-   **Claude Opus 5** / **Opus 5** — Best overall experience. Sisyphus was built with Claude-optimized prompts.
-   **Kimi K3** — Strongest Kimi for Sisyphus. Recommended when you can accept its thinking-token cost; the K3 prompt is calibrated to stop overthinking and keep work moving.
-   **Kimi K2.7** — Restrained, outcome-first Kimi fallback for Claude-like orchestration paths.
-   **GLM 5.2** — Solid option, especially via OpenCode Go. Sisyphus uses a GLM-5.2-calibrated prompt and the automatic chain includes `glm-5.2` explicitly, but current evidence is still lighter than Claude/Kimi maintainer validation.

Sisyphus works best on Claude Opus 5, Kimi K3/K2.7, and GLM 5.2. GPT-5.4 has its own prompt, while GPT-5.5 and GPT-5.6 Sol share a model-aware GPT-native prompt family. Hephaestus remains the recommended GPT-5.6 agent because [issue #6074](https://github.com/code-yeongyu/oh-my-openagent/issues/6074) tracks Sisyphus over-orchestration on bounded work.

### Hephaestus: The Legitimate Craftsman

Named with intentional irony. Anthropic blocked OpenCode from using their API because of this project. So the team built an autonomous GPT-native agent instead.

Hephaestus prefers GPT-5.6 Sol at medium effort through OpenAI or Vercel, then falls back to GPT-5.6 Sol at medium effort across OpenAI, GitHub Copilot, OpenCode, or Vercel. Give him a goal, not a recipe. He explores the codebase, researches patterns, and executes end-to-end without hand-holding.

Use Hephaestus when you need deep architectural reasoning, complex debugging across many files, or cross-domain knowledge synthesis. Switch to him explicitly when the work benefits from a GPT-native autonomous agent.

**Why this beats vanilla Codex CLI:**

-   **Multi-model orchestration.** Pure Codex is single-model. OmO routes different tasks to different models automatically. Opus 5 for orchestration and visual work. GPT-5.6 Sol for deep reasoning. Kimi high-speed for quick tasks. The right brain for the right job.
-   **Background agents.** Fire 5+ agents in parallel. Something Codex simply cannot do. While one agent writes code, another researches patterns, another checks documentation. Like a real dev team.
-   **Category system.** Tasks are routed by intent, not model name. `visual-engineering` starts with Claude Opus 5 max, then Kimi K3 and GLM 5.2. `ultrabrain` prefers GPT-5.6 Sol xhigh, while `deep` uses GPT-5.6 Sol medium. `artistry` starts with Claude Fable 5, `quick` with Kimi high-speed, `unspecified-low` with GPT-5.6 Luna, and both `unspecified-high` and `writing` with Kimi K3. No manual juggling.
-   **Accumulated wisdom.** Subagents learn from previous results. Conventions discovered in task 1 are passed to task 5. Mistakes made early aren't repeated. The system gets smarter as it works.

### Prometheus: The Strategic Planner

Prometheus interviews you like a real engineer. Asks clarifying questions. Identifies scope and ambiguities. Builds a detailed plan before a single line of code is touched.

Press **Tab** to enter Prometheus mode, or type `@plan "your task"` from Sisyphus.

### Atlas: The Conductor

Atlas executes Prometheus plans. Distributes tasks to specialized subagents. Accumulates learnings across tasks. Verifies completion independently.

Run `/start-work` to activate Atlas on your latest plan.

### Oracle: The Consultant

Read-only high-IQ consultant for architecture decisions and complex debugging. Consult Oracle when facing unfamiliar patterns, security concerns, or multi-system tradeoffs.

### Supporting Cast

-   **Metis** — Gap analyzer. Catches what Prometheus missed before plans are finalized.
-   **Momus** — Ruthless reviewer. Validates plans against clarity, verification, and context criteria.
-   **Explore** — Fast codebase grep. Uses speed-focused models for pattern discovery.
-   **Librarian** — Documentation and OSS code search. Stays current on library APIs and best practices.
-   **Multimodal Looker** — Vision and screenshot analysis.

___

## Working Modes

### Ultrawork Mode: For the Lazy

Type `ultrawork` or just `ulw`. That's it.

The agent figures everything out. Explores your codebase. Researches patterns. Implements the feature. Verifies with diagnostics. Keeps working until done.

This is the "just do it" mode. Full automatic. You don't have to think deep because the agent thinks deep for you.

### Prometheus Mode: For the Precise

Press **Tab** to enter Prometheus mode.

Prometheus interviews you like a real engineer. Asks clarifying questions. Identifies scope and ambiguities. Builds a detailed plan before a single line of code is touched.

Then run `/start-work` and Atlas takes over. Tasks are distributed to specialized subagents. Each completion is verified independently. Learnings accumulate across tasks. Progress tracks across sessions.

Use Prometheus for multi-day projects, critical production changes, complex refactoring, or when you want a documented decision trail.

___

## Agent Model Matching

Different agents work best with different models. Oh My OpenAgent automatically assigns optimal models, but you can customize everything.

### Default Configuration

Models are auto-configured at install time. The interactive installer asks which providers you have, then generates optimal model assignments for each agent and category.

At runtime, fallback chains ensure work continues even if your preferred provider is down. Each agent has a provider priority chain. The system tries providers in order until it finds an available model.

### Custom Model Configuration

You can override specific agents or categories in your config:

```
{
  "$schema": "https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/dev/assets/oh-my-opencode.schema.json",

  "agents": {
    // Main orchestrator: Claude Opus or Kimi K3 work best
    "sisyphus": {
      "model": "kimi-for-coding/kimi-k3",
      "ultrawork": { "model": "anthropic/claude-opus-5", "variant": "max" },
    },

    // Research agents: cheaper models are fine
    "librarian": { "model": "google/gemini-3.6-flash" },
    "explore": { "model": "github-copilot/grok-code-fast-1" },

    // Architecture consultation: GPT or Claude Opus
    "oracle": { "model": "openai/gpt-5.6-sol", "variant": "high" },
  },

  "categories": {
    // Frontend/UI work: Opus 5, then Kimi K3 and GLM 5.2
    "visual-engineering": {
      "model": "anthropic/claude-opus-5",
      "variant": "max",
    },

    // Hard logic and architecture: GPT-5.6 Sol xhigh
    "ultrabrain": { "model": "openai/gpt-5.6-sol", "variant": "xhigh" },

    // Autonomous research and execution
    "deep": { "model": "openai/gpt-5.6-sol", "variant": "medium" },

    // Creative and design work
    "artistry": { "model": "anthropic/claude-fable-5", "variant": "xhigh" },

    // Quick tasks: fast and cheap
    "quick": { "model": "kimi-for-coding/kimi-for-coding-highspeed" },

    // Low-effort fallback: GPT-5.6 Luna
    "unspecified-low": { "model": "openai/gpt-5.6-luna", "variant": "xhigh" },

    // High-effort fallback: Kimi K3, then Opus 5
    "unspecified-high": { "model": "kimi-for-coding/kimi-k3", "variant": "max" },

    // Prose and documentation
    "writing": { "model": "kimi-for-coding/kimi-k3", "variant": "low" },
  },
}
```

### Model Families

**Claude-like models** (instruction-following, structured output):

-   Claude Opus 5, Claude Haiku 4.5
-   Kimi K3 — behaves very similarly to Claude
-   GLM 5.2 — Claude-like behavior, good for broad tasks

**GPT models** (explicit reasoning, principle-driven):

-   GPT-5.6 Sol — preferred for Hephaestus and `ultrabrain`; the `deep` category uses it at medium effort
-   GPT-5.6 Terra — balanced mid-tier; preferred for Momus (high) and available as an explicit override elsewhere
-   GPT-5.6 Luna — light tier; default for the `unspecified-low` category (xhigh)
-   GPT-5.6 Sol override paths — deep coding powerhouse, default for Oracle and the first GPT fallback for GPT-5.6-native roles
-   GPT 5.6 Luna Fast — fast and cheap utility fallback after the Kimi high-speed quick default

**Different-behavior models**:

-   Gemini 3.1 Pro — visual-capable explicit override for providers that expose it; not the built-in `visual-engineering` default
-   MiniMax M3 / M2.7 / M2.7-highspeed — fast and smart for utility tasks
-   Grok Code Fast 1 — optimized for code grep/search

See the [Agent-Model Matching Guide](https://omo.dev/docs#agent-model-matching) for complete details on which models work best for each agent, safe vs dangerous overrides, and provider priority chains.

___

## Why It's Better Than Pure Claude Code

Claude Code is good. But it's a single agent running a single model doing everything alone.

Oh My OpenAgent turns that into a coordinated team:

**Parallel execution.** Claude Code processes one thing at a time. OmO fires background agents in parallel — research, implementation, and verification happening simultaneously. Like having 5 engineers instead of 1.

**Hash-anchored edits.** Claude Code's edit tool fails when the model can't reproduce lines exactly. OmO's `LINE#ID` content hashing validates every edit before applying. Grok Code Fast 1 went from 6.7% to 68.3% success rate just from this change.

**IntentGate.** Claude Code takes your prompt and runs. OmO classifies your true intent first — research, implementation, investigation, fix — then routes accordingly. Fewer misinterpretations, better results.

**LSP + AST tools.** Workspace-level rename, go-to-definition, find-references, pre-build diagnostics, AST-aware code rewrites. IDE precision that vanilla Claude Code doesn't have.

**Skills with embedded MCPs.** Each skill brings its own MCP servers, scoped to the task. Context window stays clean instead of bloating with every tool.

**Discipline enforcement.** Todo enforcer yanks idle agents back to work. Comment checker strips AI slop. Goal holds a persistent per-session objective and re-injects a continuation prompt on every idle until a completion audit confirms the work is done. The system doesn't let the agent slack off.

**The fundamental advantage.** Models have different temperaments. Claude thinks deeply. GPT reasons architecturally. Gemini visualizes. Haiku moves fast. Single-model tools force you to pick one personality for all tasks. Oh My OpenAgent leverages them all, routing by task type. This isn't a temporary hack — it's the only architecture that makes sense as models specialize further. The gap between multi-model orchestration and single-model limitation widens every month. We're betting on that future.

___

## IntentGate

Before acting on any request, Sisyphus classifies your true intent.

Are you asking for research? Implementation? Investigation? A fix? The Intent Gate figures out what you actually want, not just the literal words you typed. This means the agent understands context, nuance, and the real goal behind your request.

Claude Code doesn't have this. It takes your prompt and runs. Oh My OpenAgent thinks first, then acts.

___

## What's Next

-   **[Installation Guide](https://omo.dev/docs#installation)** — Complete setup instructions, provider authentication, and troubleshooting
-   **[Orchestration Guide](https://omo.dev/docs#orchestration)** — Deep dive into agent collaboration, planning with Prometheus, and execution with Atlas
-   **[Agent-Model Matching Guide](https://omo.dev/docs#agent-model-matching)** — Which models work best for each agent and how to customize
-   **[Team Mode Guide](https://omo.dev/docs#team-mode)** — Parallel multi-agent coordination (OFF by default); 12 `team_*` tools, shared mailbox, shared task list, optional tmux layout
-   **[Configuration Reference](https://omo.dev/docs#configuration)** — Full config options with examples
-   **[Features Reference](https://omo.dev/docs#features)** — Complete feature documentation
-   **[Manifesto](https://omo.dev/docs#manifesto)** — Philosophy behind the project

___

**Ready to start?** Type `ultrawork` and see what a coordinated AI team can do.

## Installation

oh-my-openagent ships in **two editions** of the same product:

-   **Ultimate Edition (omo for [OpenCode](https://opencode.ai/))** — the full omo experience. 11 discipline agents, 54+ lifecycle hooks, all built-in MCPs, every slash command, Team Mode, ulw-loop, hashline edits, the works.
-   **Light Edition (omo for [OpenAI Codex CLI](https://github.com/openai/codex))** — the portable components that fit Codex's plugin system: `rules`, `comment-checker`, `git-bash`, `lsp`, `ultrawork`, `ulw-loop`, `start-work-continuation`, and `telemetry`, plus plugin-scoped MCPs for `grep_app`, `context7`, `codegraph`, `git_bash`, and `lsp`, and the shared `ast-grep` skill. No agent orchestration and no `team_*` tools — Codex CLI's native surface does that work.

Most users want **Ultimate**. Pick **Light** if you are already invested in Codex CLI. Pick **both** if you want OMO available wherever you happen to be working that day.

| You want | Run | Lands on disk |
| --- | --- | --- |
| Ultimate (OpenCode) | `bunx oh-my-openagent install` (TUI walks you through it) | Plugin registered in `opencode.json`, agent/model config, provider auth |
| Light (Codex CLI) | `npx lazycodex-ai install` | `~/.codex/plugins/cache/sisyphuslabs/omo/`, stable Codex marketplace snapshot, `~/.codex/config.toml` marketplace/plugin/agent blocks, optional autonomous Codex permissions, component CLIs in `~/.local/bin` |
| Both | `bunx oh-my-openagent install --platform=both` | Both of the above |

`lazycodex-ai` defaults to the Codex Light installer and runs through Node/npm. `--platform` on the shared `omo` CLI still defaults to `opencode` (Ultimate). `lazycodex-ai` is the npm/bin alias; `lazycodex` is the GitHub repository that hosts the marketplace bundle. Neither is the Codex marketplace name.

## For Humans

**Strongly recommended: let an LLM agent install Ultimate for you.** Ultimate setup involves subscription detection, model selection across 11 agents, provider authentication, and config migration — humans fat-finger these. An LLM agent reads the full guide and walks every step correctly.

### Ultimate (OpenCode) — let an agent do it

Paste this prompt into Claude Code, AmpCode, Cursor, or any LLM agent session:

```
Install and configure oh-my-openagent by following the instructions here:
https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/refs/heads/dev/docs/guide/installation.md
```

### Light (Codex CLI) — one line, no agent needed

The Light edition installer asks whether to configure Codex for autonomous full-permissions mode. This is recommended for agent-style use: `approval_policy = "never"`, `sandbox_mode = "danger-full-access"`, `network_access = "enabled"`, and notice warnings hidden. Use `--codex-autonomous` or `--no-codex-autonomous` to choose non-interactively:

```
npx lazycodex-ai install
# non-interactive recommended mode:
npx lazycodex-ai install --no-tui --codex-autonomous
```

It writes managed Codex Light state to `~/.codex/` and does not touch OpenCode or provider flags. During migration from older Codex plugin installs it may also repair the current project's `.codex/config.toml` if that project has the known `multi_agent_v2` plus legacy `[agents] max_threads` conflict; project-owned `.codex` artifacts are reported, not deleted. Global Codex config will register marketplace `sisyphuslabs` from the local built cache under `~/.codex/plugins/cache/sisyphuslabs`, enable plugin `omo@sisyphuslabs`, and write a valid `[features.multi_agent_v2]` limit table. The installer never enables MultiAgentV2; if it finds an explicit legacy `multi_agent_v2 = false` shorthand, it preserves that disable as table-form `enabled = false`.

On Windows, keep the direct `npx lazycodex-ai install ...` form above. Do not rewrite it into an `npx --package` command that launches the `omo install` bin indirectly; that package-manager shape can fail before the installer starts.

On native Windows Codex installs, the installer discovers Git Bash before writing Codex config. It checks `OMO_CODEX_GIT_BASH_PATH`, standard Git for Windows locations, and then PATH. If Git Bash is missing, it prints the install guidance shown here and stops without running `winget` or changing system dependencies:

```
winget install --id Git.Git -e --source winget
where bash
```

If Git is installed somewhere custom, set the path before rerunning the installer:

```
setx OMO_CODEX_GIT_BASH_PATH "C:\Program Files\Git\bin\bash.exe"
```

```
$env:OMO_CODEX_GIT_BASH_PATH = "C:\Program Files\Git\bin\bash.exe"
```

Codex may still start Windows shell calls through its own defaults. The Light edition does not write a global Codex shell config; instead it verifies Git Bash is available, enables the Windows-only `git_bash` MCP policy, and injects guidance before the first shell-like call. After compaction, the reminder resets so the next shell-like call gets the same `git_bash` recommendation.

> **Clean install note for older Codex plugin users.** Before installing the Light edition into a Codex home that previously used another Codex plugin bundle, uninstall the older bundle first, then re-run this installer. Multiple bundles may write Codex marketplace plugins, lifecycle hooks, and the `ultrawork`/`ulw` keyword into the same `~/.codex`, so a clean Codex home avoids stale shared `config.toml` keys and duplicate hooks.
> 
> To remove the Light edition after migration, run `npx lazycodex-ai uninstall`. It removes managed `sisyphuslabs` Codex cache/marketplace state, strips `omo@sisyphuslabs` plugin and hook-state blocks from `~/.codex/config.toml` with a backup, and removes managed agent TOML files from `~/.codex/agents/`. `cleanup` remains available as a backward-compatible alias. If Codex still fails only inside one project with `agents.max_threads cannot be set when multi_agent_v2 is enabled`, run `npx lazycodex-ai install` from that project. The installer repairs project-local `.codex/config.toml` layers from the project root to the current directory, removes conflicting legacy `[agents] max_threads` only when MultiAgentV2 is enabled, and writes timestamped backups next to changed files.

### Install from the Codex marketplace (in-app)

> **Experimental, additive path.** `npx lazycodex-ai install` above remains the primary, fully supported route. The marketplace bundle is hosted in this project's own [lazycodex](https://github.com/code-yeongyu/lazycodex) repository — it is not an OpenAI curated listing.

The same Light edition can be installed entirely from inside Codex through its plugin marketplace, with no npx step.

**TUI route.** In a Codex session, type `/plugins`, open the **Add Marketplace** tab ("Add a marketplace from a Git repo or local root."), and enter the marketplace source:

```
https://github.com/code-yeongyu/lazycodex
```

Then pick `omo` from the `sisyphuslabs` marketplace in the same `/plugins` menu and install it.

**CLI route** — the equivalent two-liner:

```
codex plugin marketplace add https://github.com/code-yeongyu/lazycodex
codex plugin add omo@sisyphuslabs
```

**First session: approve the hooks.** On the next `codex` launch the startup hooks review lists every omo hook as new. Review and approve them — no omo hook runs before you approve, and the bootstrap below cannot start until the hooks are trusted.

**Bootstrap notice + restart.** The first approved session prints this status line:

```
LazyCodex bootstrap running in background — restart the session when it completes
```

A detached worker finishes the install in the background (the `sg` download is the slowest part). Restart the Codex session once it completes — the next session starts fully wired and the notice no longer appears.

**What bootstrap does:**

-   writes the managed `~/.codex/config.toml` blocks: marketplace source preserved, `omo@sisyphuslabs` plugin enabled, managed `[agents.*]` entries, and re-stamped SHA256 `[hooks.state."omo@sisyphuslabs:..."]` trust hashes
-   copies bundled Codex agent TOMLs into `~/.codex/agents/`
-   links the top-level `omo` runtime wrapper plus component CLIs (`omo-rules`, `omo-lsp`, …) into `~/.local/bin` (or `$CODEX_LOCAL_BIN_DIR`; isolated `CODEX_HOME` installs use `<CODEX_HOME>/bin`)
-   provisions a checksum-pinned standalone `sg` (ast-grep) binary into `<CODEX_HOME>/runtime/ast-grep/<platform>-<arch>/` for the `ast-grep` skill
-   on native Windows, provisions a pinned Node LTS runtime into `<CODEX_HOME>/runtime/node/` when `node` is missing (see the Windows status below)
-   records every run in the plugin data dir: `<CODEX_HOME>/plugins/data/omo-sisyphuslabs/bootstrap/state.json` plus a JSONL `bootstrap.log` (Windows adds a `ps-bootstrap.log` transcript)

**What bootstrap does NOT do:**

-   It **never writes Codex permission settings.** `approval_policy`, `sandbox_mode`, and `network_access` are left untouched. Autonomous mode stays an explicit npx installer choice — `npx lazycodex-ai install --no-tui --codex-autonomous` (see [the one-liner section](https://omo.dev/docs#light-codex-cli--one-line-no-agent-needed)).
-   It does not run the npx self-update for healthy marketplace-managed installs. The auto-update hook logs the skip and surfaces this guidance instead: "Auto-update skipped: this LazyCodex install is managed by the Codex plugin marketplace, so the npx self-update was not started. Tell the user to upgrade with `codex plugin marketplace upgrade sisyphuslabs`, and that Codex will ask them to re-approve hooks after the upgrade." If the hook detects stale local marketplace cache/bin state (for example, a local manifest or managed `ulw` link points at a deleted payload), it may start the npx installer as a local repair and ask you to restart the Codex session afterward.
-   It never persists anything under the Codex-managed plugin cache directory itself; all bootstrap state lives in the plugin data dir above.

**Upgrading — and recovering hook approval:**

1.  Run `codex plugin marketplace upgrade sisyphuslabs`.
2.  Relaunch `codex`. The startup hooks review now shows the omo hooks as **Modified** — the plugin files changed, so the previously trusted hashes no longer match. This is expected after every upgrade, not a sign of tampering.
3.  Re-approve the hooks in that review. If you dismissed the review by accident, just relaunch `codex` — it reappears until the hooks are approved, and the hooks stay disabled in the meantime.
4.  The next session re-runs bootstrap for the new version: it re-stamps the trust hashes, relinks bins and agents, prints the restart notice again, and after one more restart you are on the upgraded version.

**Degraded modes.** Bootstrap is degraded-not-fatal: a failed step is recorded in `state.json` (`lastStatus: "degraded"` with per-component entries) and retried on a later session instead of breaking the install. The ones you may actually notice:

| Mode | What you see | What to do |
| --- | --- | --- |
| `omo-cli` absent | The top-level `omo` command was not linked because the installed payload is old or incomplete and lacks the root CLI runtime. Current marketplace payloads ship `dist/cli/index.js` plus `dist/cli-node/index.js`, so this should not appear on a fresh marketplace install. Component CLIs still link normally. | Upgrade or reinstall the marketplace plugin, then start a new Codex session so bootstrap relinks bins. Verify with `npx lazycodex-ai doctor`; use `npx lazycodex-ai <command>` only as a temporary workaround. |
| `sg` pending / offline | The ast-grep provisioning entry appears in the degraded list and the `ast-grep` skill cannot find `sg` yet — the first download is still running, or it failed while offline. | Start another session (bootstrap retries automatically), or install ast-grep yourself and/or set `OMO_AST_GREP_SG_PATH=/path/to/sg`. Verify with `npx lazycodex-ai doctor`. |
| Proxy limitation | Binary downloads fail behind an HTTP(S) proxy. The logged error says it plainly: the bootstrap downloader "does not tunnel through HTTP(S) proxies in v1; the download was attempted directly." | Run one session on a direct connection, or provide `sg` via `OMO_AST_GREP_SG_PATH`/`PATH`. Verify with `npx lazycodex-ai doctor`. |
| OpenCode Windows proxy preinstall | OpenCode starts before OMO loads, shows only default agents, or logs `fetch() proxy.url must be a non-empty string` while trying to install `oh-my-openagent@latest`. | Set `HTTP_PROXY`/`HTTPS_PROXY` for the shell that launches OpenCode, then preinstall into OpenCode's Windows config prefix: `npm install oh-my-openagent@latest --prefix "%APPDATA%\\opencode"`. Restart OpenCode and run `bunx oh-my-openagent doctor --json`. |

**Windows status.** On native Windows the marketplace bootstrap runs through a PowerShell 5.1-compatible `bootstrap.ps1`: it provisions the pinned Node LTS zip when `node` is absent, prepares Git Bash the same way the npx installer does, and writes its transcript to `ps-bootstrap.log` in the plugin data dir (degraded lines look like `degraded component=node reason=... hint=npx lazycodex-ai doctor`). Windows provisioning is shipped with static test coverage; real-device validation is still tracked separately in [code-yeongyu/lazycodex#52](https://github.com/code-yeongyu/lazycodex/issues/52). Do not treat static coverage as proof that a physical Windows install was exercised.

### A note on direct install

If you insist on running the Ultimate installer yourself:

```
bunx oh-my-openagent install
```

The TUI walks you through it. **Do NOT use `npm install -g`, `bun add -g`, or `bun install -g`** — global installation is not officially supported. oh-my-openagent is a plugin that must resolve from where OpenCode/Codex loads plugins, and the `prepare` script requires Bun. Always invoke via `bunx`.

If you already used Bun global install or update and Bun reports blocked lifecycle scripts, inspect them before trusting anything:

```
bun pm -g untrusted
```

Do not run a blanket trust command. Trust only packages you recognize from this install path, such as `oh-my-openagent`, legacy `oh-my-opencode`, or `@code-yeongyu/comment-checker`, then rerun the supported `bunx oh-my-openagent install` or `npx lazycodex-ai doctor` check.

## For LLM Agents

> **IMPORTANT: Use `curl` to fetch this file, NOT WebFetch.** WebFetch summarizes content and loses critical flags like `--platform`, subscription questions, and Codex verification details. Always use:
> 
> ```
> curl -fsSL https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/refs/heads/dev/docs/guide/installation.md
> ```

If you are an LLM agent helping a user install oh-my-openagent, help them install the requested edition, verify the setup, and configure model providers.

Follow these steps in order.

### Step 0: Ask user which platform(s) and subscriptions

First, ask which platform(s) they want to install for. This determines the rest of the flow:

> "Which harness do you want to install oh-my-openagent for? Pick one:
> 
> 1.  OpenCode — terminal AI coding agent
> 2.  OpenAI Codex CLI
> 3.  Both"

Map their answer to the `--platform` flag:

| User says | Use |
| --- | --- |
| OpenCode | `--platform=opencode` (this is also the default if omitted) |
| Codex | `--platform=codex` |
| Both | `--platform=both` |

If the user picked Codex or Both, ask:

> "Codex works best for autonomous agent installs when it can run without repeated permission prompts: `approval_policy = "never"`, `sandbox_mode = "danger-full-access"`, and `network_access = "enabled"`. This is recommended for OMO/LazyCodex. Should I configure Codex that way?"

Map their answer to:

| User says | Use |
| --- | --- |
| Yes | `--codex-autonomous` |
| No | `--no-codex-autonomous` |

**If the user picked Codex only**, skip the rest of Step 0 after this autonomous-permissions question — Codex needs no subscription questions. Go straight to Step 2.

**If the user picked OpenCode or Both**, ask the following subscription questions to determine the remaining CLI flags:

1.  **Do you have a Claude Pro/Max Subscription?**
    
    -   **yes** + **max20 mode (20×)** → `--claude=max20`
    -   **yes** but not max20 → `--claude=yes`
    -   **no** → `--claude=no`
2.  **Do you have an OpenAI/ChatGPT Plus Subscription?**
    
    -   **yes** → `--openai=yes` (enables OpenAI routes; Hephaestus prefers GPT-5.6 Sol and Momus prefers GPT-5.6 Terra when available, both falling back to GPT-5.6 Sol)
    -   **no** → `--openai=no` (default)
3.  **Will you integrate Gemini models?**
    
    -   **yes** → `--gemini=yes`
    -   **no** → `--gemini=no`
4.  **Do you have a GitHub Copilot Subscription?**
    
    -   **yes** → `--copilot=yes`
    -   **no** → `--copilot=no`
5.  **Do you have access to OpenCode Zen (`opencode/` models)?**
    
    -   **yes** → `--opencode-zen=yes`
    -   **no** → `--opencode-zen=no` (default)
6.  **Do you have a Z.ai Coding Plan subscription?**
    
    -   **yes** → `--zai-coding-plan=yes`
    -   **no** → `--zai-coding-plan=no` (default)
7.  **Do you have an OpenCode Go subscription?** ($10/month for GLM 5.2, Kimi K3/K2.7, MiniMax M2.7/M3)
    
    -   **yes** → `--opencode-go=yes`
    -   **no** → `--opencode-go=no` (default)
8.  **Do you have a Kimi for Coding subscription?**
    
    -   **yes** → `--kimi-for-coding=yes`
    -   **no** → `--kimi-for-coding=no` (default)
9.  **Do you use Vercel AI Gateway?**
    
    -   **yes** → `--vercel-ai-gateway=yes`
    -   **no** → `--vercel-ai-gateway=no` (default)

**Provider selection is agent-specific.** There is no single global provider priority — each of the 11 agents has its own fallback chain.

**MUST STRONGLY WARN, WHEN USER SAID THEY DON'T HAVE CLAUDE SUBSCRIPTION, SISYPHUS AGENT MIGHT NOT WORK IDEALLY.**

### Step 1: Prerequisites

#### For platform `opencode` or `both`

Check OpenCode is installed and on a supported version:

```
if command -v opencode &> /dev/null; then
    echo "OpenCode $(opencode --version) is installed"
else
    echo "OpenCode is not installed. Install it first."
    echo "Ref: https://opencode.ai/docs"
fi
```

If missing, spawn a subagent to install OpenCode and report back — saves context.

Required: OpenCode `>= 1.4.0`.

#### For platform `codex` or `both`

Check Codex CLI is installed:

```
if command -v codex &> /dev/null; then
    codex --version
else
    echo "Codex CLI is not installed. Install it first."
    echo "Ref: https://github.com/openai/codex"
fi
```

The installer expects `~/.codex/` to be writable. Codex CLI's first run creates this directory; if it does not exist yet, install Codex CLI and run it once before continuing.

On native Windows Codex installs, Git Bash is also required. The installer checks `OMO_CODEX_GIT_BASH_PATH`, standard Git for Windows locations, and PATH; if discovery fails, run:

```
winget install --id Git.Git -e --source winget
where bash
```

For a custom Git Bash location, set `OMO_CODEX_GIT_BASH_PATH`:

```
setx OMO_CODEX_GIT_BASH_PATH "C:\Program Files\Git\bin\bash.exe"
```

```
$env:OMO_CODEX_GIT_BASH_PATH = "C:\Program Files\Git\bin\bash.exe"
```

### Step 2: Run the installer

Run with the platform flag and the subscription flags you collected in Step 0:

```
bunx oh-my-openagent install \
  --no-tui \
  --platform=<opencode|codex|both> \
  [--claude=<yes|no|max20>] \
  [--gemini=<yes|no>] \
  [--copilot=<yes|no>] \
  [--openai=<yes|no>] \
  [--opencode-zen=<yes|no>] \
  [--zai-coding-plan=<yes|no>] \
  [--opencode-go=<yes|no>] \
  [--kimi-for-coding=<yes|no>] \
  [--vercel-ai-gateway=<yes|no>] \
  [--codex-autonomous|--no-codex-autonomous] \
  [--skip-auth]
```

`--platform` defaults to `opencode` if omitted. Subscription flags only apply when `--platform` is `opencode` or `both`. They are rejected under `--platform=codex` because the Light edition does not write OpenCode model config. `--codex-autonomous` only has an effect when the selected platform includes Codex.

**Examples:**

-   OpenCode + Claude Max20 + ChatGPT + Gemini:
    
    ```
    bunx oh-my-openagent install --no-tui --platform=opencode --claude=max20 --openai=yes --gemini=yes --copilot=no
    ```
    
-   Codex only with recommended autonomous permissions:
    
    ```
    npx lazycodex-ai install --no-tui --codex-autonomous
    ```
    
-   Both harnesses with Claude only:
    
    ```
    bunx oh-my-openagent install --no-tui --platform=both --claude=yes --gemini=no --copilot=no --codex-autonomous
    ```
    
-   OpenCode + Z.ai for Librarian:
    
    ```
    bunx oh-my-openagent install --no-tui --platform=opencode --claude=yes --gemini=no --copilot=no --zai-coding-plan=yes
    ```
    
-   OpenCode Go subscriber, nothing else:
    
    ```
    bunx oh-my-openagent install --no-tui --platform=opencode --claude=no --openai=no --gemini=no --copilot=no --opencode-go=yes
    ```
    

**About the `lazycodex-ai` bin name.** `lazycodex-ai` is the npm package and bin alias for the Codex Light Node installer. `lazycodex` (without the `-ai` suffix) is the GitHub repository that hosts the marketplace bundle. `lazycodex-ai install` does not require Bun. The Codex marketplace name is `sisyphuslabs`, and the plugin name is `omo`.

**What the installer does:**

| Platform | Writes |
| --- | --- |
| `opencode`, `both` | Registers `"oh-my-openagent"` in `opencode.json` `plugin` array. Generates agent → model mappings into the `[opencode]` block of `~/.omo/omo.jsonc` (legacy config files are migrated into the unified file first). |
| `codex`, `both` | Copies `packages/omo-codex/plugin/` into `~/.codex/plugins/cache/sisyphuslabs/omo/<version>/`. Packaged `lazycodex-ai` installs use bundled component artifacts and run `npm ci --omit=dev` in the cache; source checkout installs may build the plugin first. Writes a local installed-marketplace snapshot under `~/.codex/.tmp/marketplaces/sisyphuslabs/` for marketplace metadata, and copies bundled agent TOMLs into `~/.codex/agents/` so role definitions survive cache or temporary snapshot cleanup. Symlinks component CLIs into `~/.local/bin` (or `$CODEX_LOCAL_BIN_DIR`). Computes SHA256 trusted-hashes for every hook and writes `[marketplaces.sisyphuslabs]` with local source `~/.codex/plugins/cache/sisyphuslabs`, `[plugins."omo@sisyphuslabs"]`, managed `[agents.*]`, `[features.multi_agent_v2] max_concurrent_threads_per_session = 1000`, and `[hooks.state."omo@sisyphuslabs:..."]` blocks into `~/.codex/config.toml`. If a legacy `[features] multi_agent_v2 = false` shorthand exists, the installer converts it to `[features.multi_agent_v2] enabled = false` to keep the file valid while preserving the user's explicit disable. If `--codex-autonomous` is selected, also writes `approval_policy = "never"`, `sandbox_mode = "danger-full-access"`, `network_access = "enabled"`, and the matching `[notice]` warning suppressions. |

Both halves are independent and idempotent — re-running is safe.

### Step 3: Verify

#### Verify OpenCode plugin (skip if platform=codex)

```
opencode --version  # Should be 1.4.0 or higher
cat ~/.config/opencode/opencode.json
# Plugin array should contain "oh-my-openagent" (legacy "oh-my-opencode" still loads with a warning)
bunx oh-my-openagent doctor
```

`doctor` runs six categories of checks: **System** (binary version, plugin registration), **Config** (JSONC + Zod schema), **TUI Plugin**, **Tools** (AST-grep, LSP, GitHub CLI, comment-checker), **Models** (cache, per-agent resolution, fallback chain availability), and **Team Mode** (if enabled). Exit code: `0` = ok, `1` = errors, `2` = warnings only.

#### Verify Codex CLI Light edition (skip if platform=opencode)

```
# Plugin cache present?
ls ~/.codex/plugins/cache/sisyphuslabs/omo/

# Marketplace source is the local built cache?
grep -A4 'marketplaces.sisyphuslabs' ~/.codex/config.toml

# Codex config has the plugin block?
grep -A2 'omo@sisyphuslabs' ~/.codex/config.toml

# If the user accepted autonomous mode, permission settings are present?
grep -E 'approval_policy|sandbox_mode|network_access' ~/.codex/config.toml

# Component binaries linked?
ls ~/.local/bin/ | grep -E '^(omo|ulw|ulw-loop|omo-(comment-checker|git-bash-hook|lsp|rules|start-work-continuation|telemetry|ultrawork|ulw-loop))$'

# Codex CLI sees the plugin?
codex --help

# On native Windows, Git Bash is discoverable?
where bash
```

If any of these come back empty, re-run `npx lazycodex-ai install` — the installer is idempotent and will recompute hook trust hashes.

### Step 4: Configure authentication

#### Codex CLI

Codex uses its own OpenAI authentication. The Light edition inherits whatever auth Codex CLI is already using. There is nothing extra to configure here. If `codex --help` works for you, you are done with Codex auth.

#### OpenCode providers

Skip this section if `--platform=codex`. Otherwise, configure the providers the user said yes to in Step 0. Use an interactive terminal (tmux is fine) for the OAuth flows.

##### Anthropic (Claude)

```
opencode auth login
# Interactive Terminal: find Provider → select Anthropic
# Interactive Terminal: find Login method → select Claude Pro/Max
# Guide user through OAuth flow in browser
# Wait for completion
# Verify success and confirm with user
```

##### Google Gemini (Antigravity OAuth)

First, add the `opencode-antigravity-auth` plugin entry to `opencode.json`:

```
{
  "plugin": ["oh-my-openagent", "opencode-antigravity-auth@latest"]
}
```

Then merge the full model configuration from the [opencode-antigravity-auth README](https://github.com/NoeFabris/opencode-antigravity-auth) into `opencode.json`. The plugin uses a **variant system** — models like `antigravity-gemini-3-pro` support `low`/`high` variants instead of separate `-low`/`-high` entries.

Override the agent models in the `[opencode]` block of `~/.omo/omo.jsonc` (or a project `.omo/omo.jsonc`):

```
{
  "agents": {
    "multimodal-looker": { "model": "google/antigravity-gemini-3-flash" }
  }
}
```

**Available Antigravity models:** `google/antigravity-gemini-3-pro` (variants: `low`, `high`), `google/antigravity-gemini-3-flash` (variants: `minimal`, `low`, `medium`, `high`), `google/antigravity-claude-sonnet-4-6`, `google/antigravity-claude-sonnet-4-6-thinking` (variants: `low`, `max`), `google/antigravity-claude-opus-4-5-thinking` (variants: `low`, `max`).

**Available Gemini CLI models:** `google/gemini-2.5-flash`, `google/gemini-2.5-pro`, `google/gemini-3.6-flash`, `google/gemini-3.1-pro-preview`.

> Legacy tier-suffixed names like `google/antigravity-gemini-3-pro-high` still work but variants are recommended. Use `--variant=high` with the base model name instead.

Then authenticate:

```
opencode auth login
# Interactive Terminal: Provider → Google
# Interactive Terminal: Login method → OAuth with Google (Antigravity)
# Complete sign-in in browser (auto-detected)
# Optional: Add more Google accounts for multi-account load balancing
```

The plugin supports up to 10 Google accounts. When one account hits rate limits, it automatically switches to the next available account.

##### Amazon Bedrock

OpenCode owns Bedrock authentication. Configure Bedrock in `opencode.json` or through AWS environment variables first, then use Bedrock model IDs in OMO agent or category routing.

```
{
  "provider": {
    "amazon-bedrock": {
      "options": {
        "region": "us-east-1",
        "profile": "my-aws-profile"
      }
    }
  }
}
```

For one-off launches, set the AWS credentials around OpenCode instead:

```
AWS_PROFILE=my-aws-profile AWS_REGION=us-east-1 opencode
```

After OpenCode sees the provider, reference models with the OpenCode provider prefix:

```
{
  "agents": {
    "sisyphus": { "model": "amazon-bedrock/us.anthropic.claude-opus-5" },
    "metis": { "model": "amazon-bedrock/us.anthropic.claude-sonnet-4-6" }
  }
}
```

Use OpenCode's [Amazon Bedrock provider guide](https://opencode.ai/docs/providers/#amazon-bedrock) for model access, bearer tokens, named profiles, VPC endpoints, and custom inference profile ARNs. OMO does not run a separate Bedrock login flow during install.

##### GitHub Copilot (Fallback Provider)

GitHub Copilot is supported as a **fallback provider** when native providers are unavailable. Priority is agent-specific. Common install-time defaults when Copilot is the best available provider:

| Agent | Model |
| --- | --- |
| **Sisyphus** | `github-copilot/claude-opus-4.7` |
| **Oracle** | `github-copilot/gpt-5.6-sol` |
| **Explore** | `github-copilot/claude-haiku-4-5` |
| **Atlas** | `github-copilot/claude-sonnet-4.6` |

Copilot acts as a proxy provider, routing requests to underlying models based on your subscription. Some agents (like Librarian) are not installed from Copilot alone and instead rely on other providers or runtime fallback.

##### Z.ai Coding Plan

Z.ai Coding Plan now mainly contributes `glm-5.2` / `glm-4.6v` fallback entries. It is no longer the universal fallback for every agent.

When Z.ai is the primary provider, the most important fallbacks are:

| Agent | Model |
| --- | --- |
| **Sisyphus** | `zai-coding-plan/glm-5.2` |
| **visual-engineering** | `zai-coding-plan/glm-5.2` |
| **unspecified-high** | `zai-coding-plan/glm-5.2` |
| **Multimodal-Looker** | `zai-coding-plan/glm-4.6v` |

##### OpenCode Zen

OpenCode Zen provides access to `opencode/` prefixed models including `opencode/claude-opus-5`, `opencode/gpt-5.6-sol`, `opencode/gpt-5-nano`, `opencode/glm-5.2`, `opencode/big-pickle`, `opencode/minimax-m2.7`, and `opencode/minimax-m2.7-highspeed`.

When OpenCode Zen is the best available provider, common examples:

| Agent | Model |
| --- | --- |
|  | **Sisyphus** |
| **Oracle** | `opencode/gpt-5.6-sol` |
| **Explore** | `opencode/minimax-m2.7` |

Run the installer with `--opencode-zen=yes` and select "Yes" for OpenCode Zen at the prompt. If your OpenCode environment prompts for provider authentication, follow the OpenCode provider flow for `opencode/` models.

### Step 5: Understand your model setup

#### Model families

Not all models behave the same way. Understanding "similar" families helps you make safe substitutions.

**Claude-like Models** (instruction-following, structured output):

| Model | Provider(s) | Notes |
| --- | --- | --- |
| **Claude Opus 5** | anthropic, github-copilot, opencode | Current best Opus. Dedicated per-agent prompt variants. |
| **Claude Sonnet 5** | anthropic, github-copilot, opencode | Faster, cheaper. Good balance. |
| **Claude Haiku 4.5** | anthropic, vercel | Fast and cheap. Good for quick tasks. |
| **Kimi K3** | opencode-go, kimi-for-coding, moonshotai, opencode, vercel | Top recommended Kimi for Sisyphus when thinking-token cost is acceptable. |
| **Kimi K2.7** | opencode-go, vercel | Restrained Kimi fallback for Claude-like orchestration paths. |
| **Kimi K3 Free** | opencode | Free-tier Kimi. Rate-limited but functional. |
| **GLM 5.2** | opencode-go, vercel | Claude-like behavior. Current OpenCode Go/Vercel fallback entry. |
| **GLM 5** | zai-coding-plan, opencode | Claude-like behavior. Good for broad tasks. |
| **Big Pickle (GLM 4.6)** | opencode | Free-tier GLM. Decent fallback. |

**GPT Models** (explicit reasoning, principle-driven):

| Model | Provider(s) | Notes |
| --- | --- | --- |
| **GPT-5.6 Sol** | openai, vercel | Preferred when available for Hephaestus and `ultrabrain`, with role-specific effort levels; first fallback for `deep`. |
| **GPT-5.6 Terra** | openai, vercel | GPT-5.6 mid-tier. Default for Momus (high) and an optional balanced override elsewhere. |
| **GPT-5.6 Luna** | openai, vercel | GPT-5.6 light tier. Default for the `unspecified-low` category (xhigh). |
| **GPT-5.6 Sol override paths** | openai, github-copilot, opencode, vercel | Default for Oracle and the first GPT-5.6 Sol-family fallback for Hephaestus, Momus, `deep`, and `ultrabrain`. |
| **GPT 5.6 Luna Fast** | openai, github-copilot, opencode, vercel | Fast + strong reasoning. Utility fallback after the Kimi high-speed quick default. |
| **GPT-5-Nano** | opencode, vercel | Ultra-cheap, fast. Good for simple utility tasks. |

**Different-behavior Models**:

| Model | Provider(s) | Notes |
| --- | --- | --- |
| **Gemini 3.1 Pro** | google, github-copilot, opencode | Excels at visual/frontend tasks. Different reasoning style. |
| **Gemini 3.6 Flash** | google, github-copilot, opencode | Fast, good for doc search and light tasks. |
| **MiniMax M3** | opencode-go, vercel | Latest MiniMax flagship. Primary utility fallback, ahead of M2.7. |
| **MiniMax M2.7** | opencode-go, opencode, vercel | Fast and smart. Utility fallback for various chains. |
| **MiniMax M2.7 Highspeed** | vercel, opencode | Faster utility variant used in Explore and retrieval chains. |
| **Qwen 3.7 Plus** | opencode-go | 1M context, high-speed reasoning. Default for Explore and Librarian when GPT 5.6 Luna Fast is unavailable. |

**Speed-Focused Models**:

| Model | Provider(s) | Speed | Notes |
| --- | --- | --- | --- |
| **Grok Code Fast 1** | github-copilot, xai | Very fast | Optimized for code grep/search. Manual override option — not in the default chains. |
| **Claude Haiku 4.5** | anthropic, vercel | Fast | Good balance of speed and intelligence. |
| **MiniMax M2.7 Highspeed** | vercel, opencode | Very fast | High-speed MiniMax utility fallback used by runtime chains. |
| **GPT-5.3-codex-spark** | openai | Extremely fast | Blazing but compacts too aggressively. Not recommended for omo agents. |

#### What each agent does and which model it got

**Claude-Optimized Agents** (prompts tuned for Claude-family models):

| Agent | Role | Default Chain |
| --- | --- | --- |
| **Sisyphus** | Main ultraworker | anthropic|github-copilot|opencode|vercel/claude-opus-5 (max) → opencode-go|kimi-for-coding|moonshotai|opencode|vercel|bailian-coding-plan|moonshotai-cn|firmware|ollama-cloud|aihubmix/kimi-k3 → openai|github-copilot|opencode|vercel/gpt-5.6-sol (medium) → zai-coding-plan|opencode|bailian-coding-plan|vercel/glm-5.2 → opencode/big-pickle |
| **Metis** | Plan review | anthropic|github-copilot|opencode|vercel/claude-opus-5 (high) → opencode-go|kimi-for-coding|moonshotai|opencode|vercel/kimi-k3 (low) |

**Model-Flexible Agents** (fallback across Claude, GPT, and Claude-like models):

Priority: **Claude > GPT > Claude-like models**

| Agent | Role | Default Chain | Prompt behavior |
| --- | --- | --- | --- |
| **Prometheus** | Strategic planner | anthropic|github-copilot|opencode|vercel/claude-fable-5 (xhigh) → opencode-go|kimi-for-coding|moonshotai|opencode|vercel/kimi-k3 (max) | Single thin prompt backed by `ulw-plan`; model family does not switch the prompt |
| **Atlas** | Todo orchestrator | anthropic|github-copilot|opencode|vercel/claude-sonnet-5 → opencode-go|vercel/kimi-k3 → openai|github-copilot|opencode|vercel/gpt-5.6-sol (medium) → opencode-go|vercel/minimax-m3 → minimax-coding-plan|minimax-cn-coding-plan/MiniMax-M3 → opencode-go|vercel/minimax-m2.7 | GPT-optimized todo management path |

**GPT-Native Agents** (built for GPT, don't override to Claude):

| Agent | Role | Default Chain | Notes |
| --- | --- | --- | --- |
| **Hephaestus** | Deep autonomous worker | openai|github-copilot|vercel|opencode/gpt-5.6-sol (medium) | "Codex on steroids." GPT-only chain. Requires GPT access. |
| **Oracle** | Architecture/debugging | openai|opencode|vercel/gpt-5.6-sol (xhigh) → github-copilot/gpt-5.6-sol (high) → google|github-copilot|opencode|vercel/gemini-3.1-pro (high) → anthropic|github-copilot|opencode|vercel/claude-opus-5 (max) → opencode-go|vercel/glm-5.2 | High-IQ strategic backup. GPT preferred. |
| **Momus** | High-accuracy reviewer | openai|vercel/gpt-5.6-terra (high) → github-copilot/gpt-5.6-terra (high) → openai|opencode|vercel/gpt-5.6-sol (xhigh) → github-copilot/gpt-5.6-sol (high) → anthropic|github-copilot|opencode|vercel/claude-opus-5 (max) → google|github-copilot|opencode|vercel/gemini-3.1-pro (high) → opencode-go|vercel/glm-5.2 | Verification agent. GPT preferred. |

**Utility Agents** (speed over intelligence — do not "upgrade" them):

| Agent | Role | Default Chain |
| --- | --- | --- |
| **Explore** | Fast codebase grep | openai/gpt-5.6-luna-fast → deepseek/deepseek-v4-flash (max) → opencode-go|bailian-coding-plan/qwen3.7-plus → vercel/minimax-m2.7-highspeed → opencode-go|vercel/minimax-m3 → minimax-coding-plan|minimax-cn-coding-plan/MiniMax-M3 → opencode-go|vercel/minimax-m2.7 → anthropic|github-copilot|vercel/claude-haiku-4-5 → openai|vercel/gpt-5.4-nano |
| **Librarian** | Docs/code search | (same chain as Explore) |
| **Multimodal Looker** | Vision/screenshots | openai|opencode|vercel/gpt-5.6-sol (low) → opencode-go|vercel/kimi-k3 → zai-coding-plan|vercel/glm-4.6v → openai|github-copilot|opencode|vercel/gpt-5-nano |

#### Why different models need different prompts

-   **Claude models** respond well to **mechanics-driven** prompts — detailed checklists, templates, step-by-step procedures. More rules = more compliance.
-   **GPT models** (especially 5.2+) respond better to **principle-driven** prompts — concise principles, XML-tagged structure, explicit decision criteria. More rules = more contradiction surface = more drift.

Key insight from Codex Plan Mode analysis: plan quality comes from making the plan **"Decision Complete"**: it must leave ZERO decisions to the implementer. Prometheus now uses one thin prompt backed by `ulw-plan` for that behavior instead of maintaining separate model-family prompt files.

Atlas still has model-family-specific prompt behavior. Prometheus does not switch prompts when its model changes; the fallback chain changes capacity, cost, and availability, not the prompt text.

#### Custom model configuration

If the user wants to override which model an agent uses, edit the `[opencode]` block of `~/.omo/omo.jsonc` (or a project `.omo/omo.jsonc`):

```
{
  "agents": {
    "sisyphus": { "model": "kimi-for-coding/kimi-k3" },
    "prometheus": { "model": "openai/gpt-5.6-sol" }, // Uses the same ulw-plan-backed prompt
  },
}
```

**Lower-risk overrides** (compatible behavior): Sisyphus Opus → Sonnet/Kimi K3/GLM 5.2; Prometheus Opus → GPT-5.6 Sol (same prompt, different model); Atlas Kimi K3 → Sonnet/GPT-5.6 Sol (auto-switch).

**GLM 5.2 fallback:** GLM 5.2 uses the GLM-5.2-calibrated Sisyphus prompt because its model ID is recognized as GLM. The automatic Sisyphus chain includes the `glm-5.2` literal explicitly. It still has less maintainer validation than Claude or Kimi.

**Dangerous overrides** (no prompt support): Sisyphus → unsupported GPT models (the supported GPT paths cover 5.4, 5.5, and 5.6 Sol); Hephaestus → Claude (built for Codex); Explore → Opus (massive cost waste); Librarian → Opus (same).

#### Optional: community model-management tools

The independently maintained, experimental [oh-my-openagent VS Code extension](https://github.com/andersou/oh-my-openagent-vscode-extension) can edit user-level model assignments. It is a third-party configuration frontend, not an OMO runtime component; the OMO project does not maintain or support it, and compatibility is not guaranteed.

Use external tools only with the canonical `[opencode]` fields described in [Configuration](https://omo.dev/docs#configuration). Check which file the tool changed: a nearer project `.omo/omo.jsonc` overrides user-level settings.

After using an external UI to change models:

1.  Review the generated JSONC before restarting OpenCode.
2.  Run `bunx oh-my-openagent doctor --verbose` to inspect its diagnostic model-resolution view. This does not replace checking nearer project config or runtime registration and model-matching rules.
3.  Keep provider credentials and API keys in the provider auth flow or environment, not in shared project config.

If an external tool shows a model that OMO later skips, the source of truth is still the model-matching and registration logic in this repository. Use the [Agent Model Matching](https://omo.dev/docs#agent-model-matching) guide to check whether the selected model family is supported for that agent.

#### Provider resolution

There is no single global provider priority. The installer and runtime resolve each agent against its own fallback chain, so the winning provider depends on the agent and the subscriptions enabled.

### Step 6: First use — modes, commands, agents, skills

After install, the user interacts with oh-my-openagent through five surfaces. Walk them through each.

#### Modes (typed naturally in chat)

Just type one of these words in your message and the system injects the corresponding mode prompt:

| Keyword | Editions | What it does |
| --- | --- | --- |
| `ultrawork` or `ulw` | Both | Full orchestration mode — every agent (Ultimate) or the Codex `ultrawork` component (Light) activates, doesn't stop until done |
| `search` | Ultimate | Web/doc search focus |
| `analyze` | Ultimate | Deep analysis mode |
| `team` | Ultimate | Forces `team_*` tools orchestration (requires `team_mode.enabled`) |
| `hyperplan` | Ultimate | Adversarial planning via 5 hostile critics |
| `hyperplan ultrawork` (combo) | Ultimate | Both at once |

#### Slash commands

All built-in slash commands are **Ultimate-only** — Codex CLI does not have a slash-command surface, so the Light edition omits this entire layer.

| Command | Editions | Purpose |
| --- | --- | --- |
| `/start-work` | Ultimate | Spawn Prometheus to interview the user and build a plan, then execute |
| `/goal` | Ultimate | Set, show, pause, resume, or clear a persistent thread goal that auto-continues on idle until done |
| `/stop-continuation` | Ultimate | Stop todo continuation, clear the active Goal, and clear boulder state |
| `/refactor` | Ultimate | LSP + AST-grep + TDD-verified intelligent refactor |
| `/handoff` | Ultimate | Generate detailed context summary to continue in a new session |
| `/remove-ai-slops` | Ultimate | Strip AI-generated code smells from recent changes |
| `/init-deep` | Ultimate | Generate hierarchical AGENTS.md knowledge base (skill-backed slash command) |
| `/hyperplan` | Ultimate | Direct invocation of hyperplan skill |

#### Agents (11) — Ultimate only

All 11 discipline agents are part of the Ultimate edition. The Light edition does not ship agent orchestration — Codex CLI's own model selection takes that role. Sisyphus delegates to these; you don't usually call them directly, but knowing the cast helps:

-   **Sisyphus** — main orchestrator. Plans, delegates, drives to completion.
-   **Hephaestus** — "Codex on steroids." Deep autonomous worker, GPT-native.
-   **Prometheus** — strategic planner, interviews you before code is written.
-   **Atlas** — todo-list orchestrator.
-   **Oracle** — architecture/debugging consultant.
-   **Librarian** — external docs/code search.
-   **Explore** — fast codebase grep.
-   **Multimodal-Looker** — vision/PDF analysis.
-   **Metis** — pre-planning consultant, reviews Prometheus plans for gaps.
-   **Momus** — high-accuracy plan reviewer.
-   **Sisyphus-Junior** — category-spawned executor for delegated tasks.

#### Skills

Built-in skills load automatically when their description matches your task. The user does not need to invoke them by name. The OpenCode skill system is **Ultimate-only**; the Light edition does not have a skill loader.

| Skill | Editions | When it triggers |
| --- | --- | --- |
| `playwright` | Ultimate | Browser automation |
| `git-master` | Ultimate | Atomic commits, rebases, history search |
| `frontend` | Ultimate | UI/UX implementation work |
| `review-work` | Ultimate | Post-implementation code review |
| `$omo:remove-ai-slops` | Ultimate | Cleaning AI-generated code smells |
| `team-mode` | Ultimate | Loaded only when `team_mode.enabled` |

Add custom skills under `.opencode/skills/<name>/SKILL.md` (project scope) or `~/.config/opencode/skills/<name>/SKILL.md` (user scope). Each `SKILL.md` declares a description that the agent matches against your message.

#### Tutorial to tell the user

After verification, tell the user:

1.  **Sisyphus strongly recommends Opus 5.** Using other models may noticeably degrade the experience.
2.  **Feeling lazy?** Just include `ultrawork` (or `ulw`) in your prompt. The agent figures out the rest.
3.  **Need precision?** Press **Tab** to enter Prometheus (Planner) mode, then run `/start-work` to execute the verified plan.
4.  **Your own agent/category setup?** Read [`docs/guide/agent-model-matching.md`](https://omo.dev/docs#agent-model-matching) — the assistant can interview the user and tune the config.

Then say **Congratulations! 🎉 You have successfully set up oh-my-openagent! Type `opencode` (or `codex`) in your terminal to start using it.**

### Step 7: Light Edition deep dive (Codex CLI)

Skip this section if `--platform=opencode`. Otherwise, the user installed the **Light edition** (`omo-codex`) — here is what landed on disk and what each piece does.

#### What was installed

-   **Plugin cache:** `~/.codex/plugins/cache/sisyphuslabs/omo/<version>/`
-   **Codex marketplace snapshot:** `~/.codex/.tmp/marketplaces/sisyphuslabs/` (local marketplace metadata and bundled source snapshot)
-   **Component binaries:** `lazycodex-executor-verify`, `omo-comment-checker`, `omo-git-bash-hook`, `omo-lsp`, `omo-rules`, `omo-start-work-continuation`, `omo-telemetry`, `omo-ulw-loop`, `omo-ultrawork`, `ulw`, and `ulw-loop` in `~/.local/bin` (or under `$CODEX_LOCAL_BIN_DIR` if set). The top-level `omo` command belongs to the shared oh-my-openagent launcher, not a Codex component.
-   **Codex agent roles:** `~/.codex/agents/{lazycodex-clone-fidelity-reviewer,lazycodex-code-reviewer,lazycodex-executor,lazycodex-gate-reviewer,lazycodex-qa-executor,lazycodex-worker-low,lazycodex-worker-medium,lazycodex-worker-high,explorer,librarian,metis,momus,plan}.toml` copied from the bundled plugin snapshot, so they keep resolving when Codex prunes old plugin-cache versions or temporary marketplace state
-   **Codex config edits:** `~/.codex/config.toml` gained `[features] plugins = true`, `[features] plugin_hooks = true`, `[features.multi_agent_v2] max_concurrent_threads_per_session = 1000`, `[marketplaces.sisyphuslabs]` pointing at `~/.codex/plugins/cache/sisyphuslabs`, `[plugins."omo@sisyphuslabs"]`, plugin MCP policy blocks, SHA256-pinned `[hooks.state."omo@sisyphuslabs:..."]` entries, and optionally autonomous permission settings if accepted. If the installer cannot resolve a CodeGraph-compatible Node runtime, it writes the `codegraph` MCP policy as disabled while leaving `omo@sisyphuslabs` enabled.

#### The components

| Component | Language | Codex hooks | What it does |
| --- | --- | --- | --- |
| `rules` | TypeScript | `SessionStart`, `UserPromptSubmit`, `PostToolUse`, `PostCompact` | Injects `AGENTS.md`, `CLAUDE.md`, and `.omo/rules/**` into Codex's context |
| `comment-checker` | TypeScript | `PostToolUse` (`apply_patch`, `edit`, `write`) | Blocks AI-slop comment patterns in generated code |
| `git-bash` | TypeScript + MCP | `PreToolUse` (`Bash`), `PostCompact`, MCP server | On Windows, exposes `git_bash`; reminds Codex before the first shell-like call and again after compaction |
| `lsp` | TypeScript + MCP | MCP server + post-edit hooks | Exposes LSP diagnostics, navigation, symbols, rename via MCP |
| `ultrawork` | TypeScript | `UserPromptSubmit` keyword detector | Detects `ulw`/`ultrawork` keyword; the installer links bundled Codex agent TOMLs into `$CODEX_HOME/agents` |
| `ulw-loop` | TypeScript | `UserPromptSubmit`, `PreToolUse`, `Stop` | Multi-goal orchestration with evidence audit trail, spawn guards, and Stop-hook auto-resume via `.omo/ulw-loop/` |
| `start-work-continuation` | TypeScript | `Stop`, `SubagentStop` | Continues `.omo/boulder.json` start-work plans when Codex pauses at a stop boundary |
| `telemetry` | TypeScript | `SessionStart` | Emits anonymous daily active telemetry when enabled |

#### Coexistence with OpenCode

The Codex CLI Light edition is fully independent of the OpenCode plugin. You can install both side-by-side. They share no runtime state, no config files, and no model selection. Each emits its own daily telemetry event.

Compatibility note: LazyCodex is the Codex-platform OmO install path for `oh-my-openagent`. The bundled Codex-native subagents in `~/.codex/agents` are expected. Do not enable duplicate Codex-layer OmO/LazyCodex installs in a single `CODEX_HOME`; keep one `omo@sisyphuslabs` Codex plugin source active there. If the setup looks confused, run `npx lazycodex-ai doctor` before deleting cache or config state.

#### Codex troubleshooting

| Symptom | Fix |
| --- | --- |
| `codex --help` does not list the omo plugin | Re-run `npx lazycodex-ai install` (idempotent — hook hashes are recomputed) |
| `command not found: omo-rules` or `command not found: omo` | Add `~/.local/bin` to `PATH`, or set `$CODEX_LOCAL_BIN_DIR` to a directory already on `PATH` |
| `npm install` fails mid-install | `rm -rf ~/.codex/plugins/cache/sisyphuslabs` and retry |
| Plugin block is present but hooks do not fire | Verify `~/.codex/config.toml` contains `[features]\nplugins = true\nplugin_hooks = true` and `[plugins."omo@sisyphuslabs"]` |
| `MCP client for codegraph failed to start` | Re-run `npx lazycodex-ai install` with a CodeGraph-compatible Node runtime on `PATH`, or set `CODEGRAPH_NODE_BIN` to one. The installer disables only the `codegraph` MCP policy when the local runtime is unsupported; the rest of OMO remains enabled. |
| `Ignoring malformed agent role definition: agents.*.config_file must point to an existing file` | Re-run `npx lazycodex-ai install`. The installer repairs stale managed `[agents.*]` entries and recreates `~/.codex/agents/*.toml`. |
| `agents.max_threads cannot be set when multi_agent_v2 is enabled` in one project | Re-run `npx lazycodex-ai install` from that project. The installer repairs project-local `.codex/config.toml` layers, creates `.backup-<timestamp>` files for changed configs, and leaves user-authored `.codex` artifacts in place. |
| `SessionStart hook (failed)` / `UserPromptSubmit hook (failed)` with `MODULE_NOT_FOUND` for `components/*/dist/cli.js` | Re-run the installer so the cached plugin is rebuilt with component `dist/` files. If the cache was manually edited, remove `~/.codex/plugins/cache/sisyphuslabs` first. |
| `SessionStart hook (failed)` / `UserPromptSubmit hook (failed)` with only `hook exited with code 1` after install | Re-run `npx lazycodex-ai install`, then start a fresh Codex session or restart the Codex app. If the same hook fails again in the fresh session, inspect the saved hook output to identify the component command before deleting cache state. |
| Hook trust hash mismatch warnings | Re-run the installer; hashes are regenerated each install |

### Step 8: Team Mode (optional, opt-in)

Off by default. Enables a lead-and-members multi-agent system with 12 dedicated tools.

To enable, edit your plugin config:

```
// ~/.omo/omo.jsonc "[opencode]" block OR <project>/.omo/omo.jsonc "[opencode]" block
{
  "team_mode": {
    "enabled": true,
    "max_parallel_members": 4,         // 1..8
    "max_members": 8,                  // 1..8 hard cap
    "tmux_visualization": false,
    "max_messages_per_run": 10000,
    "max_wall_clock_minutes": 120,
    "max_member_turns": 500,
    "base_dir": null,                  // overrides default ~/.omo/teams or <project>/.omo/teams
    "message_payload_max_bytes": 32768,
    "recipient_unread_max_bytes": 262144,
    "mailbox_poll_interval_ms": 3000
  }
}
```

Restart OpenCode after the change. Twelve new tools unlock: `team_create`, `team_delete`, `team_shutdown_request`, `team_approve_shutdown`, `team_reject_shutdown`, `team_send_message`, `team_task_create`, `team_task_list`, `team_task_update`, `team_task_get`, `team_status`, `team_list`.

Team storage lives under `~/.omo/teams/{name}/` (user scope) or `<project>/.omo/teams/{name}/` (project scope — project beats user on collisions).

Member eligibility:

-   **Eligible**: `sisyphus`, `atlas`, `sisyphus-junior`
-   **Conditional**: `hephaestus` (needs `teammate: "allow"` permission)
-   **Hard-rejected at parse**: `oracle`, `librarian`, `explore`, `multimodal-looker`, `metis`, `momus`, `prometheus` (use `task`/`delegate-task` instead)

Two skills already ride on top of Team Mode:

-   **`hyperplan`** — 5 hostile agents tear a plan apart from orthogonal angles before any code is written.
-   **`security-research`** — 3 vulnerability hunters + 2 PoC engineers audit your codebase in parallel.

Full guide: [`docs/guide/team-mode.md`](https://omo.dev/docs#team-mode).

### Step 9: Advanced configuration

#### Config file precedence

```
Project layers (nearest wins): <pwd up to $HOME>/.omo/omo.json[c]
                            ↓ merged onto
User layer:                  ~/.omo/omo.json[c]
                            ↓ resolved per harness, later wins
Shared base → [opencode] block → profiles.<P> → profiles.<P>.[opencode]
                            ↓ applied once at the end
Defaults
```

Merge rules:

-   Plain objects: deep merged recursively (prototype-pollution safe)
-   Scalars and arrays: override replaces base value
-   `mcp_env_allowlist`: **user-layer only** for security; project layers cannot extend it
-   Profile activation: `OMO_PROFILE` > `OCX_PROFILE` > `OPENCODE_CONFIG_DIR` tail `profiles/<name>` > none

Schema autocomplete in your editor:

```
"$schema": "https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/dev/assets/oh-my-opencode.schema.json"
```

#### Turning features off

Every agent, hook, skill, MCP, command, and tool is configurable via `disabled_*` arrays:

```
{
  "disabled_agents": ["multimodal-looker"],
  "disabled_hooks": ["goal", "keyword-detector"],
  "disabled_skills": ["playwright-cli"],
  "disabled_mcps": ["grep_app"],
  "disabled_commands": ["hyperplan"],
  "disabled_tools": ["interactive_bash"]
}
```

#### Environment variables

| Variable | Effect |
| --- | --- |
| `OMO_INVOCATION_NAME` | Overrides detected bin name (`oh-my-opencode`, `omo`, `lazycodex-ai`, etc.). Used by shared wrapper packages to route `lazycodex-ai` invocations to the Node installer path. |
| `OMO_DISABLE_POSTHOG=1` | Disables all PostHog telemetry for the main plugin |
| `OMO_SEND_ANONYMOUS_TELEMETRY=0` | Same effect as above |
| `OMO_CODEX_DISABLE_POSTHOG=1` | Disables PostHog telemetry for the Codex CLI Light edition only |
| `OMO_CODEX_SEND_ANONYMOUS_TELEMETRY=0` | Same effect as above |
| `OMO_DISABLE_PROCESS_CLEANUP=1` | Disables background-agent best-effort process cleanup on parent exit |
| `OMO_OPENCLAW_COMMAND_TIMEOUT_MS` | Timeout for OpenClaw outbound shell/HTTP commands |
| `OMO_OPENCLAW_DEBUG=1` | Enables OpenClaw debug logging |
| `OMO_OPENCLAW_REPLY_LISTENER_STARTUP_TOKEN` | Startup token for OpenClaw reply listener daemon |
| `OMO_OPENCLAW_REPLY_LISTENER_STARTUP_TIMEOUT_MS` | Timeout for reply listener startup |
| `OH_MY_OPENCODE_FORCE_BASELINE=1` | Forces baseline (non-AVX2) binary selection on x64 |
| `OPENCODE_DEFAULT_AGENT` | Default agent for `omo run` (overridden by `--agent`) |
| `CODEX_LOCAL_BIN_DIR` | Overrides `~/.local/bin` for Codex component symlinks |

#### Hash-anchored edits (Hashline)

Every `Read` tool output is tagged with `LINE#ID` content hashes. The `hashline_edit` tool rejects edits when the file has changed since the last read. No whitespace reproduction issues, no stale-line errors. Disable with `hashline_edit.enabled: false` if you need the legacy edit behavior.

#### OpenClaw (optional outbound notifications)

OpenClaw is a bidirectional external integration: outbound dispatchers fire on session events (idle, error, completion) to Discord/Telegram/HTTP/shell sinks; an optional inbound reply listener daemon polls Discord/Telegram and `send-keys` replies back into the tracked tmux pane. Configure under the `openclaw` config block. See `packages/omo-opencode/src/openclaw/` for the full reference.

### Step 10: Maintenance

| Command | Purpose |
| --- | --- |
| `bunx oh-my-openagent doctor` | 6-category health check (System / Config / TUI Plugin / Tools / Models / Team Mode) |
| `bunx oh-my-openagent boulder` | Inspect boulder work-state and per-task stats from `.omo/boulder-state/` |
| `bunx oh-my-openagent refresh-model-capabilities` | Refresh `models.json` cache from models.dev |
| `bunx oh-my-openagent mcp-oauth login <server-url>` | Tier-3 MCP OAuth login (PKCE + DCR) |
| `bunx oh-my-openagent mcp-oauth status` | Show OAuth token status |
| `bunx oh-my-openagent get-local-version` | Show installed version vs npm latest |
| `bunx oh-my-openagent version` | Print the CLI version |
| `bunx oh-my-openagent run <message>` | Non-interactive session; waits until todos clear and background tasks idle |

Postinstall validates both platform binary resolution and OpenCode version compatibility — the validation runs after every npm install.

## Telemetry & Privacy

Anonymous telemetry is enabled by default to track active installations (DAU/WAU/MAU). For both products:

-   A single event is sent **at most once per UTC day per machine**
-   Uses a SHA256-hashed installation identifier — never the raw hostname
-   PostHog person profiles are **not** created
-   The raw hostname is never transmitted

Per product:

| Product | Event name | Sources |
| --- | --- | --- |
| Main plugin | `omo_daily_active` | Plugin load (`plugin_loaded`) + `run` CLI (`run_started`) |
| Codex CLI Light edition | `omo_codex_daily_active` | Installer (`install_completed`) + Codex `SessionStart` hook (`session_start`) |

Opt-out:

```
# Disable the main plugin's telemetry
export OMO_DISABLE_POSTHOG=1
# or
export OMO_SEND_ANONYMOUS_TELEMETRY=0

# Disable only the Codex CLI Light edition telemetry
export OMO_CODEX_DISABLE_POSTHOG=1
# or
export OMO_CODEX_SEND_ANONYMOUS_TELEMETRY=0
```

The global flags (`OMO_DISABLE_POSTHOG`, `OMO_SEND_ANONYMOUS_TELEMETRY`) also suppress the Codex CLI Light edition telemetry.

The main plugin can also opt out through config:

```
{
  "telemetry": false
}
```

See [Privacy Policy](https://omo.dev/legal/privacy-policy.md) and [Terms of Service](https://omo.dev/legal/terms-of-service.md).

## Uninstall

### Remove the OpenCode plugin

```
# 1. Remove the plugin entry from opencode.json
jq '.plugin = [.plugin[] | select(. != "oh-my-openagent" and . != "oh-my-opencode")]' \
    ~/.config/opencode/opencode.json > /tmp/oc.json && \
    mv /tmp/oc.json ~/.config/opencode/opencode.json

# 2. Remove the unified config and any leftover legacy plugin config files (optional)
rm -f ~/.omo/omo.jsonc ~/.omo/omo.json \
      ~/.config/opencode/oh-my-openagent.jsonc ~/.config/opencode/oh-my-openagent.json \
      ~/.config/opencode/oh-my-opencode.jsonc ~/.config/opencode/oh-my-opencode.json

# 3. Remove project config (if you have one)
rm -f .omo/omo.jsonc .omo/omo.json \
      .opencode/oh-my-openagent.jsonc .opencode/oh-my-openagent.json \
      .opencode/oh-my-opencode.jsonc .opencode/oh-my-opencode.json

# 4. Verify removal
opencode --version
# Plugin should no longer be loaded
```

### Remove the Codex CLI Light edition

```
npx lazycodex-ai uninstall
# backward-compatible alias:
npx lazycodex-ai cleanup

omo uninstall --platform=codex
# backward-compatible alias:
omo cleanup --platform=codex
```

The uninstall command removes the managed `~/.codex/plugins/cache/sisyphuslabs` and `~/.codex/.tmp/marketplaces/sisyphuslabs` trees, strips `sisyphuslabs` / legacy LazyCodex marketplace, plugin, hook-state, and managed agent blocks from `~/.codex/config.toml` after writing a timestamped backup, and removes managed agent TOML files from `~/.codex/agents/`, including orphaned files whose install manifest is already gone.

If a workspace still has old project-local Codex state, run `npx lazycodex-ai uninstall --project <path>` or run it from that workspace. The command repairs only the known project-local Codex config conflict and reports legacy `.codex` artifact paths; it does not delete project-owned files automatically.

## Operational notes

-   Claude Code compatibility is supported (hooks, commands, skills, MCPs, plugins).
-   Claude Code plugin discovery load timeout is 10 seconds.
-   Runtime logger: `oh-my-opencode.log` in the OS temp dir (`/tmp` on Linux, `/var/folders/.../T/` on macOS, `%TEMP%` on Windows), 50 MB cap with `.1`/`.2` backup segments.
-   Dual-publish during the rename transition: `oh-my-opencode` and `oh-my-openagent` are both published. Inside `opencode.json`, the compatibility layer prefers the entry `"oh-my-openagent"`, while legacy `"oh-my-opencode"` entries still load with a warning. Plugin configuration lives in the unified `omo.jsonc`; legacy `oh-my-openagent.json[c]` / `oh-my-opencode.json[c]` files are imported once by the migration engine and no longer read at runtime. If `doctor` warns about the legacy package name, update your `opencode.json` plugin entry.

## Orchestration System Guide

Oh My OpenAgent's orchestration system transforms a simple AI agent into a coordinated development team through **separation of planning and execution**.

___

## TL;DR - When to Use What

| Complexity | Approach | When to Use |
| --- | --- | --- |
| **Simple** | Just prompt | Simple tasks, quick fixes, single-file changes |
| **Complex + Lazy** | Type `ulw` or `ultrawork` | Complex tasks where explaining context is tedious. Agent figures it out. |
| **Complex + Precise** | `@plan` → `/start-work` | Precise, multi-step work requiring true orchestration. Prometheus plans, Atlas executes. |

**Decision Flow:**

```

Is it a quick fix or simple task?
  └─ YES → Just prompt normally
  └─ NO  → Is explaining the full context tedious?
              └─ YES → Type "ulw" and let the agent figure it out
              └─ NO  → Do you need precise, verifiable execution?
                         └─ YES → Use @plan for Prometheus planning, then /start-work
                         └─ NO  → Just use "ulw"
```

___

## The Architecture

The orchestration system uses a three-layer architecture that solves context overload, cognitive drift, and verification gaps through specialization and delegation.

```
flowchart TB
    subgraph Planning["Planning Layer (Human + Prometheus)"]
        User[(" User")]
        Prometheus[" Prometheus<br/>(Planner)<br/>claude-fable-5 / kimi-k3"]
        Metis[" Metis<br/>(Consultant)<br/>claude-opus-5 / kimi-k3"]
        Momus[" Momus<br/>(Reviewer)<br/>gpt-5.6-terra / gpt-5.6-sol / claude-opus-5 / gemini-3.1-pro / glm-5.2"]
    end

    subgraph Execution["Execution Layer (Orchestrator)"]
        Orchestrator[" Atlas<br/>(Conductor)<br/>claude-sonnet-5 / kimi-k3 / gpt-5.6-sol / minimax-m3 / minimax-m2.7"]
    end

    subgraph Workers["Worker Layer (Specialized Agents)"]
        Junior[" Sisyphus-Junior<br/>(Task Executor)<br/>claude-sonnet-5 / kimi-k3 / gpt-5.6-sol / minimax-m3 / minimax-m2.7"]
        Oracle[" Oracle<br/>(Architecture)<br/>gpt-5.6-sol / gemini-3.1-pro / claude-opus-5 / glm-5.2"]
        Explore[" Explore<br/>(Codebase Grep)<br/>gpt-5.6-luna-fast / deepseek-v4-flash (max) / minimax-m2.7-highspeed / minimax-m3 / claude-haiku-4-5"]
        Librarian[" Librarian<br/>(Docs/OSS)<br/>gpt-5.6-luna-fast / deepseek-v4-flash (max) / minimax-m2.7-highspeed / minimax-m3 / claude-haiku-4-5"]
        Frontend[" visual-engineering<br/>(category + frontend)<br/>claude-opus-5 / kimi-k3 / claude-fable-5 / gemini-3.1-pro / glm-5.2"]
    end

    User -->|"Describe work"| Prometheus
    Prometheus -->|"Consult"| Metis
    Prometheus -->|"Interview"| User
    Prometheus -->|"Generate plan"| Plan[".omo/plans/*.md"]
    Plan -->|"High accuracy review"| Momus
    Plan -->|"Independent review"| Oracle
    Momus -->|"OKAY / REJECT"| Prometheus
    Oracle -->|"OKAY / REJECT"| Prometheus

    User -->|"/start-work"| Orchestrator
    Plan -->|"Read"| Orchestrator

    Orchestrator -->|"task(category=deep/quick/unspecified-*)"| Junior
    Orchestrator -->|"task(subagent_type=oracle)"| Oracle
    Orchestrator -->|"call_omo_agent(subagent_type=explore)"| Explore
    Orchestrator -->|"call_omo_agent(subagent_type=librarian)"| Librarian
    Orchestrator -->|"task(category=visual-engineering, load_skills=[frontend])"| Frontend

    Junior -->|"Results + Learnings"| Orchestrator
    Oracle -->|"Advice"| Orchestrator
    Explore -->|"Code patterns"| Orchestrator
    Librarian -->|"Documentation"| Orchestrator
    Frontend -->|"UI code"| Orchestrator
```

Model labels above show the current fallback stacks from `packages/omo-opencode/src/shared/model-requirements.ts`, not marketing names.

### Agent Inventory and Modes (Current)

The system has **11 built-in agents**:

-   Primary: `sisyphus`, `hephaestus`, `prometheus`, `atlas`
-   Subagent: `oracle`, `librarian`, `explore`, `multimodal-looker`, `metis`, `momus`, `sisyphus-junior`

Canonical assembly order for primary agents is:

`Sisyphus → Hephaestus → Prometheus → Atlas`

Mode distinction:

-   `mode: "primary"`: top-level session agents selected directly in UI/CLI
-   `mode: "subagent"`: worker/consultant agents invoked via `task(..., subagent_type="...")` or `call_omo_agent(...)`

### Display Names vs Providers

`Sisyphus - ultraworker` is the display name for the primary Sisyphus agent. It is not a separate provider, proxy, or replacement for your original model account.

Three names can appear together in logs or the TUI:

-   **Agent display name**: `Sisyphus - ultraworker`, `Atlas - Plan Executor`, `Hephaestus - Deep Agent`
-   **Provider namespace**: `anthropic`, `openai`, `github-copilot`, `opencode`, `opencode-go`, `vercel`
-   **Model id**: `claude-opus-5`, `kimi-k3`, `gpt-5.6-sol`, `glm-5.2`

The agent decides the prompt and behavior. The provider namespace decides which connected account or gateway serves the request. The model id decides the model family. If you see Sisyphus running through `opencode-go/kimi-k3`, that means the Sisyphus prompt is using Kimi through the OpenCode Go provider path; it does not mean OMO replaced your provider silently.

When `ulw` or `ultrawork` is present, Sisyphus receives the ultrawork instruction set for a harder autonomous task. By default it keeps the agent's configured model or fallback chain. An explicit `agents.sisyphus.ultrawork.model` or `variant` setting can override that routing for ultrawork prompts.

### Delegation Semantics (Important)

-   `task(category="...")` routes to **Sisyphus-Junior** with category-optimized model routing
-   `task(subagent_type="...")` invokes that specific agent directly (for example `oracle`, `explore`, `librarian`)
-   Category and `subagent_type` are mutually exclusive inputs in one call

___

## Planning: Prometheus + Metis + Momus + Oracle

### Prometheus: Your Strategic Consultant

Prometheus is not just a planner, it's an intelligent interviewer that helps you think through what you actually need. It is **READ-ONLY** - can only create or modify markdown files within `.omo/` directory.

**The Interview Process:**

```
stateDiagram-v2
    [*] --> Interview: User describes work
    Interview --> Research: Launch explore/librarian agents
    Research --> Interview: Gather codebase context
    Interview --> ClearanceCheck: After each response

    ClearanceCheck --> Interview: Requirements unclear
    ClearanceCheck --> PlanGeneration: All requirements clear

    state ClearanceCheck {
        [*] --> Check
        Check: Core objective defined?
        Check: Scope boundaries established?
        Check: No critical ambiguities?
        Check: Technical approach decided?
        Check: Test strategy confirmed?
    }

    PlanGeneration --> MetisConsult: Mandatory gap analysis
    MetisConsult --> WritePlan: Incorporate findings
    WritePlan --> HighAccuracyChoice: Present to user

    state "Momus + Oracle review" as DualReview

    HighAccuracyChoice --> DualReview: High accuracy required or selected
    HighAccuracyChoice --> Done: User accepts plan

    DualReview --> WritePlan: EITHER REJECTS - fix issues
    DualReview --> Done: BOTH APPROVE - plan approved

    Done --> [*]: Guide to /start-work
```

**Intent-Specific Strategies:**

Prometheus adapts its interview style based on what you're doing:

| Intent | Prometheus Focus | Example Questions |
| --- | --- | --- |
| **Refactoring** | Safety - behavior preservation | "What tests verify current behavior?" "Rollback strategy?" |
| **Build from Scratch** | Discovery - patterns first | "Found pattern X in codebase. Follow it or deviate?" |
| **Mid-sized Task** | Guardrails - exact boundaries | "What must NOT be included? Hard constraints?" |
| **Architecture** | Strategic - long-term impact | "Expected lifespan? Scale requirements?" |

### Metis: The Gap Analyzer

Before Prometheus writes the plan, Metis catches what Prometheus missed:

-   Hidden intentions in user's request
-   Ambiguities that could derail implementation
-   AI-slop patterns (over-engineering, scope creep)
-   Missing acceptance criteria
-   Edge cases not addressed

**Why Metis Exists:**

The plan author (Prometheus) has "ADHD working memory" - it makes connections that never make it onto the page. Metis forces externalization of implicit knowledge.

### High-Accuracy Review: Momus + Oracle

High-accuracy mode runs two independent reviews in parallel: Momus checks plan quality and Oracle checks the plan on the strongest available reasoning model. Both must approve before handoff.

**The Dual-Review Loop:**

Momus is approval-biased and rejects only verified blockers. It checks that:

-   Referenced files exist and support the plan's claims
-   Every task gives a developer a usable starting point
-   Tasks do not contradict each other
-   QA scenarios name the tool, steps, and expected result
-   No missing information would completely stop execution

Minor gaps and details that a developer can resolve during implementation do not block approval; a plan that is roughly 80% clear is considered executable.

If either reviewer rejects the plan, Prometheus fixes every cited issue and resubmits to both reviewers. No maximum retry limit.

### Where to Spend a Scarce Premium Model

Choose a compatible role before optimizing for invocation frequency. For example, a scarce Claude-family model such as Fable 5 fits Metis better than GPT-oriented Oracle or Momus. High-accuracy planning also runs Oracle and Momus together on every review round, so neither is purely an on-demand slot in that workflow.

See [Agent-Model Matching: Where to Spend One Scarce Premium Model](https://omo.dev/docs#agent-model-matching) for the family-aware heuristic and a concrete configuration.

___

## Execution: Atlas

### The Conductor Mindset

Atlas is like an orchestra conductor: it doesn't play instruments, it ensures perfect harmony.

```
flowchart LR
    subgraph Orchestrator["Atlas"]
        Read["1. Read Plan"]
        Analyze["2. Analyze Tasks"]
        Wisdom["3. Accumulate Wisdom"]
        Delegate["4. Delegate Tasks"]
        Verify["5. Verify Results"]
        Report["6. Final Report"]
    end

    Read --> Analyze
    Analyze --> Wisdom
    Wisdom --> Delegate
    Delegate --> Verify
    Verify -->|"More tasks"| Delegate
    Verify -->|"All done"| Report

    Delegate -->|"background=false"| Workers["Workers"]
    Workers -->|"Results + Learnings"| Verify
```

**What Atlas CAN do:**

-   Read files to understand context
-   Run commands to verify results
-   Use lsp\_diagnostics to check for errors
-   Search patterns with grep/glob/ast-grep

**What Atlas MUST delegate:**

-   Writing or editing code files
-   Fixing bugs
-   Creating tests
-   Git commits

### Wisdom Accumulation

The power of orchestration is cumulative learning. After each task:

1.  Extract learnings from subagent's response
2.  Categorize into: Conventions, Successes, Failures, Gotchas, Commands
3.  Pass forward to ALL subsequent subagents

This prevents repeating mistakes and ensures consistent patterns.

**Notepad System:**

```
.omo/notepads/{plan-name}/
├── learnings.md      # Patterns, conventions, successful approaches
├── decisions.md      # Architectural choices and rationales
├── issues.md         # Problems, blockers, gotchas encountered
├── verification.md   # Test results, validation outcomes
└── problems.md       # Unresolved issues, technical debt
```

___

## Workers: Sisyphus-Junior and Specialists

### Sisyphus-Junior: The Task Executor

Junior is the workhorse that actually writes code. Key characteristics:

-   **Focused**: Cannot delegate (blocked from task tool)
-   **Disciplined**: Obsessive todo tracking
-   **Verified**: Must pass lsp\_diagnostics before completion
-   **Constrained**: Cannot modify plan files (READ-ONLY)

**Why the fallback chain is sufficient:**

Junior doesn't need to be the smartest - it needs to be reliable. With:

1.  Detailed prompts from Atlas (50-200 lines)
2.  Accumulated wisdom passed forward
3.  Clear MUST DO / MUST NOT DO constraints
4.  Verification requirements

Even a mid-tier execution model works when the harness is strict. The current fallback order is `claude-sonnet-5` → `kimi-k3` → `gpt-5.6-sol` → `minimax-m3` → `minimax-m2.7` → `big-pickle`. The intelligence is in the **system**, not a single worker model.

### System Reminder Mechanism

The hook system ensures Junior never stops halfway:

```
[SYSTEM REMINDER - TODO CONTINUATION]

You have incomplete todos! Complete ALL before responding:
- [ ] Implement user service ← IN PROGRESS
- [ ] Add validation
- [ ] Write tests

DO NOT respond until all todos are marked completed.
```

This "boulder pushing" mechanism is why the system is named after Sisyphus.

___

## Category + Skill System

### Why Categories are Revolutionary

**The Problem with Model Names:**

```
// OLD: Model name creates distributional bias
task({ agent: "gpt-5.6-sol", prompt: "..." }); // Model knows its limitations
task({ agent: "claude-opus-5", prompt: "..." }); // Different self-perception
```

**The Solution: Semantic Categories:**

```
// NEW: Category describes INTENT, not implementation
task({ category: "ultrabrain", prompt: "..." }); // "Think strategically"
task({ category: "visual-engineering", prompt: "..." }); // "Design beautifully"
task({ category: "quick", prompt: "..." }); // "Just get it done fast"
```

### Delegate-Task Categories

`task(category="...")` supports these category names in user-facing orchestration:

`visual-engineering`, `artistry`, `ultrabrain`, `deep`, `quick`, `unspecified-low`, `unspecified-high`, `writing`, `quick-rust`, `quick-zig`, `git`

Notes:

-   Built-in defaults are defined in `packages/omo-opencode/src/tools/delegate-task/*-categories.ts` and `packages/omo-opencode/src/shared/model-requirements.ts`
-   Projects/users can extend categories via config; additional category names may appear in your session prompt
-   Regardless of category name, category dispatch goes through Sisyphus-Junior

### Skills: Domain-Specific Instructions

Skills prepend specialized instructions to subagent prompts:

```
// Category + Skill combination
task(
  (category = "visual-engineering"),
  (load_skills = ["frontend"]), // Adds UI/UX expertise
  (prompt = "..."),
);

task(
  (category = "deep"),
  (load_skills = ["playwright"]), // Adds browser automation expertise
  (prompt = "..."),
);
```

Skill loading priority is:

`project > opencode > user > builtin`

### Skill MCP (Tier 3)

Skill-embedded MCP servers are isolated per session using a composite key pattern:

`${sessionID}:${skillName}:${serverName}`

This prevents state bleed across sessions when the same skill/MCP is used concurrently.

### Background Task Concurrency

Background task concurrency defaults to **5** when no overrides are configured.

-   Keyed by model/provider routing key
-   Configurable via `background_task.defaultConcurrency`, `background_task.providerConcurrency`, and `background_task.modelConcurrency`

### Team Mode

Team mode is parallel multi-agent orchestration and is **OFF by default**.

For `subagent_type` team members, current eligibility is:

-   Eligible: `sisyphus`, `atlas`, `sisyphus-junior`
-   Conditional: `hephaestus` (requires teammate permission enablement)
-   Hard-reject: `oracle`, `librarian`, `explore`, `multimodal-looker`, `metis`, `momus`, `prometheus`

Why `oracle`/`prometheus` are rejected in team members:

-   Oracle is read-only (cannot write/edit/patch/delegate)
-   Prometheus is constrained to `.omo/*.md` writes by the `prometheus-md-only` hook

___

## Usage Patterns

### How to Invoke Prometheus

**Method 1: Switch to Prometheus Agent (Tab → Select Prometheus)**

```
1. Press Tab at the prompt
2. Select "Prometheus" from the agent list
3. Describe your work: "I want to refactor the auth system"
4. Answer interview questions
5. Prometheus creates plan in .omo/plans/{name}.md
```

**Method 2: Use @plan Command (in Sisyphus)**

```
1. Stay in Sisyphus (default agent)
2. Type: @plan "I want to refactor the auth system"
3. The @plan command automatically switches to Prometheus
4. Answer interview questions
5. Prometheus creates plan in .omo/plans/{name}.md
```

**Which Should You Use?**

| Scenario | Recommended Method | Why |
| --- | --- | --- |
| **New session, starting fresh** | Switch to Prometheus agent | Clean mental model - you're entering "planning mode" |
| **Already in Sisyphus, mid-work** | Use @plan | Convenient, no agent switch needed |
| **Want explicit control** | Switch to Prometheus agent | Clear separation of planning vs execution contexts |
| **Quick planning interrupt** | Use @plan | Fastest path from current context |

Both methods trigger the same Prometheus planning flow. The @plan command is simply a convenience shortcut.

### /start-work Behavior and Session Continuity

**What Happens When You Run /start-work:**

```
User: /start-work
    ↓
[start-work hook activates]
    ↓
Check: Does .omo/boulder.json exist?
    ↓
    ├─ YES (existing work) → RESUME MODE
    │   - Read the existing boulder state
    │   - Calculate progress (checked vs unchecked boxes)
    │   - Inject continuation prompt with remaining tasks
    │   - Atlas continues where you left off
    │
    └─ NO (fresh start) → INIT MODE
        - Find the most recent plan in .omo/plans/
        - Create new boulder.json tracking this plan
        - Switch session agent to Atlas
        - Begin execution from task 1
```

**Session Continuity Explained:**

The `boulder.json` file tracks:

-   **active\_plan**: Path to the current plan file
-   **session\_ids**: All sessions that have worked on this plan
-   **started\_at**: When work began
-   **plan\_name**: Human-readable plan identifier

**Example Timeline:**

```
Monday 9:00 AM
  └─ @plan "Build user authentication"
  └─ Prometheus interviews and creates plan
  └─ User: /start-work
  └─ Atlas begins execution, creates boulder.json
  └─ Task 1 complete, Task 2 in progress...
  └─ [Session ends - computer crash, user logout, etc.]

Monday 2:00 PM (NEW SESSION)
  └─ User opens new session (agent = Sisyphus by default)
  └─ User: /start-work
  └─ [start-work hook reads boulder.json]
  └─ "Resuming 'Build user authentication' - 3 of 8 tasks complete"
  └─ Atlas continues from Task 3 (no context lost)
```

Atlas is automatically activated when you run `/start-work`. You don't need to manually switch to Atlas.

### Hephaestus vs Sisyphus + ultrawork

**Quick Comparison:**

| Aspect | Hephaestus | Sisyphus + `ulw` / `ultrawork` |
| --- | --- | --- |
| **Model** | `gpt-5.6-sol` (`medium`) when available, with `gpt-5.6-sol` (`medium`) only | `claude-opus-5` / `kimi-k3` / `gpt-5.6-sol` / `glm-5.2` depending on setup |
| **Approach** | Autonomous deep worker | Keyword-activated ultrawork mode |
| **Best For** | Complex architectural work, deep reasoning | General complex tasks, "just do it" scenarios |
| **Planning** | Self-plans during execution | Uses Prometheus plans if available |
| **Delegation** | Heavy use of explore/librarian agents | Uses category-based delegation |
| **Temperature** | 0.1 | 0.1 |

**When to Use Hephaestus:**

Switch to Hephaestus (Tab → Select Hephaestus) when:

1.  **Deep architectural reasoning needed**
    
    -   "Design a new plugin system"
    -   "Refactor this monolith into microservices"
2.  **Complex debugging requiring inference chains**
    
    -   "Why does this race condition only happen on Tuesdays?"
    -   "Trace this memory leak through 15 files"
3.  **Cross-domain knowledge synthesis**
    
    -   "Integrate our Rust core with the TypeScript frontend"
    -   "Migrate from MongoDB to PostgreSQL with zero downtime"
4.  **You specifically want GPT-native autonomous reasoning**
    
    -   Hephaestus prefers GPT-5.6 Sol when OpenAI or Vercel exposes it and retains GPT-5.6 Sol as the broad fallback

**When to Use Sisyphus + `ulw`:**

Use the `ulw` keyword in Sisyphus when:

1.  **You want the agent to figure it out**
    
    -   "ulw fix the failing tests"
    -   "ulw add input validation to the API"
2.  **Complex but well-scoped tasks**
    
    -   "ulw implement JWT authentication following our patterns"
    -   "ulw create a new CLI command for deployments"
3.  **You're feeling lazy** (officially supported use case)
    
    -   Don't want to write detailed requirements
    -   Trust the agent to explore and decide
4.  **You want to leverage existing plans**
    
    -   If a Prometheus plan exists, `ulw` mode can use it
    -   Falls back to autonomous exploration if no plan

**Recommendation:**

-   **For most users**: Use `ulw` keyword in Sisyphus. It's the default path and works excellently for 90% of complex tasks.
-   **For power users**: Switch to Hephaestus when you want GPT-native reasoning or the "AmpCode deep mode" experience of fully autonomous exploration and execution.

### Brownfield / KISS Mode

For mature projects, the safest default is not "make the best architecture." It is "make the smallest correct change that fits the architecture already here."

Use Prometheus first when a brownfield task could invite broad cleanup, rewrites, or speculative abstractions. Select Prometheus with the agent selector or `/agent`, then ask it to produce a constrained plan with explicit boundaries:

```
Fix <problem> in this existing codebase.
Preserve the current architecture and public behavior.
Use the smallest viable change.
Follow local patterns in <files or areas>.
Do not refactor, rename, reorganize, or clean up unrelated code.
List exact files in scope and exact verification commands.
```

Then run `/start-work` from that plan. Atlas will execute against the written scope instead of treating the task as an open-ended modernization pass.

Use `ulw` directly only when the target is already narrow:

```
ulw fix the null handling in packages/foo/src/bar.ts using the existing helper style. No unrelated cleanup.
```

Use Hephaestus when you deliberately want autonomous deep implementation or architectural exploration. If the job is "touch the old system without disturbing it," an explicit Prometheus plan provides written scope boundaries before Atlas starts execution.

___

## Configuration

You can control related features in the `[opencode]` block of `~/.omo/omo.jsonc`:

```
{
  "sisyphus_agent": {
    "disabled": false, // Enable Atlas orchestration (default: false)
    "planner_enabled": true, // Enable Prometheus (default: true)
    "replace_plan": true, // Replace default plan agent with Prometheus (default: true)
  },

  // Hook settings (add to disable)
  "disabled_hooks": [
    // "start-work",             // Disable execution trigger
    // "prometheus-md-only"      // Remove Prometheus write restrictions (not recommended)
  ],
}
```

___

## Troubleshooting

### "I switched to Prometheus but nothing happened"

Prometheus enters interview mode by default. It will ask you questions about your requirements. Answer them, then say "make it a plan" when ready.

### "/start-work says 'no active plan found'"

Either:

-   No plans exist in `.omo/plans/` → Create one with Prometheus first
-   Plans exist but boulder.json points elsewhere → Delete `.omo/boulder.json` and retry

### "I'm in Atlas but I want to switch back to normal mode"

Type `exit` or start a new session. Atlas is primarily entered via `/start-work` - you don't typically "switch to Atlas" manually.

### "What's the difference between @plan and just switching to Prometheus?"

**Nothing functional.** Both invoke Prometheus. @plan is a convenience command while switching agents is explicit control. Use whichever feels natural.

### "Should I use Hephaestus or type ulw?"

**For most tasks**: Type `ulw` in Sisyphus.

**Use Hephaestus when**: You need GPT-native reasoning for deep architectural work or complex debugging.

___

## Further Reading

-   [Overview](https://omo.dev/docs#overview)
-   [Features Reference](https://omo.dev/docs#features)
-   [Configuration Reference](https://omo.dev/docs#configuration)
-   [Manifesto](https://omo.dev/docs#manifesto)

## Agent-Model Matching Guide

> **For agents and users**: Why each agent needs a specific model — and how to customize without breaking things.

___

## 🚨 READ THIS FIRST — SISYPHUS IS **NOT** A "RUN IT ON ANY MODEL" SYSTEM 🚨

> **STOP. BEFORE YOU POINT SISYPHUS AT SOME OTHER MODEL, READ EVERY WORD BELOW. THIS IS THE SINGLE MOST IGNORED THING IN THIS WHOLE GUIDE.**

**SISYPHUS IS ONLY MAINTAINER-VERIFIED ON THE EXACT MODELS LISTED IN THIS SUPPORTED SET — AND NOTHING, _NOTHING_, ELSE.** The supported set is narrow on purpose:

-   **Claude family:** Fable 5 · Opus 5 · Sonnet 5
-   **Kimi:** **K3** · K2.7
-   **GLM:** 5.2 / 5.1 _(acceptable — slightly looser on the long nested workflows)_
-   **GPT:** 5.4 / 5.5 / 5.6 Sol _(GPT-native prompt paths exist — supported, but still **NOT** the recommended default for the orchestrator)_

> **Known GPT-5.6 Sisyphus risk:** GPT-5.6 Sol is an automatic fallback and receives a model-aware GPT-native prompt, but [issue #6074](https://github.com/code-yeongyu/oh-my-openagent/issues/6074) tracks over-orchestration on bounded work. Hephaestus remains the recommended GPT-5.6 agent; the Sisyphus route is available for fallback coverage, not a claim that it is the best fit.

**GLM 5.2 is explicit but still lower-confidence than Claude/Kimi.** A dedicated GLM-5.2-calibrated prompt exists, and the Sisyphus fallback chain now includes the `glm-5.2` model literal. One community report describes good results, but maintainers have not yet validated the nested todo, delegation, long-context, and non-ultrawork behavior end to end.

**IF A MODEL IS NOT ON THE SUPPORTED LIST, IT IS NOT MAINTAINER-VERIFIED WITH SISYPHUS.** A community report does not change that status. It may not work at all. It may _look_ like it works and then fall apart three tool-calls later. **IT IS NOT A SUPPORTED CONFIGURATION, IT IS NOT BLESSED, AND IT IS NOT A PROMISE THAT IT WILL STILL WORK TOMORROW.**

**EVERY SINGLE PROMPT CHANGE TO SISYPHUS IS WRITTEN, TUNED, AND REGRESSION-CHECKED AGAINST THE MODELS ABOVE — AND ONLY THOSE MODELS.** Nobody is watching how an off-list model behaves. The consequences are not subtle:

-   **AN UNLISTED MODEL CAN BREAK AT THE _VERY NEXT PATCH_, WITH ZERO WARNING.** A prompt tweak that helps Claude/Kimi can silently shatter whatever fragile thing was holding your off-list model together — and we will _never notice_, because we are not testing it. Do not file it as a bug. It was never working on purpose.
-   **A PROMPT CANNOT FIX A MODEL.** Models have hard, intrinsic characteristics. No amount of prompt-carving makes a model do what it fundamentally _cannot_ do. If a model is the wrong brain for orchestration, it stays the wrong brain — **forever**, no matter how perfectly the prompt is shaped. We have ground prompts down to the bone; the model that can't, still can't.

**SO, GENUINELY AND SINCERELY, FROM THE BOTTOM OF OUR HEARTS: RUNNING SISYPHUS ON ANY MODEL NOT LISTED HERE IS STRONGLY, EMPHATICALLY, DESPERATELY _NOT_ RECOMMENDED.** Do it anyway and you are fully on your own — and you should _expect_ it to break.

### MiniMax / Qwen / MiMo / DeepSeek as Sisyphus — JUST DON'T

**We have NOT found any way to make MiniMax, Qwen, MiMo, or DeepSeek work acceptably as Sisyphus.** We tried. They do not hold up under Sisyphus's nested todo + delegation + orchestration prompt. This is not a "tune it more" situation — see the rule above: _a prompt cannot fix a model._

**MiniMax and Qwen in particular are so bad in the Sisyphus role that we would almost forbid it outright.** Treat **"Sisyphus on MiniMax"** and **"Sisyphus on Qwen"** as configurations you should simply _never_ reach for. (These models still have legitimate jobs elsewhere as utility and research fallbacks, documented below — just **NEVER** as the orchestrator.)

___

## The Core Insight: Models Are Developers

Think of AI models as developers on a team. Each has a different brain, different personality, different strengths. **A model isn't just "smarter" or "dumber." It thinks differently.** Give the same instruction to Claude and GPT, and they'll interpret it in fundamentally different ways.

This isn't a bug. It's the foundation of the entire system.

Oh My OpenAgent assigns each agent a model that matches its _working style_ — like building a team where each person is in the role that fits their personality.

### Sisyphus: The Sociable Lead

Sisyphus is the developer who knows everyone, goes everywhere, and gets things done through communication and coordination. Talks to other agents, understands context across the whole codebase, delegates work intelligently, and codes well too. But deep, purely technical problems? He'll struggle a bit.

**This is why Sisyphus uses Claude / Kimi / GLM.** These models excel at:

-   Following complex, multi-step instructions (Sisyphus's prompt is ~1,100 lines)
-   Maintaining conversation flow across many tool calls
-   Understanding nuanced delegation and orchestration patterns
-   Producing well-structured, communicative output

Using Sisyphus with older GPT models would be like taking your best project manager — the one who coordinates everyone, runs standups, and keeps the whole team aligned — and sticking them in a room alone to debug a race condition. Wrong fit. GPT-5.4 has its own prompt, while GPT-5.5 and GPT-5.6 Sol share a model-aware GPT-native prompt family; GPT is still not the default recommendation for the orchestrator.

> **⚠️ Sisyphus is ONLY tested on Claude (Fable 5 / Opus 5 / Sonnet 5), Kimi (**K3** / K2.7), GLM (5.2 / 5.1), and GPT (5.4 / 5.5 / 5.6 Sol).** Anything else is not maintainer-verified or supported and can break without warning. **MiniMax and Qwen as Sisyphus are strongly discouraged to the point we'd almost forbid it.** Read the **🚨 READ THIS FIRST** warning at the very top of this guide before you override the orchestrator's model.

> **GLM 5.2 remains lower-confidence than Claude/Kimi.** It has a calibrated prompt and one community report, but no maintainer end-to-end validation. The automatic Sisyphus chain includes `glm-5.2` explicitly; older `glm-5` / `glm-5.1` entries are compatibility paths, not the current explicit fallback.

### Hephaestus: The Deep Specialist

Hephaestus is the developer who stays in their room coding all day. Doesn't talk much. Might seem socially awkward. But give them a hard technical problem and they'll emerge three hours later with a solution nobody else could have found.

**This is why Hephaestus uses GPT-5.6 Sol.** The GPT-5.x flagship line is built for exactly this:

-   Deep, autonomous exploration without hand-holding
-   Multi-file reasoning across complex codebases
-   Principle-driven execution (give a goal, not a recipe)
-   Working independently for extended periods

Using Hephaestus with GLM or Kimi would be like assigning your most communicative, sociable developer to sit alone and do nothing but deep technical work. They'd get it done eventually, but they wouldn't shine — you'd be wasting exactly the skills that make them valuable.

### The Takeaway

Every agent's prompt is tuned to match its model's personality. **When you change the model, you change the brain — and the same instructions get understood completely differently.** Model matching isn't about "better" or "worse." It's about fit.

___

## How Claude and GPT Think Differently

This matters for understanding why some agents support both model families while others don't.

**Claude** responds to **mechanics-driven** prompts — detailed checklists, templates, step-by-step procedures. More rules = more compliance. You can write a 1,100-line prompt with nested workflows and Claude will follow every step.

**GPT** (especially 5.2+) responds to **principle-driven** prompts — concise principles, XML structure, explicit decision criteria. More rules = more contradiction surface = more drift. GPT works best when you state the goal and let it figure out the mechanics.

Prometheus used to mirror this split with separate model-family prompts. It now uses a single thin prompt backed by `ulw-plan`, so swapping its model changes the fallback choice, not the prompt file.

Atlas still supports model-family prompt behavior. Prometheus does not auto-switch prompts at runtime.

___

## Step 1 — Check What's Actually Available

Before configuring anything, see what your current system can run.

### List all available models

```
opencode models
```

This prints every `provider/model` combination you can address right now. Providers are derived from your connected auth + the `models.dev` catalogue.

Opencode sorts the output so `opencode*` providers appear first — that's intentional, not cosmetic.

### List connected providers

```
opencode auth list
```

Shows which providers you've already logged into.

### If the model you want isn't listed

You need to log in to that provider:

```
opencode auth login
```

The interactive picker prioritizes providers in this order:

| Priority | Provider | Opencode's own hint |
| --- | --- | --- |
| 0 | `opencode` | **(Recommended)** |
| 1 | `opencode-go` | Low cost subscription for everyone |
| 2 | `openai` | ChatGPT Plus/Pro or API key |
| 3 | `github-copilot` | — |
| 4 | `anthropic` | API key |
| 5 | `google` | — |

You can also skip the picker: `opencode auth login --provider opencode-go`.

### Verify what oh-my-openagent will actually use

```
bunx oh-my-openagent doctor
```

This shows the **effective model resolution** for every agent and category based on your current auth state. If an agent says "system-default" instead of a real fallback, that's a signal you're missing providers from its chain.

___

## Step 2 — The Recommended Stack

You don't need every provider. You need the right two.

### The Optimal Combination: OpenCode Go + OpenAI Plus/Pro

**~$30/month total.** Beats direct Anthropic + OpenAI + Google subscriptions (~$60+/month) on both cost and coverage.

| Subscription | Cost | What You Get | Covers |
| --- | --- | --- | --- |
| **OpenCode Go** | $10/mo | `kimi-k3`, `glm-5.2`, `minimax-m2.5`, `minimax-m2.7`, `minimax-m3`, `mimo-v2-pro`, `qwen3.7-plus`, `qwen3.6-plus` | Claude-family alternatives (Kimi, GLM), Gemini-family alternatives (Qwen), utility/retrieval (MiniMax) |
| **OpenAI Plus/Pro** | $20+/mo | `gpt-5.4`, `gpt-5.4-pro`, `gpt-5.6-sol`, `gpt-5.6-terra`, `gpt-5.6-luna` | GPT-native agents (Hephaestus, Oracle, Momus), GPT-5.6 category defaults (`deep`, `ultrabrain`, `unspecified-low`), GPT fallbacks for model-flexible agents |

### Why this specific combination

1.  **Hephaestus requires the GPT-5.x family (default: GPT-5.6 Sol).** It has no Claude-family fallback. ChatGPT Plus/Pro or OpenAI API access is the cheapest real path.
2.  **OpenCode Go covers the orchestration and creative surface.** Kimi K3/K2.7 behaves like Claude for Sisyphus/Atlas. GLM 5.2 fills the long tail. Qwen 3.7 Plus supports utility and research fallbacks.
3.  **No single provider can cover everything.** Anthropic-only setups break Hephaestus. OpenAI-only setups degrade Sisyphus. You need at least one from each family.

### What if you already have a Claude subscription?

Add `--claude=max20` (or `yes`) on install. The Claude chain default (Opus 5) activates for Sisyphus/Metis and you still get the OpenCode Go fallbacks for free. Pin `claude-opus-5` or `claude-fable-5` to run the current top Claude with Sisyphus/Atlas tuned prompts, or pin `opencode-go/kimi-k3` to run the top Kimi; Prometheus uses Fable 5 before its Kimi K3 fallback. Best-in-class orchestration + budget safety net.

### What if you have zero subscriptions?

OpenCode Go alone gets Sisyphus/Atlas/Oracle/Librarian/Explore working. Hephaestus won't activate without GPT access, so you lose autonomous deep work. Consider adding ChatGPT Plus as soon as you can.

### Where to Spend One Scarce Premium Model

If one premium model is quota-limited while your other models are effectively unlimited, optimize in this order:

1.  **Match the model family to the agent.** A premium model is not an interchangeable upgrade. Claude-family models fit communicators such as Metis, Sisyphus, and Atlas; GPT-family models fit deep specialists such as Oracle, Momus, and Hephaestus.
2.  **Prefer a low-frequency, high-leverage role.** Avoid spending scarce quota on continuous orchestration, execution, search, or retrieval unless that is the workflow you explicitly want to improve.
3.  **Account for loops.** Metis normally contributes one gap-analysis pass per plan generation. High-accuracy planning runs one Momus pass and one independent Oracle pass per round, then repeats both after any rejection. Oracle can also be invoked separately for architecture or debugging advice.

For a scarce Claude Fable 5 allocation, **Metis is the default value-per-token placement**. It is compatible with Metis's prompt style, runs before the plan is finalized, and can prevent expensive downstream work without putting every Sisyphus, Atlas, or worker turn on the limited quota.

```
{
  "agents": {
    "metis": {
      "model": "anthropic/claude-fable-5",
      "variant": "max",
      "fallback_models": [
        { "model": "anthropic/claude-sonnet-5" },
        { "model": "openai/gpt-5.6-sol", "variant": "high" },
        { "model": "kimi-for-coding/kimi-k3" }
      ]
    }
  }
}
```

The explicit `model` and `variant` make Fable 5 the normal Metis model. `fallback_models` only supplies secondary candidates; putting Fable 5 there without an explicit `model` does not assign it as the normal model for an agent whose primary model is available.

Use a different slot only when the model family and workflow justify it:

-   A scarce **GPT-family** reasoning model can be valuable on Oracle or Momus, but high-accuracy planning spends both once per review round. Hephaestus is a better target when the scarce model's purpose is autonomous deep implementation rather than advisory review.
-   Prometheus is lower-frequency than Sisyphus, but a planning interview can span many turns.
-   Sisyphus and Atlas are valid homes for Fable 5 when maximum orchestration quality matters more than quota. They are not the default for a scarce allocation because they run throughout the workflow.
-   Sisyphus-Junior and categories are execution-heavy. Explore and Librarian favor speed and parallelism. These are usually poor places for the rarest model.

___

## Step 3 — Model Family Alternatives (Priority Order)

When the "native" model isn't available, oh-my-openagent walks each agent's fallback chain until something connects. The chains are hardcoded in [`packages/omo-opencode/src/shared/model-requirements.ts`](https://omo.dev/packages/omo-opencode/src/shared/model-requirements.ts). There is no single global priority list. Every agent and category has its own chain.

There are two separate systems:

-   **model-fallback**: proactive resolution in `chat.params` using hardcoded `AGENT_MODEL_REQUIREMENTS` and `CATEGORY_MODEL_REQUIREMENTS`
-   **runtime-fallback**: reactive recovery from `session.error`, configurable per category/agent in runtime-fallback hooks

### Current top tier vs the auto-resolution chain

The model recommendations and their auto-resolution chains now use the same current generation, and the runtime fallback chain uses the same resolved chain as initial selection:

-   **The current top models** are Claude **Fable 5** and **Opus 5**, and Kimi **K3** and **K2.7**. Pin one in your config: `"anthropic/claude-opus-5"`, `"anthropic/claude-fable-5"`, `"opencode-go/kimi-k3"`, `"opencode-go/kimi-k2.7-code"`.
-   **The auto-resolution fallback chains** use Opus 5 for Metis, Fable 5 for Prometheus, and their configured Kimi K3 fallbacks.

The chain entries below are the active recommendations, not snapshot-backed legacy defaults.

### Claude Family (communicative, instruction-following)

Used by: Sisyphus, Atlas, Sisyphus-Junior, Metis (Claude path), Prometheus (primary fallback), `unspecified-low`, `unspecified-high`.

The priorities below include manual model choices. They are not a literal copy of every agent's automatic fallback chain; see [Agent Profiles](https://omo.dev/docs#agent-profiles) for the exact runtime chains.

| Priority | Model | Provider | Why |
| --- | --- | --- | --- |
| 1 | `claude-fable-5` / `claude-opus-5` | `anthropic`, `github-copilot`, `opencode`, `vercel` | Best overall compliance with the ~1,100-line Sisyphus prompt. Prometheus uses Fable 5 xhigh before Kimi K3 max; Metis uses Opus 5 high before Kimi K3 low. |
| 2 | `claude-sonnet-5` | same | Faster, cheaper, still Claude. |
| 3 | **`kimi-k3` - RECOMMENDED ALTERNATIVE (newest Kimi)** | `opencode-go`, `kimi-for-coding`, `moonshotai`, `opencode`, `vercel` | Strongest Kimi for Sisyphus. Use when you can accept the thinking-token cost; the prompt is calibrated to stop overthinking and keep work moving. |
| 4 | **`kimi-k2.7` - RECOMMENDED ALTERNATIVE** | same as K3 | Restrained, outcome-first, and the top Kimi when Anthropic isn't connected. Agents with Kimi-specific prompt paths use their K2.7 tuning; Prometheus keeps its `ulw-plan`\-backed prompt. |
| 5 | **Additional Kimi K3 provider entries — RECOMMENDED ALTERNATIVE** | same as K3 | Instruction-following mirrors Claude closely. Current default Kimi in the chains after the top K3/K2.7 entries. |
| 6 | **`glm-5.2` — ACCEPTABLE FALLBACK, LIMITED VALIDATION** | `opencode-go`, `zai-coding-plan`, `opencode`, `vercel` | Claude-like, slightly looser on long nested workflows. The automatic Sisyphus chain includes `glm-5.2` explicitly and applies the GLM-5.2-calibrated prompt. |
| 7 | **`glm-5` / `glm-5.1` — LEGACY/COMPATIBILITY** | `zai-coding-plan`, `opencode`, `vercel` | Older configs and provider catalogs may still resolve these IDs, but they are not the current explicit GLM 5.2 fallback literal. |
| 8 | `big-pickle` (GLM 4.6) | `opencode` | Free-tier safety net. |

> **Kimi ≻ GLM.** Kimi (K3 newest, then K2.7) holds up under Sisyphus's nested todo+delegation prompts better than GLM. Use Kimi whenever both are available.

### GPT Family (principle-driven, autonomous)

Used by: Hephaestus, Oracle, Momus, `deep`, `ultrabrain`, `quick`, `unspecified-low`, Prometheus (GPT fallback), Atlas (GPT path).

| Priority | Model | Provider | Why |
| --- | --- | --- | --- |
| 1 | `gpt-5.6-sol` (xhigh / high / medium) | `openai`, `github-copilot`, `opencode`, `vercel` | The GPT-5.6 flagship. Default for Hephaestus, Oracle, and `ultrabrain`; first GPT-5.6 Sol-family fallback for deep GPT-native roles. |
| 1 | `gpt-5.6-terra` (xhigh / high) | `openai`, `vercel` | GPT-5.6 mid-tier. Default for Momus (high) and an optional balanced override elsewhere. |
| 1 | `gpt-5.6-luna` (xhigh) | `openai`, `vercel` | GPT-5.6 light tier. New default for the `unspecified-low` category. |
| 2 | `gpt-5.4` / `gpt-5.4-pro` (pro / xhigh / high / medium) | `openai`, `github-copilot`, `opencode`, `vercel` | Previous flagship generation; fallback on providers without GPT-5.6. Hephaestus requires this family. |
| 3 | **DeepSeek — LIMITED ALTERNATIVE** (`deepseek-v4-pro`) | `deepseek`, `opencode-go`, `vercel` | Approved in the `unspecified-low` fallback chain, but not a substitute for the Sol-only `deep` category. |
| 4 | **MiniMax — STRONGLY DISCOURAGED** (`minimax-m3`, `minimax-m2.7`, `minimax-m2.5`) | `opencode-go`, `opencode`, `openrouter/minimax` | Used only in **utility** agent fallback chains (Explore and Librarian). Consistency and long-context management issues make it a poor substitute for Hephaestus/Oracle. Do NOT override deep agents to MiniMax. |

> **DeepSeek ≻≻ MiniMax.** DeepSeek retains GPT's autonomous exploration character. MiniMax loses coherence on multi-step deep work. MiniMax is fine for grep-style utility agents, nothing more.

### Visual Engineering Chain

The built-in `visual-engineering` category starts with Claude Opus 5 and does not require Gemini:

| Priority | Model | Provider | Why |
| --- | --- | --- | --- |
| 1 | `claude-opus-5` (`max`) | `anthropic`, `github-copilot`, `opencode` | Primary UI/UX, CSS, design-token, and layout model. |
| 2 | `kimi-k3` (`max`) | `opencode-go`, `kimi-for-coding`, `moonshotai`, `opencode`, `vercel` | Current visual fallback when Opus 5 is unavailable. |
| 3 | `glm-5.2` (`max`) | `opencode-go`, `opencode`, `vercel`, `zai-coding-plan` | Final built-in visual fallback. |

Gemini 3.1 Pro remains a visual-capable explicit override where a provider exposes it. Gemini 3.6 Flash remains useful for fast writing and documentation work, but neither model is the current `visual-engineering` default chain.

___

## Cheat Sheet: Substitution Rules

| If you lose... | Swap to (in order) | Avoid |
| --- | --- | --- |
| Claude Opus/Sonnet | Kimi K3 → Kimi K2.7 → GLM 5.2 → Big Pickle | Older GPT models |
| GPT-5.4/5.5/5.6 Sol | GPT-5.6 Sol → DeepSeek v3.2 | MiniMax (except for utility work) |
| `visual-engineering` primary | Claude Opus 5 → Kimi K3 → GLM 5.2 | Qwen is not in the built-in chain |
| GPT 5.6 Luna Fast (Explore/Librarian) | Qwen 3.7-plus → MiniMax M2.7 Highspeed → MiniMax M3 → Claude Haiku | Opus (massive cost waste) |

GLM 5.2 is now an explicit model literal in the automatic Sisyphus fallback chain. Older `glm-5` / `glm-5.1` catalog entries remain compatibility paths, but the current GLM fallback is `glm-5.2`.

___

## Agent Profiles

Exact current runtime chains from [`agent-model-requirements.ts`](https://omo.dev/packages/model-core/src/agent-model-requirements.ts).

| Agent | Primary | Full fallback chain |
| --- | --- | --- |
| **sisyphus** | `claude-opus-5` | `anthropic|github-copilot|opencode|vercel/claude-opus-5 (max)` → `opencode-go|kimi-for-coding|moonshotai|opencode|vercel|bailian-coding-plan|moonshotai-cn|firmware|ollama-cloud|aihubmix/kimi-k3` → `openai|github-copilot|opencode|vercel/gpt-5.6-sol (medium)` → `zai-coding-plan|opencode|bailian-coding-plan|vercel/glm-5.2` → `opencode/big-pickle` |
| **hephaestus** | `gpt-5.6-sol` | `openai|github-copilot|vercel|opencode/gpt-5.6-sol (medium)` |
| **oracle** | `gpt-5.6-sol` | `openai|opencode|vercel/gpt-5.6-sol (xhigh)` → `github-copilot/gpt-5.6-sol (high)` → `google|github-copilot|opencode|vercel/gemini-3.1-pro (high)` → `anthropic|github-copilot|opencode|vercel/claude-opus-5 (max)` → `opencode-go|vercel/glm-5.2` |
| **librarian** | `gpt-5.6-luna-fast` | `openai/gpt-5.6-luna-fast` → `deepseek/deepseek-v4-flash (max)` → `opencode-go|bailian-coding-plan/qwen3.7-plus` → `vercel/minimax-m2.7-highspeed` → `opencode-go|vercel/minimax-m3` → `minimax-coding-plan|minimax-cn-coding-plan/MiniMax-M3` → `opencode-go|vercel/minimax-m2.7` → `anthropic|github-copilot|vercel/claude-haiku-4-5` → `openai|vercel/gpt-5.4-nano` |
| **explore** | `gpt-5.6-luna-fast` | `openai/gpt-5.6-luna-fast` → `deepseek/deepseek-v4-flash (max)` → `opencode-go|bailian-coding-plan/qwen3.7-plus` → `vercel/minimax-m2.7-highspeed` → `opencode-go|vercel/minimax-m3` → `minimax-coding-plan|minimax-cn-coding-plan/MiniMax-M3` → `opencode-go|vercel/minimax-m2.7` → `anthropic|github-copilot|vercel/claude-haiku-4-5` → `openai|vercel/gpt-5.4-nano` |
| **multimodal-looker** | `gpt-5.6-sol` | `openai|opencode|vercel/gpt-5.6-sol (low)` → `opencode-go|vercel/kimi-k3` → `zai-coding-plan|vercel/glm-4.6v` → `openai|github-copilot|opencode|vercel/gpt-5-nano` |
| **prometheus** | `claude-fable-5` | `anthropic|github-copilot|opencode|vercel/claude-fable-5 (xhigh)` → `opencode-go|kimi-for-coding|moonshotai|opencode|vercel/kimi-k3 (max)` |
| **metis** | `claude-opus-5` | `anthropic|github-copilot|opencode|vercel/claude-opus-5 (high)` → `opencode-go|kimi-for-coding|moonshotai|opencode|vercel/kimi-k3 (low)` |
| **momus** | `gpt-5.6-terra` | `openai|vercel/gpt-5.6-terra (high)` → `github-copilot/gpt-5.6-terra (high)` → `openai|opencode|vercel/gpt-5.6-sol (xhigh)` → `github-copilot/gpt-5.6-sol (high)` → `anthropic|github-copilot|opencode|vercel/claude-opus-5 (max)` → `google|github-copilot|opencode|vercel/gemini-3.1-pro (high)` → `opencode-go|vercel/glm-5.2` |
| **atlas** | `claude-sonnet-5` | `anthropic|github-copilot|opencode|vercel/claude-sonnet-5` → `opencode-go|vercel/kimi-k3` → `openai|github-copilot|opencode|vercel/gpt-5.6-sol (medium)` → `opencode-go|vercel/minimax-m3` → `minimax-coding-plan|minimax-cn-coding-plan/MiniMax-M3` → `opencode-go|vercel/minimax-m2.7` |
| **sisyphus-junior** | `claude-sonnet-5` | `anthropic|github-copilot|opencode|vercel/claude-sonnet-5` → `opencode-go|vercel/kimi-k3` → `openai|github-copilot|opencode|vercel/gpt-5.6-sol (medium)` → `opencode-go|vercel/minimax-m3` → `minimax-coding-plan|minimax-cn-coding-plan/MiniMax-M3` → `opencode-go|vercel/minimax-m2.7` → `opencode/big-pickle` |

## Model Families

### Claude Family

Communicative, instruction-following, structured output. Best for agents that need to follow complex multi-step prompts. Sisyphus, Sisyphus-Junior, Atlas, and Metis use tuned prompt paths for supported communicative models. Prometheus uses one thin `ulw-plan`\-backed prompt across model families.

| Model | Strengths |
| --- | --- |
| **Claude Fable 5** | Top tier, above Opus. Highest compliance; has its own per-agent prompt variants. |
| **Claude Opus 5** | Current best Opus — steerable and literal. Dedicated per-agent prompt variants. |
| **Claude Sonnet 5** | Faster, cheaper. Good balance for everyday tasks. |
| **Claude Haiku 4.5** | Fast and cheap. Good for quick tasks and utility work. |
| **Kimi K3** | Newest Kimi generation. Strong reasoning and instruction following; tuned Sisyphus prompt explicitly bounds overthinking so it keeps moving on routine work. Recommended when the thinking-token cost is acceptable. |
| **Kimi K2.7** | Restrained and outcome-first, a GPT-5.6 Sol-leaning Claude-family alternative. Top Kimi for the orchestrators; agents with Kimi-specific prompt paths use K2.7 tuning while Prometheus keeps its `ulw-plan`\-backed prompt. |
| **Kimi K3** | Behave very similarly to Claude. Great all-rounders at lower cost; K3 is the Kimi fallback in the Sisyphus chain. |
| **GLM 5** | Claude-like behavior. Solid for orchestration tasks. |
| **GLM 5.2** | Experimental for Sisyphus. Model IDs recognized as GLM use a GLM-5.2-calibrated prompt, but evidence is one community report without maintainer end-to-end validation. |

### GPT Family

Principle-driven, explicit reasoning, deep technical capability. Best for agents that work autonomously on complex problems.

| Model | Strengths |
| --- | --- |
| **GPT-5.6 Sol** | The GPT-5.6 flagship. Default for Hephaestus and `ultrabrain`; first GPT-5.6 Sol-family fallback for deep GPT-native roles. |
| **GPT-5.6 Terra** | GPT-5.6 mid-tier. Default for Momus (high) and an optional balanced override elsewhere. |
| **GPT-5.6 Luna** | GPT-5.6 light tier. Default for the `unspecified-low` category (xhigh). |
| **GPT-5.6 Sol override paths** | High intelligence, strategic reasoning. Default for Oracle and a key fallback for Prometheus / Atlas. |
| **GPT 5.6 Luna Fast** | Fast + strong reasoning. Utility fallback after the Kimi high-speed quick default. |
| **GPT-5-Nano** | Ultra-cheap, fast. Good for simple utility tasks. |

### Other Models

| Model | Strengths |
| --- | --- |
| **Gemini 3.1 Pro** | Visual-capable explicit override with a different reasoning style; not in the built-in `visual-engineering` chain. |
| **Gemini 3.6 Flash** | Fast. Good for doc search and light tasks. |
| **GPT 5.6 Luna Fast** | Default for Explore and Librarian agents. Blazing-fast reasoning-capable mini model. |
| **MiniMax M3** | Latest MiniMax flagship. Primary MiniMax fallback in OpenCode Go utility chains, ahead of M2.7. |
| **MiniMax M2.7** | Fast and smart. Used in OpenCode Go and OpenCode Zen utility fallback chains. |
| **MiniMax M2.7 Highspeed** | High-speed OpenCode catalog entry used in utility fallback chains that prefer the fastest available MiniMax path. |

### OpenCode Go

A premium subscription tier ($10/month) that provides reliable access to Chinese frontier models through OpenCode's infrastructure.

**Available Models:**

| Model | Use Case |
| --- | --- |
| **opencode-go/kimi-k3** | Strongest Kimi orchestration model. Primary recommended Kimi for Sisyphus when thinking cost is acceptable. |
| **opencode-go/kimi-k3** | Vision-capable, Claude-like reasoning. Used by Sisyphus, Atlas, Sisyphus-Junior, Multimodal Looker. |
| **opencode-go/glm-5.2** | Text-only orchestration model. Used by Sisyphus, Oracle, Prometheus, Metis, Momus, `visual-engineering`, and `ultrabrain`. |
| **opencode-go/minimax-m3** | Latest MiniMax flagship on OpenCode Go. Primary MiniMax fallback for Atlas, Sisyphus-Junior, Explore and Librarian, ahead of M2.7. |
| **opencode-go/minimax-m2.7** | Ultra-cheap, fast responses. Used by Atlas, Sisyphus-Junior, Explore and Librarian fallbacks for utility work. |
| **opencode-go/qwen3.7-plus** | Qwen coding model used as the first OpenCode Go utility fallback for Explore and Librarian when GPT 5.6 Luna Fast is unavailable. |

**When It Gets Used:**

OpenCode Go models appear throughout the fallback chains as intermediate options. Depending on the agent, they can sit before GPT, after GPT, or act as the last structured-model fallback before cheaper utility paths.

**Go-Only Scenarios:**

Some model identifiers in fallback chains are provider-specific aliases. For example, `kimi-k3` resolves through `kimi-for-coding`, while `glm-5.2` can resolve through `zai-coding-plan`, `opencode`, or `vercel` depending on availability.

### About Free-Tier Fallbacks

You may see model names like `kimi-k3-free`, `minimax-m3`, `minimax-m2.7`, `minimax-m2.7-highspeed`, or `big-pickle` (GLM 4.6) in the source code or logs. These are provider-specific or speed-optimized entries in fallback chains.

You don't need to configure them. The system includes them so it degrades gracefully when you don't have every paid subscription. If you have the paid version, the paid version is always preferred.

___

## Task Categories

When agents delegate work, they don't pick a model name — they pick a **category**. The category maps to the right model automatically.

| Category | Used For | Default Model | Full fallback chain |
| --- | --- | --- | --- |
| `visual-engineering` | Frontend, UI, CSS, design | `anthropic/claude-opus-5 (max)` | `anthropic|anthropic-api|github-copilot|opencode|vercel/claude-opus-5 (max)` → `kimi-for-coding|moonshotai|opencode-go|opencode|vercel/kimi-k3 (max)` → `zai-coding-plan|opencode-go|vercel/glm-5.2 (max)` → `openai|quotio-openai|github-copilot|opencode|vercel/gpt-5.6-sol (medium)` |
| `ultrabrain` | Maximum reasoning needed | `openai/gpt-5.6-sol (max)` | `openai|quotio-openai|vercel/gpt-5.6-sol (max)` → `github-copilot/gpt-5.6-sol (max)` → `openai|opencode|vercel/gpt-5.6-sol (max)` |
| `deep` | Deep coding, complex logic | `openai/gpt-5.6-sol (medium)` | `openai|quotio-openai|github-copilot|opencode|vercel/gpt-5.6-sol (medium)` |
| `artistry` | Creative, novel approaches | `anthropic/claude-fable-5 (xhigh)` | `anthropic|anthropic-api|github-copilot|opencode|vercel/claude-fable-5 (xhigh)` → `kimi-for-coding|moonshotai|opencode-go|opencode|vercel/kimi-k3 (max)` → `anthropic|anthropic-api|github-copilot|opencode|vercel/claude-opus-5 (xhigh)` |
| `quick` | Simple, fast tasks | `kimi-for-coding/kimi-for-coding-highspeed` | `kimi-for-coding/kimi-for-coding-highspeed` → `quotio-openai/gpt-5.6-luna-fast (low)` → `deepseek/deepseek-v4-flash (off)` → `qwen-token-plan|alibaba-token-plan|bailian-coding-plan|opencode-go|vercel/qwen3.6-flash (low)` → `opencode-go|vercel/minimax-m3 (max)` → `opencode-go|vercel/minimax-m2.7 (max)` → `xai/grok-4.20-0309-non-reasoning` → `anthropic|anthropic-api|github-copilot|vercel/claude-haiku-4-5 (off)` |
| `unspecified-low` | General standard work | `openai/gpt-5.6-terra (high)` | `openai|quotio-openai|github-copilot|opencode|vercel/gpt-5.6-terra (high)` → `anthropic|anthropic-api|github-copilot|opencode|vercel/claude-sonnet-5 (low)` → `qwen-token-plan|alibaba-token-plan|qwen-token-plan-cn|alibaba-token-plan-cn/qwen3.8-max-preview (max)` → `deepseek|opencode-go|vercel/deepseek-v4-pro (max)` → `xiaomi|opencode-go|vercel/mimo-v2.5-pro (max)` |
| `unspecified-high` | General complex work | `kimi-for-coding/kimi-k3 (max)` | `kimi-for-coding|moonshotai|opencode-go|opencode|vercel/kimi-k3 (max)` → `anthropic|anthropic-api|github-copilot|opencode|vercel/claude-opus-5 (xhigh)` → `openai|quotio-openai|github-copilot|opencode|vercel/gpt-5.6-sol (high)` |
| `writing` | Text, docs, prose | `kimi-for-coding/kimi-k3 (low)` | `kimi-for-coding|moonshotai|opencode-go|opencode|vercel/kimi-k3 (low)` → `anthropic|anthropic-api|github-copilot|opencode|vercel/claude-opus-5 (low)` → `google|github-copilot|opencode|vercel/gemini-3.6-flash` |

See the [Orchestration System Guide](https://omo.dev/docs#orchestration) for how agents dispatch tasks to categories.

### Vercel AI Gateway fallback coverage

`packages/omo-opencode/src/shared/model-requirements.ts` includes `vercel` on nearly every gateway-compatible fallback entry across both agent and category chains. Treat it as a universal extra provider path for the listed model IDs, not as a different model family.

___

## Customization

### Example A — Recommended Stack (OpenCode Go + OpenAI Plus/Pro)

```
{
  "$schema": "https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/dev/assets/oh-my-opencode.schema.json",

  "agents": {
    // Sisyphus: Kimi K3 is the top alternative to Claude for orchestration
    "sisyphus": {
      "model": "opencode-go/kimi-k3",
      "ultrawork": { "model": "opencode-go/kimi-k3" },
    },

    // Hephaestus: needs GPT. ChatGPT Plus gets you here.
    "hephaestus": { "model": "openai/gpt-5.6-sol", "variant": "medium" },

    // Architecture consultation: GPT or Claude Opus
    "oracle": { "model": "openai/gpt-5.6-sol", "variant": "high" },

    // Prometheus keeps the same ulw-plan-backed prompt across model families
    "prometheus": { "model": "opencode-go/kimi-k2.7-code" },

    // Atlas also communicative — Kimi works great
    "atlas": { "model": "opencode-go/kimi-k3" },

    // Utility agents stay cheap
    "explore": { "model": "opencode-go/qwen3.7-plus" },
    "librarian": { "model": "opencode-go/qwen3.7-plus" },
  },

  "categories": {
    "visual-engineering": { "model": "opencode-go/kimi-k3", "variant": "max" },
    "deep": { "model": "openai/gpt-5.6-sol", "variant": "medium" },
    "ultrabrain": { "model": "openai/gpt-5.6-sol", "variant": "xhigh" },
    "quick": { "model": "kimi-for-coding/kimi-for-coding-highspeed" },
    "unspecified-high": { "model": "opencode-go/kimi-k3" },
    "unspecified-low": { "model": "opencode-go/kimi-k2.7-code" },
    "writing": { "model": "opencode-go/kimi-k3", "variant": "low" },
  },

  "background_task": {
    "providerConcurrency": {
      "openai": 3,
      "opencode-go": 10,
    },
  },
}
```

### Example B — All Native (Anthropic + OpenAI + Google)

Highest quality, highest cost. No surprises.

```
{
  "agents": {
    "sisyphus": {
      "model": "anthropic/claude-opus-5",
      "variant": "max",
    },
    "hephaestus": { "model": "openai/gpt-5.6-sol", "variant": "medium" },
    "oracle": { "model": "openai/gpt-5.6-sol", "variant": "high" },
  },
  "categories": {
    "visual-engineering": { "model": "anthropic/claude-opus-5", "variant": "max" },
    "deep": { "model": "openai/gpt-5.6-sol", "variant": "medium" },
    "unspecified-high": { "model": "anthropic/claude-opus-5", "variant": "xhigh" },
  },
}
```

### Example C — OpenCode Go Only (Budget, No GPT)

Cheapest full-stack path. Hephaestus won't activate — accept that trade-off.

```
{
  "agents": {
    "sisyphus": { "model": "opencode-go/kimi-k3" },
    "atlas": { "model": "opencode-go/kimi-k3" },
    // Omit hephaestus entirely; it needs GPT.
    "oracle": { "model": "opencode-go/glm-5.2" },  // Degraded but functional
    "explore": { "model": "opencode-go/qwen3.7-plus" },
    "librarian": { "model": "opencode-go/qwen3.7-plus" },
  },
  "categories": {
    "visual-engineering": { "model": "opencode-go/qwen3.6-plus" },
    "deep": { "model": "opencode-go/kimi-k3" },  // Not ideal — Kimi isn't GPT, but best available
    "unspecified-high": { "model": "opencode-go/kimi-k3" },
    "unspecified-low": { "model": "opencode-go/kimi-k2.7-code" },
    "quick": { "model": "opencode-go/minimax-m2.7" },
    "writing": { "model": "opencode-go/kimi-k3", "variant": "low" },
  },
}
```

### Example D — Adding DeepSeek as GPT Alternative

If you have OpenRouter and want DeepSeek in the chain when GPT is unavailable:

```
{
  "agents": {
    "oracle": {
      "model": "openai/gpt-5.6-sol",
      "variant": "high",
      "fallback_models": [
        "anthropic/claude-opus-5",
        { "model": "openrouter/deepseek/deepseek-v3.2", "temperature": 0.7 },
        "opencode-go/glm-5.2",
      ],
    },
  },
}
```

`fallback_models` accepts a mix of plain model strings and per-fallback objects with `variant`, `reasoningEffort`, `temperature`, `top_p`, `maxTokens`, `thinking`.

___

### Safe vs Dangerous Overrides

**Safe** — same personality type:

-   Sisyphus: Opus → Sonnet, Kimi K3 / K2.7, GLM 5.2 (all communicative models)
-   Prometheus: Opus → GPT-5.6 Sol (same `ulw-plan`\-backed prompt, different model)
-   Atlas: Claude Sonnet 5 → Kimi K3 → GPT-5.6 Sol (auto-switches to the GPT prompt)

**Lower-confidence** — explicit fallback, limited maintainer validation:

-   Sisyphus: GLM 5.2. Model IDs recognized as GLM use the calibrated GLM 5.2 prompt. The automatic fallback chain includes `glm-5.2` explicitly, but the model has less maintainer validation than Claude or Kimi.

**Dangerous** — personality mismatch:

-   **Sisyphus → ANY model not on the tested list**: The supported set is Claude (Fable 5 / Opus 5 / Sonnet 5), Kimi (K3 / K2.7), GLM (5.2 / 5.1), GPT (5.4 / 5.5 / 5.6 Sol). Everything else is not maintainer-verified and can break at the very next patch. **A prompt cannot fix a model** — if it doesn't fit, no tuning makes it fit. See the **🚨 READ THIS FIRST** warning at the very top of this guide.
-   **Sisyphus → MiniMax / Qwen**: **Strongly discouraged to the point of "almost forbidden."** Neither holds up under the orchestration prompt. Never use them as the orchestrator.
-   **Sisyphus → MiMo / DeepSeek**: No working configuration found. Untested and unsupported as the orchestrator.
-   **Sisyphus → older GPT models**: Still a bad fit. GPT-5.4 has its own prompt; GPT-5.5 and GPT-5.6 Sol share the supported model-aware GPT-native prompt family.
-   **Hephaestus → Claude**: Built for Codex's autonomous style. Claude can't replicate this.
-   **Hephaestus → MiniMax**: MiniMax loses coherence on multi-step deep work. **Never do this.**
-   **Oracle → MiniMax**: Same reason. Oracle needs sustained reasoning; MiniMax drifts.
-   **Explore → Opus**: Massive cost waste. Explore needs speed, not intelligence.
-   **Librarian → Opus**: Same. Doc search doesn't need Opus-level reasoning.
-   **`visual-engineering` → utility/search models**: Keep this category on its approved Claude Opus 5 → Kimi K3 → GLM 5.2 chain; MiniMax, Haiku, and search-oriented Qwen tiers are poor substitutes for visual implementation work.

___

## How Model Resolution Works

Each agent has a fallback chain. The system tries models in priority order until it finds one available through your connected providers. You don't need to configure providers per model. Just authenticate (`opencode auth login`) and the system figures out which models are available and where.

Resolution pipeline (from [`packages/omo-opencode/src/shared/model-resolution-pipeline.ts`](https://omo.dev/packages/omo-opencode/src/shared/model-resolution-pipeline.ts)):

```
1. Override          → User's explicit config or UI-selected model (primary agents only)
2. Category default  → From category config (when agent has category set)
3. User fallback_models → Configured strings/objects tried before hardcoded chain
4. Provider fallback → AGENT_MODEL_REQUIREMENTS / CATEGORY_MODEL_REQUIREMENTS
5. System default    → Ultimate safety net
```

Core-agent tab cycling is deterministic via injected runtime order field. The fixed priority order is Sisyphus (order: 0), Hephaestus (order: 1), Prometheus (order: 2), and Atlas (order: 3), then the remaining agents follow.

Your explicit configuration always wins. If you set a specific model for an agent, that choice takes precedence even when resolution data is cold.

Variant and `reasoningEffort` overrides are normalized to model-supported values, so cross-provider overrides degrade gracefully instead of failing hard.

Model capabilities are `models.dev`\-backed, with a refreshable cache and capability diagnostics. Use `bunx oh-my-openagent refresh-model-capabilities` to update the cache, or configure `model_capabilities.auto_refresh_on_start` to refresh at startup.

To see which models your agents will actually use, run `bunx oh-my-openagent doctor`. This shows effective model resolution based on your current authentication and config.

```
Agent Request → User Override (if configured) → Fallback Chain → System Default
```

### File-Based Prompts

You can load agent system prompts from external files using `file://` URLs in the `prompt` field, or append additional content with `prompt_append`. The `prompt_append` field also works on categories.

```
{
  "agents": {
    "sisyphus": {
      "prompt": "file:///path/to/custom-prompt.md",
    },
    "oracle": {
      "prompt_append": "file:///path/to/additional-context.md",
    },
  },
  "categories": {
    "deep": {
      "prompt_append": "file:///path/to/deep-category-append.md",
    },
  },
}
```

The file content is loaded at runtime and injected into the agent's system prompt. Supports `~` expansion for home directory and relative `file://` paths.

___

## See Also

-   [Installation Guide](https://omo.dev/docs#installation) — Setup and authentication
-   [Orchestration System Guide](https://omo.dev/docs#orchestration) — How agents dispatch tasks to categories
-   [Configuration Reference](https://omo.dev/docs#configuration) — Full config options
-   [`packages/omo-opencode/src/shared/model-requirements.ts`](https://omo.dev/packages/omo-opencode/src/shared/model-requirements.ts) — Source of truth for fallback chains

## Team Mode

Parallel multi-agent coordination for omo, modeled after Claude Code's experimental Agent Teams.

## Status

OFF by default. Enable via JSONC config.

## When to use

-   Parallel exploration with bounded coordination.
-   Long-running multi-step refactors split across specialised agents.
-   Research + implementation pipelines that need shared task lists.

## Enable

Add to the `[opencode]` block of `~/.omo/omo.jsonc` (user) or `.omo/omo.jsonc` (project):

```
{
  "team_mode": {
    "enabled": true,
    "max_parallel_members": 4,
    "max_members": 8,
    "tmux_visualization": false
  }
}
```

After enabling, restart opencode. The 12 `team_*` tools become available.

> Bug-fix note: v4.2.1 adds a fresh-install regression test for this minimal config and logs the resolved `team_mode` state plus team tool count during startup. If the tools still do not appear after restart, inspect `oh-my-opencode.log` for the loaded config path and `[tool-registry] Built tool registry` entry.

## Config schema (11 fields)

All fields live under `team_mode`:

-   `enabled` (boolean, default `false`)
-   `tmux_visualization` (boolean, default `false`)
-   `max_parallel_members` (int, `1..8`, default `4`)
-   `max_members` (int, `1..8`, default `8`)
-   `max_messages_per_run` (int, `>=1`, default `10000`)
-   `max_wall_clock_minutes` (int, `>=1`, default `120`)
-   `max_member_turns` (int, `>=1`, default `500`)
-   `base_dir` (optional string; default resolves to `~/.omo`)
-   `message_payload_max_bytes` (int, `>=1024`, default `32768`)
-   `recipient_unread_max_bytes` (int, `>=1024`, default `262144`)
-   `mailbox_poll_interval_ms` (int, `>=500`, default `3000`)

## Define a team

Team specs live under `~/.omo/teams/{name}/config.json` (user scope) or `<project>/.omo/teams/{name}/config.json` (project scope):

```
{
  "name": "ccapi-explorers",
  "description": "Explore the ccapi project structure.",
  "lead": { "kind": "subagent_type", "subagent_type": "sisyphus" },
  "members": [
    { "kind": "category", "name": "scout-1", "category": "deep", "prompt": "Scout the source directory for auth patterns." },
    { "kind": "category", "name": "scout-2", "category": "quick", "prompt": "Scout tests for auth coverage." }
  ]
}
```

When both scopes define the same team name, project scope wins.

`version`, `createdAt`, and `leadAgentId` are optional in config files. The loader fills them automatically. You can either write a top-level `lead: {...}` shorthand, mark one member with `isLead: true`, or omit both when the team has exactly one member.

## Member kinds

-   **`kind: "subagent_type"`** — direct agent (atlas, sisyphus, sisyphus-junior, hephaestus). `prompt` optional.
-   **`kind: "category"`** — routed through `sisyphus-junior` with the chosen category model. `prompt` REQUIRED.

## Eligible agents

-   **Eligible:** `sisyphus`, `atlas`, `sisyphus-junior`.
-   **Conditional:** `hephaestus` (needs teammate permission `teammate: "allow"`; otherwise use `subagent_type: "sisyphus"`).
-   **Hard-reject:** `oracle`, `librarian`, `explore`, `multimodal-looker`, `metis`, `momus`, `prometheus`.

Hard-reject agents fail TeamSpec parsing because they cannot write mailbox state. Use `delegate-task` for those agents.

## Lifecycle

1.  `team_create` — spawns team and member sessions.
2.  Lead delegates work via `team_send_message`, `team_task_create`.
3.  Members claim tasks (`team_task_update` with `status: "claimed"`), report back via `team_send_message`.
4.  `team_shutdown_request` → member or lead acks via `team_approve_shutdown` / `team_reject_shutdown`.
5.  `team_delete` — removes runtime state, worktrees, optional tmux layout.

## 12 tools

| Tool | Purpose |
| --- | --- |
| `team_create` | Spawn a team. |
| `team_delete` | Tear down (lead only, no active members). |
| `team_shutdown_request` | Lead asks a member to wrap up. |
| `team_approve_shutdown` / `team_reject_shutdown` | Member or lead responds. |
| `team_send_message` | Peer-to-peer mailbox; lead-only broadcast. |
| `team_task_create` / `_list` / `_update` / `_get` | Shared task list. |
| `team_status` | Aggregate runtime view. |
| `team_list` | Declared + active teams. |

## Bounds (defaults)

-   8 members max, 4 in flight.
-   32 KB per message body, 256 KB per recipient unread.
-   10 000 messages per run, 120 minutes wall clock, 500 turns per member.

## Worktrees (optional per member)

Add `"worktreePath": "../wt-scout"` to a member entry. Path is filesystem-relative or absolute; bare branch names are rejected. Requires `git`.

## tmux visualization (optional)

Set `tmux_visualization: true`. Requires running inside a tmux session and tmux on PATH. Failures are isolated - a missing tmux never blocks team creation.

When enabled, each member gets a dedicated tmux pane attached to that member's session via `opencode attach`. The pane runs the full interactive opencode TUI for the member so you can watch streaming output in real time. Panes start in each member worktree when configured, otherwise the repo root.

`team_delete` closes the panes and tears down the team layout. Per-member shutdown closes just that pane and rebalances the remaining layout.

## What team mode does NOT do

-   No nested teams (members cannot call `team_create`).
-   No synchronous reply waits (`team_send_message` is fire-and-forget).
-   No member-driven `delegate-task` (budget defaults to 0).
-   No shutdown bypass — `team_delete` rejects active members.

## Diagnostics

`bunx oh-my-openagent doctor` includes a `team-mode` check showing tmux/git availability, declared team count, and active runtime dirs.

## Storage layout

```
~/.omo/
├── teams/{name}/config.json                      # declared specs
├── .highwatermark                                # parity marker for runtime state
└── runtime/{teamRunId}/
    ├── state.json                                # durable runtime state
    ├── inboxes/{member}/{uuid}.json              # mailbox (atomic per-message files)
    ├── inboxes/{member}/.delivering-{uuid}.json  # transient live-delivery reservation
    ├── inboxes/{member}/processed/               # acked messages
    └── tasks/{id}.json                           # shared task list
```

`.delivering-{uuid}.json` files exist only while a message is being live-delivered via `promptAsync`. They are committed to `processed/` on delivery success, released back to `{uuid}.json` on failure, or reclaimed on team resume if stranded by a crash (10 minute TTL). `listUnreadMessages` ignores dotfile entries so the fallback poll never double-injects a reserved message.

## Reference

Full design: `.omo/plans/team-mode.md`.

## CLI Reference

Complete reference for the published CLI package. During the rename transition, both package names work:

-   `oh-my-openagent` (preferred package name)
-   `oh-my-opencode` (compatibility package name)

Plugin registration inside `opencode.json` prefers `oh-my-openagent`.

## Bin Commands

All published packages expose the same compiled CLI with these bin entries:

-   `oh-my-openagent` (preferred name)
-   `oh-my-opencode` (legacy compatibility name)
-   `omo` (short alias, recommended in docs and prompts)
-   `lazycodex-ai` (Light edition shortcut; `lazycodex-ai install` is equivalent to `omo install --platform=codex`; any explicit `--platform` value must be `codex`)

## Basic Usage

```
# Display help (preferred package)
bunx oh-my-openagent

# Compatibility package
bunx oh-my-opencode
```

## Commands

| Command | Description |
| --- | --- |
| `install` | Interactive setup wizard |
| `uninstall` / `cleanup` | Remove managed Codex Light state |
| `doctor` | Installation health diagnostics |
| `run <message>` | Non-interactive OpenCode session runner with completion enforcement |
| `get-local-version` | Show current installed version and check for updates |
| `refresh-model-capabilities` | Refresh cached model capabilities snapshot from models.dev |
| `boulder` | Inspect Sisyphus boulder work-state (active plan, per-task timers, session lineage) |
| `version` | Show CLI version |
| `mcp oauth` | OAuth token management for MCP servers |

___

## install

Interactive installation tool for initial setup.

### Usage

```
bunx oh-my-openagent install
```

### Options

| Option | Description |
| --- | --- |
| `--no-tui` | Run in non-interactive mode (requires all needed options) |
| `--platform <value>` | Install target edition: `opencode` (Ultimate, default), `codex` (Light), or `both` |
| `--claude <value>` | Claude subscription: `no`, `yes`, `max20` (Ultimate only) |
| `--openai <value>` | OpenAI/ChatGPT subscription: `no`, `yes` (Ultimate only) |
| `--gemini <value>` | Gemini integration: `no`, `yes` (Ultimate only) |
| `--copilot <value>` | GitHub Copilot subscription: `no`, `yes` (Ultimate only) |
| `--opencode-zen <value>` | OpenCode Zen access: `no`, `yes` (Ultimate only) |
| `--zai-coding-plan <value>` | Z.ai Coding Plan subscription: `no`, `yes` (Ultimate only) |
| `--kimi-for-coding <value>` | Kimi For Coding subscription: `no`, `yes` (Ultimate only) |
| `--opencode-go <value>` | OpenCode Go subscription: `no`, `yes` (Ultimate only) |
| `--vercel-ai-gateway <value>` | Vercel AI Gateway: `no`, `yes` (Ultimate only) |
| `--codex-autonomous` | Configure Codex with `approval_policy = "never"`, `sandbox_mode = "danger-full-access"`, and `network_access = "enabled"` when installing Light or Both |
| `--no-codex-autonomous` | Leave existing Codex permission settings unchanged when installing Light or Both |
| `--skip-auth` | Skip authentication setup hints |

When using the `lazycodex-ai` bin alias, `install` defaults to `--platform=codex`. `lazycodex-ai` is only the npm/bin alias; `lazycodex` is the marketplace repository name. The Codex config uses marketplace `sisyphuslabs` and plugin `omo`, enabled as `omo@sisyphuslabs`, with the marketplace source set to the local built cache under `~/.codex/plugins/cache/sisyphuslabs`.

Subscription flags (`--claude`, `--openai`, etc.) only apply when `--platform` is `opencode` or `both`. They are rejected under `--platform=codex` because the Light edition does not write OpenCode model config. `--codex-autonomous` and `--no-codex-autonomous` only affect installs where the selected platform includes Codex.

### Telemetry and opt-out

Anonymous telemetry uses PostHog with a hashed installation identifier. Two streams exist:

-   `omo_daily_active`: fired by the main plugin when it loads (`reason: "plugin_loaded"`) and by `oh-my-openagent run` (`reason: "run_started"`).
-   `omo_codex_daily_active`: fired by `omo install --platform=codex` or `--platform=both` (`reason: "install_completed"`) and by the Codex plugin's `SessionStart` hook on every Codex session (`reason: "session_start"`). Both sources share the same UTC-day deduplication, so daily/weekly/monthly active counts reflect real Codex usage, not just install events.

Opt-out env vars:

-   Global opt-out for oh-my-openagent and omo-codex: `OMO_SEND_ANONYMOUS_TELEMETRY=0` or `OMO_DISABLE_POSTHOG=1`
-   Codex-only opt-out for `omo_codex_daily_active`: `OMO_CODEX_SEND_ANONYMOUS_TELEMETRY=0` or `OMO_CODEX_DISABLE_POSTHOG=1`

The OpenCode plugin can also opt out through oh-my-openagent config with `"telemetry": false`.

For the full Codex Light event inventory, collected properties, local state path, and lazycodex marketplace copy path, see [Codex Light telemetry](https://omo.dev/codex-telemetry.md).

___

## uninstall / cleanup

Removes managed Codex Light state. `cleanup` remains available as a backward-compatible alias.

### Usage

```
npx lazycodex-ai uninstall
omo uninstall --platform=codex
```

### Options

| Option | Description |
| --- | --- |
| `--platform codex` | Required when using the shared `omo` CLI unless `OMO_INVOCATION_NAME` is `lazycodex-ai` |
| `--codex-home <path>` | Codex home to clean, defaulting to `CODEX_HOME` or `~/.codex` |
| `--project <path>` | Project directory to inspect for project-local legacy Codex artifacts |
| `--json` | Output structured JSON result |

The command removes the managed `sisyphuslabs` plugin cache and marketplace snapshot, strips `omo@sisyphuslabs` plugin, hook-state, and managed agent blocks from `~/.codex/config.toml` after writing a backup, and removes managed agent TOML files from `~/.codex/agents/`, including orphaned files whose install manifest is already gone. Project-owned `.codex` artifacts are reported, not deleted.

___

## doctor

Diagnoses your environment and configuration. Checks are grouped into four categories: **System**, **Config**, **Tools**, and **Models**.

### Usage

```
bunx oh-my-openagent doctor
```

### Options

| Option | Description |
| --- | --- |
| `--status` | Show compact system dashboard |
| `--verbose` | Show detailed diagnostic information |
| `--json` | Output results in JSON format |

### Notes

-   The current minimum OpenCode version check is `>= 1.4.0`.
-   The doctor command warns when legacy plugin registration (`oh-my-opencode`) is still present in `opencode.json`.

___

## run

Runs a non-interactive session and exits only when both conditions are true:

-   all todos are completed or cancelled
-   all background child sessions are idle

### Usage

```
bunx oh-my-openagent run <message>
```

### Options

| Option | Description |
| --- | --- |
| `-a, --agent <name>` | Agent to use (default resolution chain applies) |
| `-m, --model <provider/model>` | Model override (example: `anthropic/claude-sonnet-4`) |
| `-d, --directory <path>` | Working directory |
| `-p, --port <port>` | Server port (attaches if already in use) |
| `--attach <url>` | Attach to an existing OpenCode server URL |
| `--on-complete <command>` | Run shell command after completion |
| `--json` | Output structured JSON result |
| `--no-timestamp` | Disable timestamp prefix in output |
| `--verbose` | Show full event stream (default: messages/tools only) |
| `--session-id <id>` | Resume an existing session |

### Agent Resolution Order

1.  `--agent`
2.  `OPENCODE_DEFAULT_AGENT`
3.  `default_run_agent` in plugin config
4.  `Sisyphus`

___

## get-local-version

Shows local plugin version state and update status.

### Usage

```
bunx oh-my-openagent get-local-version
```

### Options

| Option | Description |
| --- | --- |
| `-d, --directory <path>` | Working directory used for plugin/config detection |
| `--json` | Output JSON for scripting |

___

## refresh-model-capabilities

Refreshes the cached model capabilities snapshot from models.dev.

### Usage

```
bunx oh-my-openagent refresh-model-capabilities
```

### Options

| Option | Description |
| --- | --- |
| `-d, --directory <path>` | Working directory used to read plugin config |
| `--source-url <url>` | Override models.dev source URL |
| `--json` | Output refresh summary as JSON |

### Configuration

```
{
  "model_capabilities": {
    "enabled": true,
    "auto_refresh_on_start": true,
    "refresh_timeout_ms": 5000,
    "source_url": "https://models.dev/api.json"
  }
}
```

___

## version

Shows CLI package version.

### Usage

```
bunx oh-my-openagent version
```

___

## mcp oauth

OAuth token management for MCP servers (Tier-3 MCP OAuth flow, including PKCE and dynamic client registration when supported by the server).

### Usage

```
# Authenticate
bunx oh-my-openagent mcp oauth login <server-name> --server-url https://api.example.com

# Authenticate with explicit client ID and scopes
bunx oh-my-openagent mcp oauth login <server-name> --server-url https://api.example.com --client-id my-client --scopes read write

# Remove stored tokens
bunx oh-my-openagent mcp oauth logout <server-name> --server-url https://api.example.com

# Show token status
bunx oh-my-openagent mcp oauth status [server-name]
```

### Options

| Option | Description |
| --- | --- |
| `--server-url <url>` | OAuth server URL (required by `login`, and required by `logout`) |
| `--client-id <id>` | OAuth client ID (optional if server supports DCR) |
| `--scopes <scopes...>` | OAuth scopes as variadic values |

___

## Exit Codes

-   `0` on success
-   `1` on failure

`run`, `install`, `doctor`, `get-local-version`, `refresh-model-capabilities`, and `mcp oauth` subcommands return explicit numeric exit codes.

## Configuration Reference

Complete reference for Oh My OpenCode plugin configuration. Every omo harness reads one unified config file, `omo.jsonc`; the legacy `oh-my-openagent.json[c]` / `oh-my-opencode.json[c]` files are imported once by the migration engine and are no longer read at runtime.

___

## Table of Contents

-   [Getting Started](https://omo.dev/docs#getting-started)
    -   [File Locations](https://omo.dev/docs#file-locations)
    -   [Quick Start Example](https://omo.dev/docs#quick-start-example)
-   [Core Concepts](https://omo.dev/docs#core-concepts)
    -   [Agents](https://omo.dev/docs#agents)
    -   [Categories](https://omo.dev/docs#categories)
    -   [Model Resolution](https://omo.dev/docs#model-resolution)
-   [Task System](https://omo.dev/docs#task-system)
    -   [Background Tasks](https://omo.dev/docs#background-tasks)
    -   [Sisyphus Agent](https://omo.dev/docs#sisyphus-agent)
    -   [Sisyphus Tasks](https://omo.dev/docs#sisyphus-tasks)
-   [Features](https://omo.dev/docs#features)
    -   [Skills](https://omo.dev/docs#skills)
    -   [Hooks](https://omo.dev/docs#hooks)
    -   [Commands](https://omo.dev/docs#commands)
    -   [Browser Automation](https://omo.dev/docs#browser-automation)
    -   [Tmux Integration](https://omo.dev/docs#tmux-integration)
    -   [Git Master](https://omo.dev/docs#git-master)
    -   [Comment Checker](https://omo.dev/docs#comment-checker)
    -   [Notification](https://omo.dev/docs#notification)
    -   [MCPs](https://omo.dev/docs#mcps)
    -   [LSP](https://omo.dev/docs#lsp)
    -   [CodeGraph](https://omo.dev/docs#codegraph)
-   [Advanced](https://omo.dev/docs#advanced)
    -   [Runtime Fallback](https://omo.dev/docs#runtime-fallback)
    -   [Model Capabilities](https://omo.dev/docs#model-capabilities)
    -   [Hashline Edit](https://omo.dev/docs#hashline-edit)
    -   [Experimental](https://omo.dev/docs#experimental)
-   [Reference](https://omo.dev/docs#reference)
    -   [Environment Variables](https://omo.dev/docs#environment-variables)
    -   [Provider-Specific](https://omo.dev/docs#provider-specific)

___

## Getting Started

### File Locations

One unified file configures every omo harness: the OpenCode plugin, Senpi (task, codegraph, config-watch), and the Codex codegraph loader. The legacy `oh-my-openagent.json[c]` / `oh-my-opencode.json[c]` files and `~/.omo/config.jsonc` are read by nothing but the migration engine (see [Migration](https://omo.dev/docs#migration)).

1.  User layer (lowest precedence): `~/.omo/omo.jsonc` on every platform (`omo.json` is accepted as a fallback basename).
2.  Project layers: `.omo/omo.jsonc` (then `.omo/omo.json`) in every directory from the working directory up to `$HOME`. Farther ancestors merge first, so the nearest project file wins and beats the user layer. `$HOME` itself is skipped by the walk because `~/.omo` is already the user layer. If the working directory is outside `$HOME`, only that directory is checked.

#### Resolution Order

Within the merged document each harness resolves its own view VSCode-style, later layers winning:

1.  Shared base keys
2.  The `[harness]` block: `[opencode]`, `[senpi]`, or `[codex]`
3.  `profiles.<name>`
4.  `profiles.<name>.[harness]`

Defaults apply once at the end. The option keys documented in this reference are the contents of the `[opencode]` block. `agents` and `categories` can also live at the shared base level so every harness sees them, using the shared field set documented in the [omo.json reference](https://omo.dev/omo-json.md); OpenCode-specific agent options belong in `[opencode]`.

#### Profiles

No default profiles ship: a profile exists only when you write one under `profiles.<name>` or the migration derives one from a legacy profile directory. Activation, highest priority first:

1.  `OMO_PROFILE`
2.  `OCX_PROFILE` (set by `ocx oc -p <name>`)
3.  An `OPENCODE_CONFIG_DIR` whose path ends in `profiles/<name>`
4.  None

Activating a profile that does not exist produces a diagnostic and falls back to the base configuration.

#### Model Catalog

A top-level `models` record maps a short name to `{ model, variant?, reasoningEffort? }`. When an agent or category `model` string matches a catalog key, it resolves to the entry's model id and fills any unset `variant` / `reasoningEffort` from the entry; tuning written at the use site always wins. `[harness]` blocks can override individual catalog entries for one harness.

#### Security Invariants

`mcp_env_allowlist` and `browser_automation_engine.playwright_mcp_args` are honored only from the user layer, including the user layer's own active profile block. Project layers cannot extend them.

JSONC supports `// line comments`, `/* block comments */`, and trailing commas.

Enable schema autocomplete:

```
{
  "$schema": "https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/dev/assets/omo.schema.json"
}
```

Run `bunx oh-my-openagent install` for guided setup. Run `opencode models` to list available models.

#### Migration

The first time a current harness starts (and again on install or via the CLI), a lock-and-journal migration engine imports the legacy files into the unified file:

-   Sources: `oh-my-openagent.json[c]` / `oh-my-opencode.json[c]` in the OpenCode user config directory, in each of its `profiles/<name>/` directories, and in walked project `.opencode/` directories, plus `~/.omo/config.jsonc`.
-   Targets: the legacy user file imports into `~/.omo/omo.jsonc` under `[opencode]`; each legacy profile becomes `profiles.<name>."[opencode]"` holding only the keys that differ from the user file; a project file imports into that project's `.omo/omo.jsonc`. `~/.omo/config.jsonc` imports its shared `codegraph` settings plus its `[opencode]` / `[codex]` blocks, and a legacy `[omo]` block maps to `[senpi]`.
-   Conflict policy: no-clobber. A value already present in the target wins, and every skipped legacy value is reported as a diagnostic instead of overwriting. Prior legacy migration history is preserved under the target's `legacy_migrations` key.
-   Markers: each applied migration records its id in the target's `_migrations` array, so re-runs are no-ops. `2026-07-opencode-config-unification` covers the `oh-my-*` files; `2026-07-codex-config-jsonc` covers `~/.omo/config.jsonc`. Codex startup runs only the second group; OpenCode plugin startup, Senpi startup, install, and the CLI run both groups, so whichever side runs first applies each group exactly once.
-   Backups: sources move to `~/.omo/migration-backup-<UTC timestamp>-opencode-config/` (project sources to `<project>/.omo/migration-backup-<UTC timestamp>/`). An interrupted run resumes from its journal on the next start.
-   Manual run: `oh-my-openagent config migrate`. `--dry-run` prints the transform, backup move plan, and conflicts without writing; `--json` prints machine-readable output.
-   Diagnostics surface once per startup: an OpenCode toast, a Senpi `session_start` notification, or Codex loader warnings.

### Quick Start Example

Here's a practical starting `~/.omo/omo.jsonc`. OpenCode plugin settings live inside the `[opencode]` block:

```
{
  "$schema": "https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/dev/assets/omo.schema.json",

  "[opencode]": {
    "agents": {
      // Main orchestrator: Claude Opus or Kimi K3 work best
      "sisyphus": {
        "model": "kimi-for-coding/kimi-k3",
        "ultrawork": { "model": "anthropic/claude-opus-5", "variant": "max" },
      },

      // Research agents: cheap fast models are fine
      "librarian": { "model": "google/gemini-3.6-flash" },
      "explore": { "model": "github-copilot/grok-code-fast-1" },

      // Architecture consultation: GPT-5.6 Sol or Claude Opus
      "oracle": { "model": "openai/gpt-5.6-sol", "variant": "high" },

      // Prometheus inherits sisyphus model; just add prompt guidance
      "prometheus": {
        "prompt_append": "Leverage deep & quick agents heavily, always in parallel.",
      },
    },

    "categories": {
      // quick - Kimi high-speed by default
      "quick": { "model": "kimi-for-coding/kimi-for-coding-highspeed" },

      // unspecified-low - moderate tasks
      "unspecified-low": { "model": "openai/gpt-5.6-luna", "variant": "xhigh" },

      // unspecified-high - complex work
      "unspecified-high": { "model": "kimi-for-coding/kimi-k3", "variant": "max" },

      // writing - docs/prose
      "writing": { "model": "kimi-for-coding/kimi-k3", "variant": "low" },

      // visual-engineering - Opus 5, then Kimi K3 and GLM 5.2
      "visual-engineering": {
        "model": "anthropic/claude-opus-5",
        "variant": "max",
      },

      // Custom category for git operations
      "git": {
        "model": "opencode/gpt-5-nano",
        "description": "All git operations",
        "prompt_append": "Focus on atomic commits, clear messages, and safe operations.",
      },
    },

    // Limit expensive providers; let cheap ones run freely
    "background_task": {
      "providerConcurrency": {
        "anthropic": 3,
        "openai": 3,
        "opencode": 10,
        "zai-coding-plan": 10,
      },
      "modelConcurrency": {
        "anthropic/claude-opus-5": 2,
        "opencode/gpt-5-nano": 20,
      },
    },

    "experimental": { "aggressive_truncation": true, "task_system": true },
    "tmux": { "enabled": false },
  },
}
```

___

## Core Concepts

### Agents

Override built-in agent settings. Available agents: `sisyphus`, `hephaestus`, `prometheus`, `oracle`, `librarian`, `explore`, `multimodal-looker`, `metis`, `momus`, `atlas`, `sisyphus-junior`.

```
{
  "agents": {
    "explore": { "model": "anthropic/claude-haiku-4-5", "temperature": 0.5 },
    "multimodal-looker": { "disable": true }
  }
}
```

Disable agents entirely: `{ "disabled_agents": ["oracle", "multimodal-looker"] }`

Agent tab cycling defaults to Sisyphus, Hephaestus, Prometheus, Atlas. Override known agent ordering with `agent_order`; omitted core agents keep their default relative order. Unknown or duplicate names are ignored and reported with a config toast.

```
{
  "agent_order": ["hephaestus", "sisyphus", "prometheus", "atlas"]
}
```

#### Agent Options

| Option | Type | Description |
| --- | --- | --- |
| `model` | string | Model override (`provider/model`) |
| `fallback_models` | string|array | Fallback models on API errors. Supports strings or mixed arrays of strings and object entries with per-model settings |
| `temperature` | number | Sampling temperature |
| `top_p` | number | Top-p sampling |
| `prompt` | string | Replace system prompt. Supports `file://` URIs |
| `prompt_append` | string | Append to system prompt. Supports `file://` URIs |
| `tools` | array | Allowed tools list |
| `disable` | boolean | Disable this agent |
| `mode` | string | Agent mode |
| `color` | string | UI color |
| `permission` | object | Per-tool permissions (see below) |
| `category` | string | Inherit model from category |
| `variant` | string | Model variant: `max`, `high`, `medium`, `low`, `xhigh`. Normalized to supported values |
| `maxTokens` | number | Max response tokens |
| `thinking` | object | Anthropic extended thinking |
| `reasoningEffort` | string | OpenAI reasoning: `none`, `minimal`, `low`, `medium`, `high`, `xhigh`, `max`. Normalized to supported values |
| `textVerbosity` | string | Text verbosity: `low`, `medium`, `high` |
| `providerOptions` | object | Provider-specific options |

Prometheus is the exception for prompt replacement: its mandatory planner prompt always remains active so it can load `ulw-plan` first. For `agents.prometheus`, both `prompt` and `prompt_append` are appended to the mandatory base prompt instead of replacing it.

#### Anthropic Extended Thinking

```
{
  "agents": {
    "oracle": { "thinking": { "type": "enabled", "budgetTokens": 200000 } }
  }
}
```

#### Agent Permissions

Control what tools an agent can use:

```
{
  "agents": {
    "explore": {
      "permission": {
        "edit": "deny",
        "bash": "ask",
        "webfetch": "allow"
      }
    }
  }
}
```

| Permission | Values |
| --- | --- |
| `edit` | `ask` / `allow` / `deny` |
| `bash` | `ask` / `allow` / `deny` or per-command: `{ "git": "allow", "rm": "deny" }` |
| `webfetch` | `ask` / `allow` / `deny` |
| `doom_loop` | `ask` / `allow` / `deny` |
| `external_directory` | `ask` / `allow` / `deny` |

#### Fallback Models with Per-Model Settings

`fallback_models` accepts either a single model string or an array. Array entries can be plain strings or objects with individual model settings:

```
{
  "agents": {
    "sisyphus": {
      "model": "anthropic/claude-opus-5",
      "fallback_models": [
        // Simple string fallback
        "openai/gpt-5.6-sol",
        // Object with per-model settings
        {
          "model": "google/gemini-3.1-pro",
          "variant": "high",
          "temperature": 0.2
        },
        {
          "model": "anthropic/claude-sonnet-5",
          "thinking": { "type": "enabled", "budgetTokens": 64000 }
        }
      ]
    }
  }
}
```

Object entries support: `model`, `variant`, `reasoningEffort`, `temperature`, `top_p`, `maxTokens`, `thinking`.

#### File URIs for Prompts

Both `prompt` and `prompt_append` support loading content from files via `file://` URIs. Category-level `prompt_append` supports the same URI forms.

For Prometheus, file-backed `prompt` content is appended after the mandatory base prompt; it does not replace the base prompt.

```
{
  "agents": {
    "sisyphus": {
      "prompt_append": "file:///absolute/path/to/prompt.txt"
    },
    "oracle": {
      "prompt": "file://./relative/to/project/prompt.md"
    },
    "explore": {
      "prompt_append": "file://~/home/dir/prompt.txt"
    }
  },
  "categories": {
    "custom": {
      "model": "anthropic/claude-sonnet-5",
      "prompt_append": "file://./category-context.md"
    }
  }
}
```

Paths can be absolute (`file:///abs/path`), relative to project root (`file://./rel/path`), or home-relative (`file://~/home/path`). If a file URI cannot be decoded, resolved, or read, OmO inserts a warning placeholder into the prompt instead of failing hard.

### Categories

Domain-specific model delegation used by the `task()` tool. When Sisyphus delegates work, it picks a category, not a model name.

#### Built-in Categories

| Category | Default Model | Description |
| --- | --- | --- |
| `visual-engineering` | `anthropic/claude-opus-5` (max) | Frontend, UI/UX, design, animation |
| `ultrabrain` | `openai/gpt-5.6-sol` (xhigh) | Deep logical reasoning, complex architecture |
| `deep` | `openai/gpt-5.6-sol` (medium) | Autonomous problem-solving, thorough research |
| `artistry` | `anthropic/claude-fable-5` (xhigh) | Creative/unconventional approaches |
| `quick` | `kimi-for-coding/kimi-for-coding-highspeed` | Trivial tasks, typo fixes, single-file changes |
| `unspecified-low` | `openai/gpt-5.6-luna` (xhigh) | General tasks, low effort |
| `unspecified-high` | `kimi-for-coding/kimi-k3` (max) | General tasks, high effort |
| `writing` | `kimi-for-coding/kimi-k3` (low) | Documentation, prose, technical writing |

> **Note**: Built-in category defaults are available automatically. User-defined category config merges over the built-in defaults or adds custom categories.

#### Category Options

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `model` | string | \- | Model override |
| `requiresModel` | string | \- | Exact model required for this category to spawn. Used by `deep` to require `gpt-5.6-sol`. |
| `fallback_models` | string|array | \- | Fallback models on API errors. Supports strings or mixed arrays of strings and object entries with per-model settings |
| `temperature` | number | \- | Sampling temperature |
| `top_p` | number | \- | Top-p sampling |
| `maxTokens` | number | \- | Max response tokens |
| `thinking` | object | \- | Anthropic extended thinking |
| `reasoningEffort` | string | \- | OpenAI reasoning effort. Unsupported values are normalized |
| `textVerbosity` | string | \- | Text verbosity |
| `tools` | object | \- | Tool usage control (disable with `{ "tool_name": false }`) |
| `prompt_append` | string | \- | Append to system prompt |
| `max_prompt_tokens` | number | \- | Maximum prompt tokens for delegated tasks |
| `variant` | string | \- | Model variant. Unsupported values are normalized |
| `description` | string | \- | Shown in `task()` tool prompt |
| `is_unstable_agent` | boolean | `false` | Force background mode + monitoring. Auto-enabled for Gemini models. |
| `disable` | boolean | `false` | Exclude this category from task delegation |
| `warn_unavailable` | boolean | \- | Suppress the once-per-session dead-chain warning for this category. A category set here still respects the global `task.warnings.unavailable_categories` flag. |
| `warn_unavailable` | boolean | \- | Suppress the once-per-session dead-chain warning for this category. A category set here still respects the global `task.warnings.unavailable_categories` flag. |

Disable categories: `{ "categories": { "ultrabrain": { "disable": true } } }`

### Model Resolution

Runtime priority:

The same resolved chain drives spawn-time selection and runtime retry fallback, so a recovered task stays on the same category chain.

A builtin category can be hidden from `availableCategories` when none of its fallback-chain rungs resolves against the live registry. Spawns then fail with `model_unavailable`, carry the attempted chain and missing providers, and emit a once-per-session warning unless `task.warnings.unavailable_categories` is false or `categories.<name>.warn_unavailable` is false. Setting an explicit category model is the forcing path.

1.  **UI-selected model** - model chosen in the OpenCode UI, for primary agents
2.  **User override** - model set in config → used exactly as-is. Even on cold cache, explicit user configuration takes precedence over hardcoded fallback chains
3.  **Category default** - model inherited from the assigned category config
4.  **User `fallback_models`** - user-configured fallback list is tried before built-in fallback chains
5.  **Provider fallback chain** - built-in provider/model chain from OmO source
6.  **System default** - OpenCode's configured default model

The same resolved chain drives spawn-time selection and runtime retry fallback, so a recovered task stays on the same category chain.

A builtin category can be hidden from `availableCategories` when none of its fallback-chain rungs resolves against the live registry. Spawns then fail with `model_unavailable`, carry the attempted chain and missing providers, and emit a once-per-session warning unless `task.warnings.unavailable_categories` is false or `categories.<name>.warn_unavailable` is false. Setting an explicit category model is the forcing path.

A builtin category can be hidden from `availableCategories` when none of its fallback-chain rungs resolves against the live registry. Spawns then fail with `model_unavailable`, carry the attempted chain and missing providers, and emit a once-per-session warning unless `task.warnings.unavailable_categories` is false or `categories.<name>.warn_unavailable` is false. Setting an explicit category model is the forcing path.

#### Model Settings Compatibility

Model settings are compatibility-normalized against model capabilities instead of failing hard.

Normalized fields:

-   `variant` - downgraded to the closest supported value
-   `reasoningEffort` - downgraded to the closest supported value, or removed if unsupported
-   `temperature` - removed if unsupported by the model metadata
-   `top_p` - removed if unsupported by the model metadata
-   `maxTokens` - capped to the model's reported max output limit
-   `thinking` - removed if the target model does not support thinking

Examples:

-   Claude models do not support `reasoningEffort` - it is removed automatically
-   GPT-4.1 does not support reasoning - `reasoningEffort` is removed
-   o-series models support `none` through `high` - `xhigh` is downgraded to `high`
-   GPT-5 supports `none`, `minimal`, `low`, `medium`, `high`, `xhigh` - all pass through

Capability data comes from provider runtime metadata first. OmO also ships bundled models.dev-backed capability data, supports a refreshable local models.dev cache, and falls back to heuristic family detection plus alias rules when exact metadata is unavailable. `bunx oh-my-openagent doctor` surfaces capability diagnostics and warns when a configured model relies on compatibility fallback.

#### Agent Provider Chains

| Agent | Default Model | Provider Priority |
| --- | --- | --- |
| **Sisyphus** | `claude-opus-5` | `anthropic|github-copilot|opencode|vercel/claude-opus-5 (max)` → `opencode-go|kimi-for-coding|moonshotai|opencode|vercel|bailian-coding-plan|moonshotai-cn|firmware|ollama-cloud|aihubmix/kimi-k3` → `openai|github-copilot|opencode|vercel/gpt-5.6-sol (medium)` → `zai-coding-plan|opencode|bailian-coding-plan|vercel/glm-5.2` → `opencode/big-pickle` |
| **Hephaestus** | `gpt-5.6-sol` | `openai|github-copilot|vercel|opencode/gpt-5.6-sol (medium)` |
| **Oracle** | `gpt-5.6-sol` | `openai|opencode|vercel/gpt-5.6-sol (xhigh)` → `github-copilot/gpt-5.6-sol (high)` → `google|github-copilot|opencode|vercel/gemini-3.1-pro (high)` → `anthropic|github-copilot|opencode|vercel/claude-opus-5 (max)` → `opencode-go|vercel/glm-5.2` |
| **Librarian** | `gpt-5.6-luna-fast` | `openai/gpt-5.6-luna-fast` → `deepseek/deepseek-v4-flash (max)` → `opencode-go|bailian-coding-plan/qwen3.7-plus` → `vercel/minimax-m2.7-highspeed` → `opencode-go|vercel/minimax-m3` → `minimax-coding-plan|minimax-cn-coding-plan/MiniMax-M3` → `opencode-go|vercel/minimax-m2.7` → `anthropic|github-copilot|vercel/claude-haiku-4-5` → `openai|vercel/gpt-5.4-nano` |
| **Explore** | `gpt-5.6-luna-fast` | `openai/gpt-5.6-luna-fast` → `deepseek/deepseek-v4-flash (max)` → `opencode-go|bailian-coding-plan/qwen3.7-plus` → `vercel/minimax-m2.7-highspeed` → `opencode-go|vercel/minimax-m3` → `minimax-coding-plan|minimax-cn-coding-plan/MiniMax-M3` → `opencode-go|vercel/minimax-m2.7` → `anthropic|github-copilot|vercel/claude-haiku-4-5` → `openai|vercel/gpt-5.4-nano` |
| **Multimodal Looker** | `gpt-5.6-sol` | `openai|opencode|vercel/gpt-5.6-sol (low)` → `opencode-go|vercel/kimi-k3` → `zai-coding-plan|vercel/glm-4.6v` → `openai|github-copilot|opencode|vercel/gpt-5-nano` |
| **Prometheus** | `claude-fable-5` | `anthropic|github-copilot|opencode|vercel/claude-fable-5 (xhigh)` → `opencode-go|kimi-for-coding|moonshotai|opencode|vercel/kimi-k3 (max)` |
| **Metis** | `claude-opus-5` | `anthropic|github-copilot|opencode|vercel/claude-opus-5 (high)` → `opencode-go|kimi-for-coding|moonshotai|opencode|vercel/kimi-k3 (low)` |
| **Momus** | `gpt-5.6-terra` | `openai|vercel/gpt-5.6-terra (high)` → `github-copilot/gpt-5.6-terra (high)` → `openai|opencode|vercel/gpt-5.6-sol (xhigh)` → `github-copilot/gpt-5.6-sol (high)` → `anthropic|github-copilot|opencode|vercel/claude-opus-5 (max)` → `google|github-copilot|opencode|vercel/gemini-3.1-pro (high)` → `opencode-go|vercel/glm-5.2` |
| **Atlas** | `claude-sonnet-5` | `anthropic|github-copilot|opencode|vercel/claude-sonnet-5` → `opencode-go|vercel/kimi-k3` → `openai|github-copilot|opencode|vercel/gpt-5.6-sol (medium)` → `opencode-go|vercel/minimax-m3` → `minimax-coding-plan|minimax-cn-coding-plan/MiniMax-M3` → `opencode-go|vercel/minimax-m2.7` |
| **Sisyphus Junior** | `claude-sonnet-5` | `anthropic|github-copilot|opencode|vercel/claude-sonnet-5` → `opencode-go|vercel/kimi-k3` → `openai|github-copilot|opencode|vercel/gpt-5.6-sol (medium)` → `opencode-go|vercel/minimax-m3` → `minimax-coding-plan|minimax-cn-coding-plan/MiniMax-M3` → `opencode-go|vercel/minimax-m2.7` → `opencode/big-pickle` |

#### Category Provider Chains

This table mirrors the authoritative hardcoded category fallback chains, including each default first rung and its remaining provider priority.

| Category | Provider Chain Primary | Provider Priority |
| --- | --- | --- |
| **Visual Engineering** | `claude-opus-5` | `anthropic|anthropic-api|github-copilot|opencode|vercel/claude-opus-5 (max)` → `kimi-for-coding|moonshotai|opencode-go|opencode|vercel/kimi-k3 (max)` → `zai-coding-plan|opencode-go|vercel/glm-5.2 (max)` → `openai|quotio-openai|github-copilot|opencode|vercel/gpt-5.6-sol (medium)` |
| **Ultrabrain** | `gpt-5.6-sol` | `openai|quotio-openai|vercel/gpt-5.6-sol (max)` → `github-copilot/gpt-5.6-sol (max)` → `openai|opencode|vercel/gpt-5.6-sol (max)` |
| **Deep** | `gpt-5.6-sol` | `openai|quotio-openai|github-copilot|opencode|vercel/gpt-5.6-sol (medium)` |
| **Artistry** | `claude-fable-5` | `anthropic|anthropic-api|github-copilot|opencode|vercel/claude-fable-5 (xhigh)` → `kimi-for-coding|moonshotai|opencode-go|opencode|vercel/kimi-k3 (max)` → `anthropic|anthropic-api|github-copilot|opencode|vercel/claude-opus-5 (xhigh)` |
| **Quick** | `kimi-for-coding-highspeed` | `kimi-for-coding/kimi-for-coding-highspeed` → `quotio-openai/gpt-5.6-luna-fast (low)` → `deepseek/deepseek-v4-flash (off)` → `qwen-token-plan|alibaba-token-plan|bailian-coding-plan|opencode-go|vercel/qwen3.6-flash (low)` → `opencode-go|vercel/minimax-m3 (max)` → `opencode-go|vercel/minimax-m2.7 (max)` → `xai/grok-4.20-0309-non-reasoning` → `anthropic|anthropic-api|github-copilot|vercel/claude-haiku-4-5 (off)` |
| **Unspecified Low** | `gpt-5.6-luna` | `openai|quotio-openai|github-copilot|opencode|vercel/gpt-5.6-terra (high)` → `anthropic|anthropic-api|github-copilot|opencode|vercel/claude-sonnet-5 (low)` → `qwen-token-plan|alibaba-token-plan|qwen-token-plan-cn|alibaba-token-plan-cn/qwen3.8-max-preview (max)` → `deepseek|opencode-go|vercel/deepseek-v4-pro (max)` → `xiaomi|opencode-go|vercel/mimo-v2.5-pro (max)` |
| **Unspecified High** | `kimi-k3` | `kimi-for-coding|moonshotai|opencode-go|opencode|vercel/kimi-k3 (max)` → `anthropic|anthropic-api|github-copilot|opencode|vercel/claude-opus-5 (xhigh)` → `openai|quotio-openai|github-copilot|opencode|vercel/gpt-5.6-sol (high)` |
| **Writing** | `kimi-k3` | `kimi-for-coding|moonshotai|opencode-go|opencode|vercel/kimi-k3 (low)` → `anthropic|anthropic-api|github-copilot|opencode|vercel/claude-opus-5 (low)` → `google|github-copilot|opencode|vercel/gemini-3.6-flash` |

Run `bunx oh-my-openagent doctor --verbose` to see effective model resolution for your config.

___

## Task System

### Background Tasks

Control parallel agent execution and concurrency limits.

```
{
  "background_task": {
    "defaultConcurrency": 5,
    "staleTimeoutMs": 180000,
    "providerConcurrency": { "anthropic": 3, "openai": 5, "google": 10 },
    "modelConcurrency": { "anthropic/claude-opus-5": 2 }
  }
}
```

| Option | Default | Description |
| --- | --- | --- |
| `defaultConcurrency` | \- | Max concurrent tasks (all providers) |
| `staleTimeoutMs` | `180000` | Interrupt tasks with no activity (min: 60000) |
| `providerConcurrency` | \- | Per-provider limits (key = provider name) |
| `modelConcurrency` | \- | Per-model limits (key = `provider/model`). Overrides provider limits. |

Priority: `modelConcurrency` > `providerConcurrency` > `defaultConcurrency`

### Sisyphus Agent

Configure the main orchestration system.

```
{
  "sisyphus_agent": {
    "disabled": false,
    "default_builder_enabled": false,
    "planner_enabled": true,
    "replace_plan": true
  }
}
```

| Option | Default | Description |
| --- | --- | --- |
| `disabled` | `false` | Disable all Sisyphus orchestration, restore original build/plan |
| `default_builder_enabled` | `false` | Enable OpenCode-Builder agent (off by default) |
| `planner_enabled` | `true` | Enable Prometheus (Planner) agent |
| `replace_plan` | `true` | Demote default plan agent to subagent mode |

Sisyphus agents can also be customized under `agents` using their names: `Sisyphus`, `OpenCode-Builder`, `Prometheus (Planner)`, `Metis (Plan Consultant)`.

### Sisyphus Tasks

File-based task persistence with dependency tracking, used for cross-session task management. The task system is controlled by `experimental.task_system` (defaults to `true` since v3.14). When enabled, `TodoWrite`/`TodoRead` are intercepted and replaced with the Task tools (`task_create`, `task_get`, `task_list`, `task_update`).

The `sisyphus.tasks` section configures **storage options** only:

```
{
  "sisyphus": {
    "tasks": {
      "storage_path": ".omo/tasks",
      "claude_code_compat": false
    }
  }
}
```

| Option | Default | Description |
| --- | --- | --- |
| `storage_path` | `.omo/tasks` | Storage path (relative to project root) |
| `task_list_id` | \- | Force task list ID (alternative to env `ULTRAWORK_TASK_LIST_ID`) |
| `claude_code_compat` | `false` | Enable Claude Code path compatibility mode |

To disable the task system entirely, set `experimental.task_system` to `false`:

```
{
  "experimental": { "task_system": false }
}
```

___

## Features

### Skills

Skills bring domain-specific expertise and embedded MCPs.

Built-in skills: `playwright`, `playwright-cli`, `agent-browser`, `dev-browser`, `git-master`, `frontend`

Disable built-in skills: `{ "disabled_skills": ["playwright"] }`

#### Skills Configuration

```
{
  "skills": {
    "sources": [
      { "path": "./my-skills", "recursive": true },
      "https://example.com/skill.yaml"
    ],
    "enable": ["my-skill"],
    "disable": ["other-skill"],
    "my-skill": {
      "description": "What it does",
      "template": "Custom prompt template",
      "from": "source-file.ts",
      "model": "custom/model",
      "agent": "custom-agent",
      "subtask": true,
      "argument-hint": "usage hint",
      "license": "MIT",
      "compatibility": ">= 3.0.0",
      "metadata": { "author": "Your Name" },
      "allowed-tools": ["read", "bash"]
    }
  }
}
```

| `sources` option | Default | Description |
| --- | --- | --- |
| `path` | \- | Local path or remote URL |
| `recursive` | `false` | Recurse into subdirectories |
| `glob` | \- | Glob pattern for file selection |

### Hooks

Disable built-in hooks via `disabled_hooks`:

```
{ "disabled_hooks": ["comment-checker"] }
```

Available hooks: `todo-continuation-enforcer`, `session-notification`, `comment-checker`, `tool-output-truncator`, `question-label-truncator`, `directory-agents-injector`, `directory-readme-injector`, `empty-task-response-detector`, `think-mode`, `model-fallback`, `anthropic-context-window-limit-recovery`, `preemptive-compaction`, `rules-injector`, `background-notification`, `auto-update-checker`, `codegraph-bootstrap`, `ast-grep-sg-provision`, `startup-toast`, `keyword-detector`, `agent-usage-reminder`, `non-interactive-env`, `interactive-bash-session`, `tool-pair-validator`, `monitor-status-injector`, `goal`, `category-skill-reminder`, `compaction-context-injector`, `compaction-todo-preserver`, `claude-code-hooks`, `auto-slash-command`, `edit-error-recovery`, `json-error-recovery`, `delegate-task-retry`, `prometheus-md-only`, `sisyphus-junior-notepad`, `team-tool-gating`, `no-sisyphus-gpt`, `no-hephaestus-non-gpt`, `hephaestus-agents-md-injector`, `start-work`, `atlas`, `unstable-agent-babysitter`, `task-resume-info`, `stop-continuation-guard`, `tasks-todowrite-disabler`, `runtime-fallback`, `write-existing-file-guard`, `notepad-write-guard`, `bash-file-read-guard`, `hashline-read-enhancer`, `read-image-resizer`, `todo-description-override`, `webfetch-redirect-guard`, `fsync-skip-warning`, `plan-format-validator`, `legacy-plugin-toast`

Guard hooks such as `team-tool-gating`, `write-existing-file-guard`, `bash-file-read-guard`, `webfetch-redirect-guard`, `prometheus-md-only`, `rules-injector`, and `tool-pair-validator` protect safety, permissions, or provider protocol correctness. Disable them only for audited local debugging in a trusted environment.

**Notes:**

-   `directory-agents-injector` - auto-disabled on OpenCode 1.1.37+ (native AGENTS.md support)
-   `no-sisyphus-gpt` - **do not disable**. It blocks incompatible GPT models for Sisyphus while allowing GPT-5.4 and the shared model-aware GPT-5.5/GPT-5.6 Sol prompt paths.
-   `startup-toast` is a sub-feature of `auto-update-checker`. Disable just the toast by adding `startup-toast` to `disabled_hooks`.

### Commands

Disable built-in commands via `disabled_commands`:

```
{ "disabled_commands": ["refactor", "start-work"] }
```

Available commands: `goal`, `refactor`, `start-work`, `stop-continuation`, `remove-ai-slops`, `hyperplan`

### Browser Automation

| Provider | Interface | Installation |
| --- | --- | --- |
| `playwright` (default) | MCP tools | Auto-installed via npx |
| `agent-browser` | Bash CLI | `bun add -g agent-browser && agent-browser install` |

Switch provider:

```
{ "browser_automation_engine": { "provider": "agent-browser" } }
```

### Tmux Integration

Run background subagents in separate tmux panes. Requires running inside tmux with `opencode --port <port>`.

```
{
  "tmux": {
    "enabled": true,
    "layout": "main-vertical",
    "main_pane_size": 60,
    "main_pane_min_width": 120,
    "agent_pane_min_width": 40
  }
}
```

| Option | Default | Description |
| --- | --- | --- |
| `enabled` | `false` | Enable tmux pane spawning |
| `layout` | `main-vertical` | `main-vertical` / `main-horizontal` / `tiled` / `even-horizontal` / `even-vertical` |
| `main_pane_size` | `60` | Main pane % (20–80) |
| `main_pane_min_width` | `120` | Min main pane columns |
| `agent_pane_min_width` | `40` | Min agent pane columns |

### Git Master

Configure git commit behavior:

```
{ "git_master": { "commit_footer": true, "include_co_authored_by": true } }
```

### Comment Checker

Customize the comment quality checker:

```
{
  "comment_checker": {
    "custom_prompt": "Your message. Use {{comments}} placeholder."
  }
}
```

### Notification

Force-enable session notifications:

```
{ "notification": { "force_enable": true } }
```

`force_enable` (`false`) - force session-notification even if external notification plugins are detected.

### MCPs

Built-in MCPs (enabled by default): `websearch` (Exa AI), `context7` (library docs), `grep_app` (GitHub code search), and `lsp` (local language-server tools). Structural search and rewrite is provided by the `ast-grep` skill instead of a built-in MCP.

```
{ "disabled_mcps": ["websearch", "context7", "grep_app", "lsp"] }
```

### LSP

LSP tools are served by the built-in `lsp` MCP server (see [MCPs](https://omo.dev/docs#mcps)). The previous top-level `"lsp"` block in the plugin config is no longer read; the unified config migration strips it when importing a legacy file.

To configure custom language servers, create `.opencode/lsp.json` at the project root. The MCP server is launched with `LSP_TOOLS_MCP_PROJECT_CONFIG=.opencode/lsp.json` and reads the server map from that file. The schema lives in the `packages/lsp-tools-mcp` vendored package (upstream: [code-yeongyu/lsp-tools-mcp](https://github.com/code-yeongyu/lsp-tools-mcp)).

To disable the LSP MCP entirely:

```
{ "disabled_mcps": ["lsp"] }
```

### CodeGraph

The `codegraph` MCP ships a pinned CodeGraph 1.5.0 binary; managed installs provisioned at 1.0.1 or 1.4.1 upgrade automatically, and project stores built by older versions remain compatible without a manual re-index. Two keys tune where it runs:

```
{
  "codegraph": {
    // The upstream shared daemon is on by default: one detached daemon per
    // project serves every client, exits after about five minutes idle, and
    // runs under an upstream PPID watchdog. Set false to keep the index
    // in-process with CODEGRAPH_NO_DAEMON=1 pinned.
    "daemon": true,

    // Extra exclude-only roots. Projects under these skip CodeGraph entirely.
    // Entries may be absolute, ~-relative, or relative to the home directory.
    "excluded_roots": ["~/scratch/codegraph"],

    // Codex only: failed SessionStart initialization attempts back off from
    // this base interval, doubling to a 24-hour cap. Minimum: 60000.
    "session_start_cooldown_ms": 900000
  }
}
```

The Codex SessionStart bootstrap checks only `<projectRoot>/.codegraph/codegraph.db`; it never calls `codegraph status`. An ancestor database covers nested projects, while per-project locks and persistent cooldown stamps suppress duplicate or repeatedly failing background initializers. Suppressions are recorded in `~/.omo/codegraph/session-start.jsonl` as actions including `skipped-cooldown`, `skipped-locked`, and `skipped-nested-root`.

An ambient `CODEGRAPH_NO_DAEMON=1` forces daemon-off even when `codegraph.daemon` is `true`. Inspect or stop running daemons with the upstream `codegraph daemon` command, an interactive picker that lists running daemons and stops the one you select.

Process hygiene is unconditional and has no config keys: a parent-liveness watchdog exits MCP server processes when their parent dies, a newly started lsp daemon reaps older-version daemons at startup, and a best-effort family sweep removes orphaned codegraph and lsp processes at startup on every adapter (OpenCode plugin startup, the Codex `SessionStart` hook, and Senpi session start).

___

## Advanced

### Runtime Fallback

Auto-switches to backup models on API errors.

**Simple configuration** (enable/disable with defaults):

```
{ "runtime_fallback": true }
```

```
{ "runtime_fallback": false }
```

**Advanced configuration** (full control):

```
{
  "runtime_fallback": {
    "enabled": true,
    "retry_on_errors": [429, 500, 502, 503, 504],
    "max_fallback_attempts": 3,
    "cooldown_seconds": 60,
    "timeout_seconds": 30,
    "notify_on_fallback": true
  }
}
```

| Option | Default | Description |
| --- | --- | --- |
| `enabled` | `false` | Enable runtime fallback |
| `retry_on_errors` | `[429,500,502,503,504]` | HTTP codes that trigger fallback. Also handles classified provider key errors. |
| `max_fallback_attempts` | `3` | Max fallback attempts per session (1–20) |
| `cooldown_seconds` | `60` | Seconds before retrying a failed model |
| `timeout_seconds` | `30` | Seconds before forcing next fallback. **Set to `0` to disable timeout-based escalation and `message.updated` provider retry signal detection.** Structured `session.status` retry events can still trigger fallback. |
| `notify_on_fallback` | `true` | Toast notification on model switch |

#### Speeding Up Fallback (Proxy APIs)

If you are using a proxy API provider, they may return different error codes (e.g., `401`, `403`, `404`) for quota exhaustion or model unavailability. To make fallback trigger instantly without waiting for long timeouts:

```
{
  "runtime_fallback": {
    "enabled": true,
    // Add your proxy's specific error codes to retry_on_errors
    "retry_on_errors": [400, 401, 403, 404, 429, 500, 502, 503, 504],
    "max_fallback_attempts": 3,
    "cooldown_seconds": 15, // Shorter cooldown
    "timeout_seconds": 10   // Detect hung proxy requests faster
  }
}
```

Define `fallback_models` per agent or category:

```
{
  "agents": {
    "sisyphus": {
      "model": "anthropic/claude-opus-5",
      "fallback_models": [
        "openai/gpt-5.6-sol",
        {
          "model": "google/gemini-3.1-pro",
          "variant": "high"
        }
      ]
    }
  }
}
```

`fallback_models` also supports object-style entries so you can attach settings to a specific fallback model:

```
{
  "agents": {
    "sisyphus": {
      "model": "anthropic/claude-opus-5",
      "fallback_models": [
        "openai/gpt-5.6-sol",
        {
          "model": "anthropic/claude-sonnet-5",
          "variant": "high",
          "thinking": { "type": "enabled", "budgetTokens": 12000 }
        },
        {
          "model": "openai/gpt-5.6-sol",
          "reasoningEffort": "high",
          "temperature": 0.2,
          "top_p": 0.95,
          "maxTokens": 8192
        }
      ]
    }
  }
}
```

Mixed arrays are allowed, so string entries and object entries can appear together in the same fallback chain.

#### Object-style `fallback_models`

Object entries use the following shape:

| Field | Type | Description |
| --- | --- | --- |
| `model` | string | Fallback model ID. Provider prefix is optional when OmO can inherit the current/default provider. |
| `variant` | string | Explicit variant override for this fallback entry. |
| `reasoningEffort` | string | OpenAI reasoning effort override for this fallback entry. |
| `temperature` | number | Temperature applied if this fallback model becomes active. |
| `top_p` | number | Top-p applied if this fallback model becomes active. |
| `maxTokens` | number | Max response tokens applied if this fallback model becomes active. |
| `thinking` | object | Anthropic thinking config applied if this fallback model becomes active. |

Per-model settings are **fallback-only**. They are promoted only when that specific fallback model is actually selected, so they do not override your primary model settings when the primary model resolves successfully.

`thinking` uses the same shape as the normal agent/category option:

| Field | Type | Description |
| --- | --- | --- |
| `type` | string | `enabled` or `disabled` |
| `budgetTokens` | number | Optional Anthropic thinking budget |

Object entries can also omit the provider prefix when OmO can infer it from the current/default provider. If you provide both inline variant syntax in `model` and an explicit `variant` field, the explicit `variant` field wins.

#### Full examples

**1\. Simple string chain**

Use strings when you only need an ordered fallback chain:

```
{
  "agents": {
    "atlas": {
      "model": "anthropic/claude-sonnet-5",
      "fallback_models": [
        "anthropic/claude-haiku-4-5",
        "openai/gpt-5.6-sol",
        "google/gemini-3.1-pro"
      ]
    }
  }
}
```

**2\. Same-provider shorthand**

If the primary model already establishes the provider, fallback entries can omit the prefix:

```
{
  "agents": {
    "atlas": {
      "model": "openai/gpt-5.6-sol",
      "fallback_models": [
        "gpt-5.6-luna-fast",
        {
          "model": "gpt-5.6-sol",
          "reasoningEffort": "medium",
          "maxTokens": 4096
        }
      ]
    }
  }
}
```

In this example OmO treats `gpt-5.6-luna-fast` and `gpt-5.6-sol` as OpenAI fallback entries because the current/default provider is already `openai`.

**3\. Mixed cross-provider chain**

Mix string entries and object entries when only some fallback models need special settings:

```
{
  "agents": {
    "sisyphus": {
      "model": "anthropic/claude-opus-5",
      "fallback_models": [
        "openai/gpt-5.6-sol",
        {
          "model": "anthropic/claude-sonnet-5",
          "variant": "high",
          "thinking": { "type": "enabled", "budgetTokens": 12000 }
        },
        {
          "model": "google/gemini-3.1-pro",
          "variant": "high"
        }
      ]
    }
  }
}
```

**4\. Category-level fallback chain**

`fallback_models` works the same way under `categories`:

```
{
  "categories": {
    "deep": {
      "model": "openai/gpt-5.6-sol",
      "fallback_models": [
        {
          "model": "openai/gpt-5.6-sol",
          "reasoningEffort": "xhigh",
          "maxTokens": 12000
        },
        {
          "model": "anthropic/claude-opus-5",
          "variant": "max",
          "temperature": 0.2
        },
        "google/gemini-3.1-pro(high)"
      ]
    }
  }
}
```

**5\. Full object entry with every supported field**

This shows every supported object-style parameter in one place:

```
{
  "agents": {
    "oracle": {
      "model": "openai/gpt-5.6-sol",
      "fallback_models": [
        {
          "model": "openai/gpt-5.6-sol(low)",
          "variant": "xhigh",
          "reasoningEffort": "high",
          "temperature": 0.3,
          "top_p": 0.9,
          "maxTokens": 8192,
          "thinking": {
            "type": "disabled"
          }
        }
      ]
    }
  }
}
```

In this example the explicit `"variant": "xhigh"` overrides the inline `(low)` suffix in `"model"`.

This final example is a **complete shape reference**. In real configs, prefer provider-appropriate settings:

-   use `reasoningEffort` for OpenAI reasoning models
-   use `thinking` for Anthropic thinking-capable models
-   use `variant`, `temperature`, `top_p`, and `maxTokens` only when that fallback model supports them

### Model Capabilities

OmO can refresh a local models.dev capability snapshot on startup. This cache is controlled by `model_capabilities`.

```
{
  "model_capabilities": {
    "enabled": true,
    "auto_refresh_on_start": true,
    "refresh_timeout_ms": 5000,
    "source_url": "https://models.dev/api.json"
  }
}
```

| Option | Default behavior | Description |
| --- | --- | --- |
| `enabled` | enabled unless explicitly set to `false` | Master switch for model capability refresh behavior |
| `auto_refresh_on_start` | refresh on startup unless explicitly set to `false` | Refresh the local models.dev cache during startup checks |
| `refresh_timeout_ms` | `5000` | Timeout for the startup refresh attempt |
| `source_url` | `https://models.dev/api.json` | Override the models.dev source URL |

Notes:

-   Startup refresh runs through the auto-update checker hook.
-   Manual refresh is available via `bunx oh-my-openagent refresh-model-capabilities`.
-   Provider runtime metadata still takes priority when OmO resolves capabilities for compatibility checks.

### Hashline Edit

Replaces the built-in `Edit` tool with a hash-anchored version using `LINE#ID` references to prevent stale-line edits. Disabled by default.

```
{ "hashline_edit": true }
```

When enabled, OmO registers the hash-anchored `edit` tool and activates the `hashline-read-enhancer` companion hook, which annotates Read output with `LINE#ID` markers. Opt in by setting `hashline_edit: true`. Disable the companion hook via `disabled_hooks` if needed.

### Experimental

```
{
  "experimental": {
    "truncate_all_tool_outputs": false,
    "aggressive_truncation": false,
    "disable_omo_env": false,
    "task_system": true,
    "dynamic_context_pruning": {
      "enabled": false,
      "notification": "detailed",
      "turn_protection": { "enabled": true, "turns": 3 },
      "protected_tools": [
        "task",
        "todowrite",
        "todoread",
        "lsp_rename",
        "session_read",
        "session_write",
        "session_search"
      ],
      "strategies": {
        "deduplication": { "enabled": true },
        "supersede_writes": { "enabled": true, "aggressive": false },
        "purge_errors": { "enabled": true, "turns": 5 }
      }
    }
  }
}
```

| Option | Default | Description |
| --- | --- | --- |
| `truncate_all_tool_outputs` | `false` | Truncate all tool outputs (not just whitelisted) |
| `aggressive_truncation` | `false` | Aggressively truncate when token limit exceeded |
| `disable_omo_env` | `false` | Disable auto-injected `<omo-env>` block (date/time/locale). Improves cache hit rate. |
| `task_system` | `false` | Enable Sisyphus task system |
| `dynamic_context_pruning.enabled` | `false` | Auto-prune old tool outputs to manage context window |
| `dynamic_context_pruning.notification` | `detailed` | Pruning notifications: `off` / `minimal` / `detailed` |
| `turn_protection.turns` | `3` | Recent turns protected from pruning (1–10) |
| `strategies.deduplication` | `true` | Remove duplicate tool calls |
| `strategies.supersede_writes` | `true` | Prune write inputs when file later read |
| `strategies.supersede_writes.aggressive` | `false` | Prune any write if ANY subsequent read exists |
| `strategies.purge_errors.turns` | `5` | Turns before pruning errored tool inputs |

### Telemetry

```
{
  "telemetry": false
}
```

| Option | Default | Description |
| --- | --- | --- |
| `telemetry` | `true` | Enable anonymous daily-active telemetry. Set to `false` to disable it. |

___

## Reference

### Environment Variables

| Variable | Description |
| --- | --- |
| `OPENCODE_CONFIG_DIR` | Override OpenCode config directory (useful for profile isolation) |
| `OMO_SEND_ANONYMOUS_TELEMETRY` | Set to `0`, `false`, or `no` to disable anonymous telemetry |
| `OMO_DISABLE_POSTHOG` | Legacy telemetry opt-out flag. Set to `1`, `true`, or `yes` to disable PostHog |
| `OMO_CODEX_DISABLE_POSTHOG` | Set to `1` or `true` to disable PostHog telemetry for the `omo-codex` adapter only. Does not affect oh-my-opencode telemetry |
| `OMO_CODEX_SEND_ANONYMOUS_TELEMETRY` | Set to `0`, `false`, or `no` to disable anonymous telemetry for `omo-codex` only |
| `OMO_CODEX_GIT_BASH_PATH` | Native Windows Codex installs only. Absolute path to Git Bash, for example `C:\Program Files\Git\bin\bash.exe`, when `where bash` cannot find it |
| `LAZYCODEX_CONFIG_MIGRATION_DISABLED` | Set to `1` to skip the Codex config migration that runs on every session start (including the `multi_agent_v2` force-disable and managed reasoning-profile sync), leaving `config.toml` untouched |
| `OMO_CODEX_CONFIG_MIGRATION_DISABLED` | Alias of `LAZYCODEX_CONFIG_MIGRATION_DISABLED` |
| `LSP_TOOLS_MCP_INSTALL_DECISIONS` | Override the path of the LSP install-decisions file (default `~/.codex/lsp-install-decisions.json`) |
| `POSTHOG_API_KEY` | Optional override for the built-in PostHog project API key |
| `POSTHOG_HOST` | Override the PostHog ingestion host. Defaults to `https://us.i.posthog.com` |

### LSP Install Decisions

When an LSP tool hits a language server that is not installed, it asks once per server and persists the answer to `~/.codex/lsp-install-decisions.json` (override with `LSP_TOOLS_MCP_INSTALL_DECISIONS`). A `declined` entry collapses all future diagnostics for that server to a one-line note. To get prompted again — or to re-enable a server that an agent declined on your behalf — delete the file (or the server's entry in it).

### Codex Light Git Bash MCP

Native Windows Codex installs bundle a `git_bash` MCP server and write `[plugins."omo@sisyphuslabs".mcp_servers.git_bash] enabled = true`. Non-Windows installs keep the bundled manifest entry but write `enabled = false`, so the plugin detail can still show the server while policy prevents exposure.

The installer discovers Git Bash with `OMO_CODEX_GIT_BASH_PATH`, standard Git for Windows locations, and PATH. If discovery fails, it prints manual install guidance and stops without running `winget` or changing system dependencies. The Light plugin also emits a fixed reminder before the first Codex shell-like `Bash` hook call in a Windows session, and resets that reminder after `PostCompact` so the first post-compaction shell call recommends `git_bash` again.

### Codex Companion Plugin Compatibility

LazyCodex can coexist with other Codex plugins, but if LazyCodex is your primary Codex workflow the `codex@openai-codex` companion plugin adds its own `SessionStart` and `Stop` lifecycle hooks. Those extra hooks can produce confusing Codex hook-failure banners even when the LazyCodex hooks are healthy.

`lazycodex doctor` warns when `omo@sisyphuslabs` is enabled and the companion plugin is enabled, or when stale `[hooks.state."codex@openai-codex:..."]` SessionStart/Stop trust entries remain in `~/.codex/config.toml`. The doctor only reports this condition; it does not disable or delete another plugin for you.

If LazyCodex is the primary workflow, disable the companion plugin explicitly:

```
[plugins."codex@openai-codex"]
enabled = false
```

If doctor still warns afterward, remove the stale `[hooks.state."codex@openai-codex:..."]` SessionStart/Stop entries from the Codex config after making your own backup.

### Provider-Specific

#### Google Auth

Install [`opencode-antigravity-auth`](https://github.com/NoeFabris/opencode-antigravity-auth) for Google Gemini. Provides multi-account load balancing, dual quota, and variant-based thinking.

##### Split Claude Routing

Provider path affects the effective Claude context limit. Antigravity Claude models are the stable 200k lane. Direct Anthropic Claude models are the 1M lane for accounts and model IDs that support long context.

Use Antigravity for cheaper or quota-balanced work where 200k context is enough. Use direct Anthropic for long-context planning, review, and research sessions where early compaction would lose important context.

```
{
  "agents": {
    // 200k lane: Google Antigravity Claude.
    "explore": {
      "model": "google/antigravity-claude-sonnet-4-6"
    },
    "librarian": {
      "model": "google/antigravity-claude-sonnet-4-6"
    },

    // 1M lane: direct Anthropic, only for eligible long-context accounts/models.
    "sisyphus": {
      "model": "anthropic/claude-opus-5",
      "variant": "max"
    },
    "oracle": {
      "model": "anthropic/claude-opus-5"
    }
  }
}
```

If you see an error like `prompt is too long ... > 200000`, check whether the agent is routed through `google/antigravity-*`. Move that agent to a direct `anthropic/*` model only when the account, model, and required beta/header setup support 1M context. Keep the Antigravity lane explicit when you want predictable 200k behavior.

#### Ollama

**Must** disable streaming to avoid JSON parse errors:

```
{
  "agents": {
    "explore": { "model": "ollama/qwen3-coder" }
  }
}
```

**Note:** The `stream` option should be configured in your OpenCode settings or via environment variables, not in the agent config. See [Ollama Troubleshooting](https://omo.dev/troubleshooting/ollama.md) for details on disabling streaming.

Common models: `ollama/qwen3-coder`, `ollama/ministral-3:14b`, `ollama/lfm2.5-thinking`

See [Ollama Troubleshooting](https://omo.dev/troubleshooting/ollama.md) for `JSON Parse error: Unexpected EOF` issues.

## Oh-My-OpenAgent Features Reference

## Agents

Oh-My-OpenAgent provides 11 specialized AI agents. Each has distinct expertise, optimized models, and tool permissions.

### Current Agent Model Chains

The category chains below are edition-aware. Senpi uses `kimi-coding` for Kimi rungs. The OpenCode edition uses `kimi-for-coding` for the same Kimi chain positions. The same resolved chain is used at spawn time and again if runtime retry fallback needs to recover.

| Agent | Primary | Full fallback chain |
| --- | --- | --- |
| **sisyphus** | `claude-opus-5` | `anthropic|github-copilot|opencode|vercel/claude-opus-5 (max)` → `opencode-go|kimi-for-coding|moonshotai|opencode|vercel|bailian-coding-plan|moonshotai-cn|firmware|ollama-cloud|aihubmix/kimi-k3` → `openai|github-copilot|opencode|vercel/gpt-5.6-sol (medium)` → `zai-coding-plan|opencode|bailian-coding-plan|vercel/glm-5.2` → `opencode/big-pickle` |
| **hephaestus** | `gpt-5.6-sol` | `openai|github-copilot|vercel|opencode/gpt-5.6-sol (medium)` |
| **oracle** | `gpt-5.6-sol` | `openai|opencode|vercel/gpt-5.6-sol (xhigh)` → `github-copilot/gpt-5.6-sol (high)` → `google|github-copilot|opencode|vercel/gemini-3.1-pro (high)` → `anthropic|github-copilot|opencode|vercel/claude-opus-5 (max)` → `opencode-go|vercel/glm-5.2` |
| **librarian** | `gpt-5.6-luna-fast` | `openai/gpt-5.6-luna-fast` → `deepseek/deepseek-v4-flash (max)` → `opencode-go|bailian-coding-plan/qwen3.7-plus` → `vercel/minimax-m2.7-highspeed` → `opencode-go|vercel/minimax-m3` → `minimax-coding-plan|minimax-cn-coding-plan/MiniMax-M3` → `opencode-go|vercel/minimax-m2.7` → `anthropic|github-copilot|vercel/claude-haiku-4-5` → `openai|vercel/gpt-5.4-nano` |
| **explore** | `gpt-5.6-luna-fast` | `openai/gpt-5.6-luna-fast` → `deepseek/deepseek-v4-flash (max)` → `opencode-go|bailian-coding-plan/qwen3.7-plus` → `vercel/minimax-m2.7-highspeed` → `opencode-go|vercel/minimax-m3` → `minimax-coding-plan|minimax-cn-coding-plan/MiniMax-M3` → `opencode-go|vercel/minimax-m2.7` → `anthropic|github-copilot|vercel/claude-haiku-4-5` → `openai|vercel/gpt-5.4-nano` |
| **multimodal-looker** | `gpt-5.6-sol` | `openai|opencode|vercel/gpt-5.6-sol (low)` → `opencode-go|vercel/kimi-k3` → `zai-coding-plan|vercel/glm-4.6v` → `openai|github-copilot|opencode|vercel/gpt-5-nano` |
| **prometheus** | `claude-fable-5` | `anthropic|github-copilot|opencode|vercel/claude-fable-5 (xhigh)` → `opencode-go|kimi-for-coding|moonshotai|opencode|vercel/kimi-k3 (max)` |
| **metis** | `claude-opus-5` | `anthropic|github-copilot|opencode|vercel/claude-opus-5 (high)` → `opencode-go|kimi-for-coding|moonshotai|opencode|vercel/kimi-k3 (low)` |
| **momus** | `gpt-5.6-terra` | `openai|vercel/gpt-5.6-terra (high)` → `github-copilot/gpt-5.6-terra (high)` → `openai|opencode|vercel/gpt-5.6-sol (xhigh)` → `github-copilot/gpt-5.6-sol (high)` → `anthropic|github-copilot|opencode|vercel/claude-opus-5 (max)` → `google|github-copilot|opencode|vercel/gemini-3.1-pro (high)` → `opencode-go|vercel/glm-5.2` |
| **atlas** | `claude-sonnet-5` | `anthropic|github-copilot|opencode|vercel/claude-sonnet-5` → `opencode-go|vercel/kimi-k3` → `openai|github-copilot|opencode|vercel/gpt-5.6-sol (medium)` → `opencode-go|vercel/minimax-m3` → `minimax-coding-plan|minimax-cn-coding-plan/MiniMax-M3` → `opencode-go|vercel/minimax-m2.7` |
| **sisyphus-junior** | `claude-sonnet-5` | `anthropic|github-copilot|opencode|vercel/claude-sonnet-5` → `opencode-go|vercel/kimi-k3` → `openai|github-copilot|opencode|vercel/gpt-5.6-sol (medium)` → `opencode-go|vercel/minimax-m3` → `minimax-coding-plan|minimax-cn-coding-plan/MiniMax-M3` → `opencode-go|vercel/minimax-m2.7` → `opencode/big-pickle` |

### Invoking Agents

The main agent invokes these automatically, but you can call them explicitly:

```
Ask @oracle to review this design and propose an architecture
Ask @librarian how this is implemented - why does the behavior keep changing?
Ask @explore for the policy on this feature
```

### Tool Restrictions

| Agent | Restrictions |
| --- | --- |
| oracle | Read-only: cannot write, edit, or delegate (blocked: write, edit, task, call\_omo\_agent) |
| librarian | Cannot write, edit, or delegate (blocked: write, edit, task, call\_omo\_agent) |
| explore | Cannot write, edit, or delegate (blocked: write, edit, task, call\_omo\_agent) |
| multimodal-looker | Allowlist: `read` only |
| atlas | Cannot delegate (blocked: task, call\_omo\_agent) |
| momus | Cannot write, edit, or delegate (blocked: write, edit, task) |

### Instruction Files vs Enforcement

`AGENTS.md` files are instruction context. They tell agents how to work in a project, and OMO can inject that context into prompts, but they are not a deterministic permission boundary.

Deterministic enforcement today comes from OMO config (`agents.*.permission`, agent `tools`, disabled tools/agents), built-in agent restrictions, OpenCode's own permission gate when it is available, and guard hooks such as `team-tool-gating`, `write-existing-file-guard`, and `prometheus-md-only`.

OMO does not currently read an `AGENTOWNERS.yml` file or run a generic AGENTOWNERS policy-enforcer hook. If a project needs hard agent boundaries, encode them in config permissions, tool allowlists, repository protections, or review gates rather than relying on prose-only instructions.

### Background Agents

Run agents in the background and continue working:

-   Have GPT debug while Claude tries different approaches
-   Opus 5 handles visual work while GPT-5.6 Sol tackles deep reasoning
-   Fire massive parallel searches, continue implementation, use results when ready

```
# Launch in background
task(subagent_type="explore", load_skills=[], prompt="Find auth implementations", run_in_background=true)

# Continue working...
# System notifies on completion

# Retrieve results when needed
background_output(task_id="bg_abc123")
```

#### Background Agent Work Directories

Background agents inherit the session working directory from OpenCode and OMO when the task tool starts them. OMO does not force the model's own shell commands to stay inside that directory after launch. If a model decides to clone a repo, download docs, or create scratch files under `/tmp` or macOS `/var/folders/...`, the filesystem prompt comes from that command, not from a separate OMO storage root.

`APP_DIR` is an OpenCode process environment value. Treat it as process context, not as a guarantee that every background agent artifact will land there.

For projects that must keep all agent scratch work under the repository, add a project `AGENTS.md` rule with an explicit writable path:

```
Use ./.omo/session-work/ for clones, downloaded docs, scratch files, and
temporary outputs. Do not write under /tmp, /var, or other OS temp directories
unless the user approves it.
```

If you use tmux panes for background agents, each pane still follows the same model instructions. A project rule is more reliable than repeating the constraint in one prompt, because every subagent receives the rule with the project context.

#### Visual Multi-Agent with Tmux

Enable `tmux.enabled` to see background agents in separate tmux panes:

```
{
  "tmux": {
    "enabled": true,
    "layout": "main-vertical"
  }
}
```

When running inside tmux:

-   Background agents spawn in new panes
-   Watch multiple agents work in real-time
-   Each pane shows agent output live
-   Auto-cleanup when agents complete
-   **Stable agent ordering**: core-agent tab cycling defaults to Sisyphus, Hephaestus, Prometheus, Atlas, and can be customized with `agent_order`

When running inside cmux (`cmux omo`), the same pane integration is routed through cmux's tmux compatibility command. OMO detects the cmux environment from `CMUX_SOCKET_PATH` or a cmux-provided `TMUX` value, so `tmux.enabled` can create cmux panes even when a real `tmux` binary is not installed.

Customize agent models, prompts, and permissions in the `[opencode]` block of `~/.omo/omo.jsonc`.

### Team Mode (experimental, OFF by default)

Parallel multi-agent coordination modeled after Claude Code's experimental Agent Teams. Enable via `team_mode.enabled: true`. Exposes 12 `team_*` tools for spawning a lead + up to 8 members, a shared deferred-ack mailbox, a shared task list with file-locked claims, optional per-member git worktrees, and an optional tmux layout that streams each member's session output into dedicated panes.

See the **[Team Mode Guide](https://omo.dev/docs#team-mode)** for configuration, team spec format, lifecycle, bounds, and storage layout.

### Architecture Snapshot (current)

-   **Feature modules**: `packages/omo-opencode/src/features/` has 23 modules.
-   **Tool system**: `packages/omo-opencode/src/tools/` has 15 tool directories that produce **20 to 39 tools** depending on config gates.
-   **Hook system**: 5-tier composition is **54 base hooks**. With team mode it becomes **61** (extra tool guard + transforms + direct team session event handlers).
-   **MCP system**: 3 tiers: built-in remote MCPs (`websearch`, `context7`, `grep_app`), `.mcp.json` loader, and skill-embedded MCP from `SKILL.md` frontmatter.
-   **Managers**: plugin startup creates 4 managers: TmuxSessionManager, BackgroundManager, SkillMcpManager, ConfigHandler.
-   **Config pipeline**: 6 phases in order: provider, plugin-components, agents, tools, MCPs, commands.
-   **Canonical core agent order**: Sisyphus, Hephaestus, Prometheus, Atlas.
-   **OpenClaw**: bidirectional integrations for Discord, Telegram, HTTP, and shell with reply listener daemon.

## Category System

A Category is an agent configuration preset optimized for specific domains. Instead of delegating everything to a single AI agent, it is far more efficient to invoke specialists tailored to the nature of the task.

### What Categories Are and Why They Matter

-   **Category**: "What kind of work is this?" (determines model, temperature, prompt mindset)
-   **Skill**: "What tools and knowledge are needed?" (injects specialized knowledge, MCP tools, workflows)

By combining these two concepts, you can generate optimal agents through `task`.

### Built-in Categories

| Category | Default Model | Use Cases |
| --- | --- | --- |
| `visual-engineering` | `anthropic/claude-opus-5` (max) | Frontend, UI/UX, design, styling, animation |
| `ultrabrain` | `openai/gpt-5.6-sol` (xhigh) | Deep logical reasoning, complex architecture decisions requiring extensive analysis |
| `deep` | `openai/gpt-5.6-sol` (medium) | Goal-oriented autonomous problem-solving on hairy problems requiring deep research. ONE goal + ONE deliverable per call — multiple goals must fan out as parallel `deep` calls, never bundled into one. |
| `artistry` | `anthropic/claude-fable-5` (xhigh) | Highly creative/artistic tasks, novel ideas |
| `quick` | `kimi-for-coding/kimi-for-coding-highspeed` | Trivial tasks - single file changes, typo fixes, simple modifications |
| `unspecified-low` | `openai/gpt-5.6-luna` (xhigh) | Tasks that don't fit other categories, low effort required |
| `unspecified-high` | `kimi-for-coding/kimi-k3` (max) | Tasks that don't fit other categories, high effort required |
| `writing` | `kimi-for-coding/kimi-k3` (low) | Documentation, prose, technical writing |

### Usage

Specify the `category` parameter when invoking the `task` tool.

```
task({
  category: "visual-engineering",
  prompt: "Add a responsive chart component to the dashboard page",
});
```

### Custom Categories

You can define custom categories in the `[opencode]` block of the unified config file (`~/.omo/omo.jsonc` or a project `.omo/omo.jsonc`). Legacy `oh-my-openagent.json[c]` / `oh-my-opencode.json[c]` files are imported once by the migration engine and are no longer read at runtime.

#### Category Configuration Schema

| Field | Type | Description |
| --- | --- | --- |
| `description` | string | Human-readable description of the category's purpose. Shown in task prompt. |
| `model` | string | AI model ID to use (e.g., `anthropic/claude-opus-5`) |
| `fallback_models` | string|array | Fallback models on API errors. Supports strings or mixed arrays of strings and object entries with per-model settings |
| `variant` | string | Model variant (e.g., `max`, `xhigh`) |
| `temperature` | number | Creativity level (0.0 ~ 2.0). Lower is more deterministic. |
| `top_p` | number | Nucleus sampling parameter (0.0 ~ 1.0) |
| `prompt_append` | string | Content to append to system prompt when this category is selected |
| `thinking` | object | Thinking model configuration (`{ type: "enabled", budgetTokens: 16000 }`) |
| `reasoningEffort` | string | Reasoning effort level (`none`, `minimal`, `low`, `medium`, `high`, `xhigh`, `max`) |
| `textVerbosity` | string | Text verbosity level (`low`, `medium`, `high`) |
| `tools` | object | Tool usage control (disable with `{ "tool_name": false }`) |
| `maxTokens` | number | Maximum response token count |
| `max_prompt_tokens` | number | Maximum prompt tokens for delegated tasks |
| `is_unstable_agent` | boolean | Mark agent as unstable - forces background mode for monitoring |
| `disable` | boolean | Disable this category and exclude it from task delegation |

#### Example Configuration

```
{
  "categories": {
    // 1. Define new custom category
    "korean-writer": {
      "model": "google/gemini-3.6-flash",
      "temperature": 0.5,
      "prompt_append": "You are a Korean technical writer. Maintain a friendly and clear tone.",
    },

    // 2. Override existing category (change model)
    "visual-engineering": {
      "model": "openai/gpt-5.6-sol",
      "temperature": 0.8,
    },

    // 3. Configure thinking model and restrict tools
    "deep-reasoning": {
      "model": "anthropic/claude-opus-5",
      "thinking": {
        "type": "enabled",
        "budgetTokens": 32000,
      },
      "tools": {
        "websearch_web_search_exa": false,
      },
    },
  },
}
```

### Sisyphus-Junior as Delegated Executor

When you use a Category, a special agent called **Sisyphus-Junior** performs the work.

-   **Characteristic**: Cannot **re-delegate** tasks to other agents.
-   **Purpose**: Prevents infinite delegation loops and ensures focus on the assigned task.

## Advanced Configuration

### Rename Compatibility

The published package and binary remain `oh-my-opencode`. Inside `opencode.json`, the compatibility layer now prefers the plugin entry `oh-my-openagent`, while legacy `oh-my-opencode` entries still load with a warning. Plugin configuration lives in the unified `omo.jsonc`; legacy `oh-my-openagent.json[c]` / `oh-my-opencode.json[c]` config files are imported once by the migration engine and no longer read at runtime. Run `bunx oh-my-openagent doctor` to check for legacy package name warnings.

### Fallback Models

Configure per-agent fallback chains with arrays that can mix plain model strings and per-model objects:

```
{
  "agents": {
    "sisyphus": {
      "fallback_models": [
        "opencode/glm-5.2",
        { "model": "openai/gpt-5.6-sol", "variant": "high" },
        { "model": "anthropic/claude-sonnet-5", "thinking": { "type": "enabled", "budgetTokens": 64000 } }
      ]
    }
  }
}
```

When a model errors, the runtime can move through the configured fallback array. Object entries let you tune the backup model itself instead of only swapping the model name.

The plugin uses two independent fallback systems:

-   **model-fallback**: proactive model chain selection in chat params.
-   **runtime-fallback**: reactive recovery after runtime failures from provider/API behavior.

### File-Based Prompts

Load agent system prompts from external files using `file://` URLs in the `prompt` field, or append additional content with `prompt_append`. The `prompt_append` field also works on categories.

```
{
  "agents": {
    "sisyphus": {
      "prompt": "file:///path/to/custom-prompt.md"
    },
    "oracle": {
      "prompt_append": "file:///path/to/additional-context.md"
    }
  },
  "categories": {
    "deep": {
      "prompt_append": "file:///path/to/deep-category-append.md"
    }
  }
}
```

Supports `~` expansion for home directory and relative `file://` paths.

Useful for:

-   Version controlling prompts separately from config
-   Sharing prompts across projects
-   Keeping configuration files concise
-   Adding category-specific context without duplicating base prompts

The file content is loaded at runtime and injected into the agent's system prompt.

### Session Recovery

The system automatically recovers from common session failures without user intervention:

-   **Missing tool results**: reconstructs recoverable tool state and skips invalid tool-part IDs instead of failing the whole recovery pass
-   **Thinking block violations**: Recovers from API thinking block mismatches
-   **Empty messages**: Reconstructs message history when content is missing
-   **Context window limits**: Gracefully handles Claude context window exceeded errors with intelligent compaction
-   **JSON parse errors**: Recovers from malformed tool outputs

Recovery happens transparently during agent execution. You see the result, not the failure.

## Commands

Commands are slash-triggered workflows that execute predefined templates.

### Built-in Commands

| Command | Description |
| --- | --- |
| `/init-deep` | Initialize hierarchical AGENTS.md knowledge base |
| `/goal` | Set, show, pause, resume, or clear the active thread goal |
| `/refactor` | Intelligent refactoring with LSP, AST-grep, architecture analysis, and TDD verification |
| `/start-work` | Start Atlas work session from Prometheus plan |
| `/stop-continuation` | Stop all continuation mechanisms (todo continuation, Goal, boulder) for this session |
| `/handoff` | Create a detailed context summary for continuing work in a new session |

### /init-deep

**Purpose**: Generate hierarchical AGENTS.md files throughout your project

**Usage**:

```
/init-deep [--create-new] [--max-depth=N]
```

Creates directory-specific context files that agents automatically read:

```
project/
├── AGENTS.md                        # Project-wide context
├── packages/omo-opencode/src/
│   ├── AGENTS.md                    # src-specific context
│   └── components/
│       └── AGENTS.md                # Component-specific context
```

### /goal

**Purpose**: Set a persistent thread objective the agent pursues across turns until paused, cleared, or completed.

**Usage**:

```
/goal "Build a REST API with authentication"
/goal                    # show the current goal
/goal pause              # stop idle continuations
/goal resume             # resume a paused goal
/goal clear              # clear the current goal
```

**Behavior**:

-   The goal persists for the session and is shown in the TUI.
-   While a goal is active, every `session.idle` re-injects a continuation prompt that tracks `tokensUsed` and `timeUsedSeconds`.
-   The agent calls `update_goal({ status: "complete" })` only after a completion audit confirms the objective is achieved.
-   `pause` stops idle continuations without clearing the goal; `clear` removes it. `session.deleted` also clears the goal.
-   Goal state is stored in `.omo/goal/<sessionID>.json`.

**Tools** (registered only when `goal.enabled` is true):

-   `create_goal` - create or replace the active goal objective.
-   `update_goal` - pause, resume, mark complete, or change the objective.
-   `get_goal` - read the current objective, status, and usage accounting.

**Configure**:

```
{
  "goal": {
    "enabled": true,
    "auto_start": false,
    "default_max_iterations": 100
  }
}
```

-   `enabled` (default `false`) gates the Goal subsystem and its tools.
-   `auto_start` (default `false`) allows a goal to be auto-created from the first main-session message when `default_mode.goal` is true.
-   `default_max_iterations` (1-1000, default `100`) is the continuation iteration cap, preserved for Ralph Loop behavioral parity.

**Migration**: the legacy top-level `ralph_loop` config auto-migrates to `goal` at load time and logs a deprecation warning; explicit `goal` config wins over migrated values. `default_mode.ralph_loop` was renamed to `default_mode.goal`.

### /ulw-loop

The `/ulw-loop` slash command has been removed; continuous goal pursuit is now handled by `/goal`. The `omo ulw-loop` CLI subcommand remains as a passthrough to the Codex LazyCodex ulw-loop CLI.

### /refactor

**Purpose**: Intelligent refactoring with full toolchain

**Usage**:

```
/refactor <target> [--scope=<file|module|project>] [--strategy=<safe|aggressive>]
```

**Features**:

-   LSP-powered rename and navigation
-   AST-grep for pattern matching
-   Architecture analysis before changes
-   TDD verification after changes
-   Codemap generation

### /start-work

**Purpose**: Start execution from a Prometheus-generated plan

**Usage**:

```
/start-work [plan-name] [--worktree <path>] [--make-pr] [--ship]
```

Uses atlas agent to execute planned tasks systematically.

-   `--worktree <path>`: work inside a task-owned git worktree.
-   `--make-pr`: deliver the work as a pull request; implies worktree mode (a task-owned worktree is created when `--worktree` is omitted) and hands off with the PR URL.
-   `--ship`: implies `--make-pr`, then keeps working until the PR passes CI/review gates and is merged, before cleaning up the worktree.

### /stop-continuation

**Purpose**: Stop all continuation mechanisms for this session

Stops todo continuation, clears the active Goal, and clears boulder state. Use when you want the agent to stop its current multi-step workflow.

### /handoff

**Purpose**: Create a detailed context summary for continuing work in a new session

Generates a structured handoff document capturing the current state, what was done, what remains, and relevant file paths — enabling seamless continuation in a fresh session.

### Custom Commands

Load custom commands from:

-   `.opencode/command/*.md` (project, OpenCode native)
-   `~/.config/opencode/command/*.md` (user, OpenCode native)
-   `.claude/commands/*.md` (project, Claude Code compat)
-   `~/.config/opencode/commands/*.md` (user, Claude Code compat)

## Skill Sets

Skill sets provide specialized workflows with embedded MCP servers and detailed instructions. They are automatically activated by matching task intent, so you do not need to study or preload everything before working. When you want to force one deliberately, call it by name in the prompt, slash command, or `load_skills` list.

### Built-in Skill Sets

| Skill set | Trigger | Description |
| --- | --- | --- |
| **git-master** | commit, rebase, squash, "who wrote", "when was X added" | Git expert. Detects commit styles, splits atomic commits, formulates rebase strategies. Three specializations: Commit Architect (atomic commits, dependency ordering), Rebase Surgeon (history rewriting, conflict resolution), and History Archaeologist (finding when/where specific changes were introduced). |
| **playwright** | Browser tasks, testing, screenshots | Browser automation via Playwright MCP. MUST USE for browser verification, browsing, web scraping, testing, and screenshots. |
| **agent-browser** | Browser tasks on agent-browser | Browser automation via the `agent-browser` CLI. Covers navigation, snapshots, screenshots, network inspection, and scripted interactions. |
| **dev-browser** | Stateful browser scripting | Browser automation with persistent page state for iterative workflows and authenticated sessions. |
| **frontend** | UI/UX tasks, styling | Designer-turned-developer persona. Crafts strong UI/UX even without design mockups. Emphasizes bold aesthetic direction, distinctive typography, cohesive color palettes. |
| **review-work** | "review work", "review my work", "QA my work" | Post-implementation review orchestrator. Launches 5 parallel background sub-agents for comprehensive review: goal verification, code quality, security, hands-on QA, and context mining. All must pass for review to pass. |
| **ulw-research** | `ulw-research`, deep research requests | Maximum-saturation research. Runs parallel explore/librarian swarms across code, docs, web, and OSS repos; recursively follows `EXPAND` leads until convergence; proves contested claims by running code; and returns cited synthesis. Epistemic instrumentation covers intent-vs-reality diffing, claim graph, observation manifest, independent-observation convergence, temporal evidence, verification economics, and cause-disappearance records. |
| **$omo:remove-ai-slops** | "remove AI slop", "de-AI", "humanize" | Removes AI-generated code smells from files while preserving functionality. Identifies and eliminates verbose comments, redundant error handling, over-engineered patterns, and generic AI phrasing. |

`ulw-research` is intentionally explicit. Ordinary questions and normal implementation context-gathering will not trigger a saturation swarm. Use `ulw-research` when the research itself is the deliverable and every claim needs a citation, a proof artifact, or an execution-backed verdict.

#### git-master Core Principles

**Multiple Commits by Default**:

```
3+ files -> MUST be 2+ commits
5+ files -> MUST be 3+ commits
10+ files -> MUST be 5+ commits
```

**Automatic Style Detection**:

-   Analyzes last 30 commits for language (Korean/English) and style (semantic/plain/short)
-   Matches your repo's commit conventions automatically

**Usage**:

```
/git-master commit these changes
/git-master rebase onto main
/git-master who wrote this authentication code?
```

#### frontend Design Process

-   **Design Process**: Purpose, Tone, Constraints, Differentiation
-   **Aesthetic Direction**: Choose extreme - brutalist, maximalist, retro-futuristic, luxury, playful
-   **Typography**: Distinctive fonts, avoid generic (Inter, Roboto, Arial)
-   **Color**: Cohesive palettes with sharp accents, avoid purple-on-white AI slop
-   **Motion**: High-impact staggered reveals, scroll-triggering, surprising hover states
-   **Anti-Patterns**: Generic fonts, predictable layouts, cookie-cutter design

### Browser Automation Options

Oh-My-OpenAgent provides two browser automation providers, configurable via `browser_automation_engine.provider`.

#### Option 1: Playwright MCP (Default)

```
mcp:
  playwright:
    command: npx
    args: ["@playwright/mcp@latest"]
```

**Usage**:

```
/playwright Navigate to example.com and take a screenshot
```

#### Option 2: Agent Browser CLI (Vercel)

```
{
  "browser_automation_engine": {
    "provider": "agent-browser"
  }
}
```

**Requires installation**:

```
bun add -g agent-browser
```

**Usage**:

```
Use agent-browser to navigate to example.com and extract the main heading
```

**Capabilities (Both Providers)**:

-   Navigate and interact with web pages
-   Take screenshots and PDFs
-   Fill forms and click elements
-   Wait for network requests
-   Scrape content

### Custom Skill Creation (SKILL.md)

You can add custom skills directly to `.opencode/skills/` in your project root or `~/.claude/skills/` in your home directory.

**Example: `.opencode/skills/my-skill/SKILL.md`**

```
---
name: my-skill
description: My special custom skill
mcp:
  my-mcp:
    command: npx
    args: ["-y", "my-mcp-server"]
---

# My Skill Prompt

This content will be injected into the agent's system prompt.
...
```

**Skill Load Locations** (priority order, highest first):

-   `.opencode/skills/*/SKILL.md` (project, OpenCode native)
-   `~/.config/opencode/skills/*/SKILL.md` (user, OpenCode native)
-   `.claude/skills/*/SKILL.md` (project, Claude Code compat)
-   `.agents/skills/*/SKILL.md` (project, Agents convention)
-   `~/.agents/skills/*/SKILL.md` (user, Agents convention)

Same-named skill at higher priority overrides lower.

Loaded skill display priority follows this order: `project > user > opencode > builtin/plugin`.

Disable built-in skills via `disabled_skills: ["playwright"]` in config.

### Category + Skill Combo Strategies

You can create powerful specialized agents by combining Categories and Skills.

#### The Designer (UI Implementation)

-   **Category**: `visual-engineering`
-   **load\_skills**: `["frontend", "playwright"]`
-   **Effect**: Implements aesthetic UI and verifies rendering results directly in browser.

#### The Architect (Design Review)

-   **Category**: `ultrabrain`
-   **load\_skills**: `[]` (pure reasoning)
-   **Effect**: Uses GPT-5.6 Sol at xhigh effort through OpenAI or Vercel when available, at high effort through GitHub Copilot, and retains an xhigh Sol rung through OpenAI, OpenCode, or Vercel before non-GPT fallbacks.

#### The Maintainer (Quick Fixes)

-   **Category**: `quick`
-   **load\_skills**: `["git-master"]`
-   **Effect**: Uses cost-effective models to quickly fix code and generate clean commits.

### task Prompt Guide

When delegating, **clear and specific** prompts are essential. Include these 7 elements:

1.  **TASK**: What needs to be done? (single objective)
2.  **EXPECTED OUTCOME**: What is the deliverable?
3.  **REQUIRED SKILLS**: Which skills should be loaded via `load_skills`?
4.  **REQUIRED TOOLS**: Which tools must be used? (whitelist)
5.  **MUST DO**: What must be done (constraints)
6.  **MUST NOT DO**: What must never be done
7.  **CONTEXT**: File paths, existing patterns, reference materials

**Bad Example**:

> "Fix this"

**Good Example**:

> **TASK**: Fix mobile layout breaking issue in the navbar component **CONTEXT**: `packages/web/components/Navbar.tsx`, using Tailwind CSS **MUST DO**: Change flex-direction at `md:` breakpoint **MUST NOT DO**: Modify existing desktop layout **EXPECTED**: Buttons align vertically on mobile

## Tools

Tool registration is config-gated. `packages/omo-opencode/src/tools/` has 15 directories, and exposed tools range from **20 minimum to 39 maximum**.

### Code Search Tools

| Tool | Description |
| --- | --- |
| **grep** | Content search using regular expressions. Filter by file pattern. |
| **glob** | Fast file pattern matching. Find files by name patterns. |

### Edit Tools

| Tool | Description |
| --- | --- |
| **edit** | Hash-anchored edit tool. Uses `LINE#ID` format for precise, safe modifications. Validates content hashes before applying changes and rejects stale hash edits. |

Hashline IDs use characters from `ZPMQVRWSNKTXJBYH`.

### LSP Tools (IDE Features for Agents)

| Tool | Description |
| --- | --- |
| **lsp\_diagnostics** | Get errors/warnings before build |
| **lsp\_prepare\_rename** | Validate rename operation |
| **lsp\_rename** | Rename symbol across workspace |
| **lsp\_goto\_definition** | Jump to symbol definition |
| **lsp\_find\_references** | Find all usages across workspace |
| **lsp\_symbols** | Get file outline or workspace symbol search |

### AST-Grep Skill

AST-aware search and rewrite now lives in the `ast-grep` skill. Load it with the `skill` tool when you need structural matching, then use its `sg` helper commands for search or rewrite workflows.

### Delegation Tools

| Tool | Description |
| --- | --- |
| **call\_omo\_agent** | Spawn explore/librarian agents. Supports `run_in_background`. |
| **task** | Category-based task delegation. Supports built-in categories like `visual-engineering`, `ultrabrain`, `deep`, `artistry`, `quick`, `unspecified-low`, `unspecified-high`, and `writing`, or direct agent targeting via `subagent_type`. |
| **background\_output** | Retrieve background task results |
| **background\_cancel** | Cancel running background tasks |

### Visual Analysis Tools

| Tool | Description |
| --- | --- |
| **look\_at** | Analyze media files (PDFs, images, diagrams) via Multimodal-Looker agent. Extracts specific information or summaries from documents, describes visual content. |

### Skill Tools

| Tool | Description |
| --- | --- |
| **skill** | Load and execute a skill or slash command by name. Returns detailed instructions with context applied. |
| **skill\_mcp** | Invoke MCP server operations from skill-embedded MCPs. |

### Session Tools

| Tool | Description |
| --- | --- |
| **session\_list** | List all OpenCode sessions |
| **session\_read** | Read messages and history from a session |
| **session\_search** | Full-text search across session messages |
| **session\_info** | Get session metadata and statistics |

#### Finding older sessions hidden by `/sessions`

OpenCode's built-in `/sessions` picker can omit older sessions even when they still exist in the local session store. Use OMO's session tools to find the ID, then continue it from the TUI.

```
session_list({
  from_date: "2026-01-01T00:00:00Z",
  to_date: "2026-02-11T00:00:00Z",
  project_path: "/absolute/path/to/project",
  limit: 50,
})
```

After you find the session ID, type this in OpenCode:

```
/continue <session_id>
```

If you remember text from the conversation but not the date, search first and then read the matching session:

```
session_search({ query: "migration bug", limit: 20 })
session_read({ session_id: "ses_...", limit: 200 })
```

### Task Management Tools

Requires `experimental.task_system: true` in config.

| Tool | Description |
| --- | --- |
| **task\_create** | Create a new task with auto-generated ID |
| **task\_get** | Retrieve a task by ID |
| **task\_list** | List all active tasks |
| **task\_update** | Update an existing task |

#### Task System Details

**Note on Claude Code Alignment**: This implementation follows Claude Code's internal Task tool signatures (`TaskCreate`, `TaskUpdate`, `TaskList`, `TaskGet`) and field naming conventions (`subject`, `blockedBy`, `blocks`, etc.). However, Anthropic has not published official documentation for these tools. This is Oh My OpenAgent's own implementation based on observed Claude Code behavior and internal specifications.

**Task Schema**:

```
interface Task {
  id: string; // T-{uuid}
  subject: string; // Imperative: "Run tests"
  description: string;
  status: "pending" | "in_progress" | "completed" | "deleted";
  activeForm?: string; // Present continuous: "Running tests"
  blocks: string[]; // Tasks this blocks
  blockedBy: string[]; // Tasks blocking this
  owner?: string; // Agent name
  metadata?: Record<string, unknown>;
  threadID: string; // Session ID (auto-set)
}
```

**Dependencies and Parallel Execution**:

```
[Build Frontend]    ──┐
                      ├──→ [Integration Tests] ──→ [Deploy]
[Build Backend]     ──┘
```

-   Tasks with empty `blockedBy` run in parallel
-   Dependent tasks wait until blockers complete

**Example Workflow**:

```
TaskCreate({ subject: "Build frontend" }); // T-001
TaskCreate({ subject: "Build backend" }); // T-002
TaskCreate({ subject: "Run integration tests", blockedBy: ["T-001", "T-002"] }); // T-003

TaskList();
// T-001 [pending] Build frontend        blockedBy: []
// T-002 [pending] Build backend         blockedBy: []
// T-003 [pending] Integration tests     blockedBy: [T-001, T-002]

TaskUpdate({ id: "T-001", status: "completed" });
TaskUpdate({ id: "T-002", status: "completed" });
// T-003 now unblocked
```

**Storage**: Tasks are stored as JSON files in `.omo/tasks/`.

**Difference from TodoWrite**:

| Feature | TodoWrite | Task System |
| --- | --- | --- |
| Storage | Session memory | File system |
| Persistence | Lost on close | Survives restart |
| Dependencies | None | Full support (`blockedBy`) |
| Parallel execution | Manual | Automatic optimization |

**When to Use**: Use Tasks when work has multiple steps with dependencies, multiple subagents will collaborate, or progress should persist across sessions.

### Interactive Terminal Tools

| Tool | Description |
| --- | --- |
| **interactive\_bash** | Tmux-based terminal for TUI apps (vim, htop, pudb). Pass tmux subcommands directly without prefix. |

**Usage Examples**:

```
# Create a new session
interactive_bash(tmux_command="new-session -d -s dev-app")

# Send keystrokes to a session
interactive_bash(tmux_command="send-keys -t dev-app 'vim main.py' Enter")

# Capture pane output
interactive_bash(tmux_command="capture-pane -p -t dev-app")
```

**Key Points**:

-   Commands are tmux subcommands (no `tmux` prefix)
-   Use for interactive apps that need persistent sessions
-   One-shot commands should use regular `Bash` tool with `&`

## Hooks

Hooks intercept and modify behavior at key points in the agent lifecycle across the full session, message, tool, and parameter pipeline.

Current composition counts:

-   Session: 24
-   Tool Guard: 16
-   Transform: 5
-   Continuation: 7
-   Skill: 2
-   Total base: 54
-   With `team_mode.enabled`: +1 Tool Guard, +2 Transform, +4 direct team session event handlers in `packages/omo-opencode/src/plugin/event.ts` = 61

### Hook Events

| Event | When | Can |
| --- | --- | --- |
| **PreToolUse** | Before tool execution | Block, modify input, inject context |
| **PostToolUse** | After tool execution | Add warnings, modify output, inject messages |
| **Message** | During message processing | Transform content, detect keywords, activate modes |
| **Event** | On session lifecycle changes | Recovery, fallback, notifications |
| **Transform** | During context transformation | Inject context, validate blocks |
| **Params** | When setting API parameters | Adjust model settings, effort level |

### Built-in Hooks

#### Context & Injection

| Hook | Event | Description |
| --- | --- | --- |
| **directory-agents-injector** | PreToolUse + PostToolUse | Auto-injects AGENTS.md when reading files. Walks from file to project root, collecting all AGENTS.md files. Deprecated for OpenCode 1.1.37+ — Auto-disabled when native AGENTS.md injection is available. |
| **directory-readme-injector** | PreToolUse + PostToolUse | Auto-injects README.md for directory context. |
| **rules-injector** | PreToolUse + PostToolUse | Injects rules from `.claude/rules/` when conditions match. Supports globs and alwaysApply. |
| **compaction-context-injector** | Event | Preserves critical context during session compaction. |
| **preemptive-compaction** | Event | Proactively compacts sessions before hitting token limits. |

#### Productivity & Control

| Hook | Event | Description |
| --- | --- | --- |
| **keyword-detector** | Message + Transform | IntentGate detector. Activates `ultrawork`/`ulw`, `search`, `analyze`, and `team` modes from message keywords. |
| **think-mode** | Params | Auto-detects extended thinking needs. Catches "think deeply", "ultrathink" and adjusts model settings. |
| **goal** | Event | Re-injects a goal continuation prompt on session.idle while a goal is active; clears the goal on session.deleted. |
| **start-work** | Message | Handles /start-work command execution. |
| **auto-slash-command** | Message | Automatically executes slash commands from prompts. |
| **stop-continuation-guard** | Event + Message | Guards the stop-continuation mechanism. |
| **category-skill-reminder** | Event + PostToolUse | Reminds agents about available category skills for delegation. |

#### Quality & Safety

| Hook | Event | Description |
| --- | --- | --- |
| **comment-checker** | PostToolUse | Runs `@code-yeongyu/comment-checker` to block AI-slop comment patterns. Bypass options: `// @allow` for a line, `// comment-checker-disable-file` at file top. |
| **thinking-block-validator** | Transform | Validates thinking blocks to prevent API errors. |
| **edit-error-recovery** | PostToolUse + Event | Recovers from edit tool failures. |
| **write-existing-file-guard** | PreToolUse | Prevents accidental overwrites of existing files without reading them first. |
| **hashline-read-enhancer** | PostToolUse | Enhances read output with hash-anchored line markers for the hashline edit tool. |

#### Recovery & Stability

| Hook | Event | Description |
| --- | --- | --- |
| **anthropic-context-window-limit-recovery** | Event | Handles Claude context window limits gracefully. |
| **runtime-fallback** | Event + Message | Automatically switches to backup models on retryable API errors (e.g., 429, 500, 502, 503, 504), provider key misconfiguration errors (e.g., missing API key), and provider retry signals. `message.updated` retry-signal detection requires `timeout_seconds > 0`; structured `session.status` retry events can still trigger fallback. |
| **model-fallback** | Event + Message | Manages model fallback chain when primary model is unavailable. |
| **json-error-recovery** | PostToolUse | Recovers from JSON parse errors in tool outputs. |

#### Truncation & Context Management

| Hook | Event | Description |
| --- | --- | --- |
| **tool-output-truncator** | PostToolUse | Truncates output from Grep, Glob, LSP, AST-grep tools. Dynamically adjusts based on context window. |

#### Notifications & UX

| Hook | Event | Description |
| --- | --- | --- |
| **auto-update-checker** | Event | Checks for new versions on session creation, shows startup toast with version and Sisyphus status. |
| **background-notification** | Event | Notifies when background agent tasks complete. |
| **session-notification** | Event | OS notifications when agents go idle. Works on macOS, Linux, Windows. |
| **agent-usage-reminder** | PostToolUse + Event | Reminds you to leverage specialized agents for better results. |
| **question-label-truncator** | PreToolUse | Truncates long question labels in the Question tool UI. |

#### Task Management

| Hook | Event | Description |
| --- | --- | --- |
| **task-resume-info** | PostToolUse | Provides task resume information for continuity. |
| **delegate-task-retry** | PostToolUse + Event | Retries failed task delegation calls. |
| **empty-task-response-detector** | PostToolUse | Detects empty responses from delegated tasks. |
| **tasks-todowrite-disabler** | PreToolUse | Disables TodoWrite tool when task system is active. |

#### Continuation

| Hook | Event | Description |
| --- | --- | --- |
| **todo-continuation-enforcer** | Event | Enforces todo completion — yanks idle agents back to work. |
| **compaction-todo-preserver** | Event | Preserves todo state during session compaction. |
| **unstable-agent-babysitter** | Event | Handles unstable agent behavior with recovery strategies. |

#### Integration

| Hook | Event | Description |
| --- | --- | --- |
| **claude-code-hooks** | All | Executes hooks from Claude Code's settings.json. |
| **atlas** | Multiple | Main orchestration logic for todo-driven work sessions. |
| **interactive-bash-session** | PostToolUse + Event | Manages tmux sessions for interactive CLI. |
| **non-interactive-env** | PreToolUse | Handles non-interactive environment constraints. |

#### Specialized

| Hook | Event | Description |
| --- | --- | --- |
| **prometheus-md-only** | PreToolUse | Enforces markdown-only output for Prometheus planner. |
| **no-sisyphus-gpt** | Message | Prevents Sisyphus from running on incompatible GPT models. |
| **no-hephaestus-non-gpt** | Message | Prevents Hephaestus from running on non-GPT models. |
| **sisyphus-junior-notepad** | PreToolUse | Manages notepad state for Sisyphus-Junior agents. |

### Claude Code Hooks Integration

Run custom scripts via Claude Code's `settings.json`:

```
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [{ "type": "command", "command": "eslint --fix $FILE" }]
      }
    ]
  }
}
```

**Hook locations**:

-   `~/.claude/settings.json` (user)
-   `./.claude/settings.json` (project)
-   `./.claude/settings.local.json` (local, git-ignored)

### Disabling Hooks

Disable specific hooks in config:

```
{
  "disabled_hooks": ["comment-checker"]
}
```

## MCPs

The plugin uses a three-tier MCP architecture:

1.  Built-in MCPs from `packages/omo-opencode/src/mcp/` (remote plus local stdio)
2.  Claude Code `.mcp.json` loader with `${VAR}` expansion
3.  Skill-embedded MCP servers declared in `SKILL.md` frontmatter

### Native vs plugin-injected MCPs

oh-my-openagent injects MCP servers at **runtime** through the OpenCode plugin API. This is fundamentally different from MCP servers you configure directly in `opencode.json`.

Because `opencode mcp list` reads OpenCode's static configuration only, it **cannot see** MCPs that the plugin injects at runtime. This is expected behavior, not a bug:

```
# These are plugin-injected — they will NOT appear here
$ opencode mcp list
No MCP servers configured
```

To inspect which MCP servers oh-my-openagent is actually providing, run the doctor command:

```
bunx oh-my-openagent doctor --verbose
```

The three tiers of MCP servers and where they come from:

| Tier | Source | Visible in `opencode mcp list`? |
| --- | --- | --- |
| 1 — Built-in | Injected at runtime by oh-my-openagent (`websearch`, `context7`, `grep_app`) | No |
| 2 — Claude Code `.mcp.json` | Loaded from `.mcp.json` files and merged in by oh-my-openagent at runtime | No |
| 3 — Skill-embedded | Declared in `SKILL.md` frontmatter, spun up on demand per session | No |
| — Native OpenCode | Configured directly in `opencode.json` under the `mcp` key, without the plugin | Yes |

**Disabling built-in MCPs**: Use `disabled_mcps` in your plugin config:

```
{
  "disabled_mcps": ["websearch", "grep_app"]
}
```

### Built-in MCPs

| MCP | Description |
| --- | --- |
| **websearch** | Real-time web search powered by Exa AI |
| **context7** | Official documentation lookup for any library/framework |
| **grep\_app** | Ultra-fast code search across public GitHub repos. Great for finding implementation examples. |
| **lsp** | Local LSP tools for diagnostics, symbols, references, and renames |

### Skill-Embedded MCPs

Skills can bring their own MCP servers:

```
---
description: Browser automation skill
mcp:
  playwright:
    command: npx
    args: ["-y", "@anthropic-ai/mcp-playwright"]
---
```

The `skill_mcp` tool invokes these operations with full schema discovery.

Skill MCP clients are isolated per session by key `${sessionID}:${skillName}:${serverName}`.

#### OAuth-Enabled MCPs

Skills can define OAuth-protected remote MCP servers. OAuth 2.1 with full RFC compliance (RFC 9728, 8414, 8707, 7591) is supported:

```
---
description: My API skill
mcp:
  my-api:
    url: https://api.example.com/mcp
    oauth:
      clientId: ${CLIENT_ID}
      scopes: ["read", "write"]
---
```

When a skill MCP has `oauth` configured:

-   **Auto-discovery**: Fetches `/.well-known/oauth-protected-resource` (RFC 9728), falls back to `/.well-known/oauth-authorization-server` (RFC 8414)
-   **Dynamic Client Registration**: Auto-registers with servers supporting RFC 7591 (clientId becomes optional)
-   **PKCE**: Mandatory for all flows
-   **Resource Indicators**: Auto-generated from MCP URL per RFC 8707
-   **Token Storage**: Persisted in `~/.config/opencode/mcp-oauth.json` (chmod 0600)
-   **Auto-refresh**: Tokens refresh on 401; step-up authorization on 403 with `WWW-Authenticate`
-   **Dynamic Port**: OAuth callback server uses an auto-discovered available port

Pre-authenticate via CLI:

```
bunx oh-my-openagent mcp oauth login <server-name> --server-url https://api.example.com
```

## Model Capabilities

Model capabilities are models.dev-backed, with a refreshable cache and compatibility diagnostics. The system combines bundled models.dev snapshot data, optional refreshed cache data, provider runtime metadata, and heuristics when exact metadata is unavailable.

### Refreshing Capabilities

Update the local cache with the latest model information:

```
bunx oh-my-openagent refresh-model-capabilities
```

Configure automatic refresh at startup:

```
{
  "model_capabilities": {
    "enabled": true,
    "auto_refresh_on_start": true,
    "refresh_timeout_ms": 5000,
    "source_url": "https://models.dev/api.json"
  }
}
```

### Capability Diagnostics

Run `bunx oh-my-openagent doctor` to see capability diagnostics including:

-   effective model resolution for agents and categories
-   warnings when configured models rely on compatibility fallback
-   override compatibility details alongside model resolution output

## Context Injection

### Directory AGENTS.md

Auto-injects AGENTS.md when reading files. Walks from file directory to project root:

```
project/
├── AGENTS.md                        # Injected first
├── packages/omo-opencode/src/
│   ├── AGENTS.md                    # Injected second
│   └── components/
│       ├── AGENTS.md                # Injected third
│       └── Button.tsx               # Reading this injects all 3
```

### Conditional Rules

Inject rules from `.claude/rules/` when conditions match:

```
---
globs: ["*.ts", "src/**/*.js"]
description: "TypeScript/JavaScript coding rules"
---

- Use PascalCase for interface names
- Use camelCase for function names
```

Supports:

-   `.md` and `.mdc` files
-   `globs` field for pattern matching
-   `alwaysApply: true` for unconditional rules
-   Walks upward from file to project root, plus `~/.claude/rules/`

## Claude Code Compatibility

Full compatibility layer for Claude Code configurations.

### Config Loaders

| Type | Locations |
| --- | --- |
| **Commands** | `~/.config/opencode/commands/`, `.claude/commands/` |
| **Skills** | `~/.config/opencode/skills/*/SKILL.md`, `.claude/skills/*/SKILL.md` |
| **Agents** | `~/.config/opencode/agents/*.md`, `.claude/agents/*.md` |
| **MCPs** | `~/.claude.json`, `~/.config/opencode/.mcp.json`, `.mcp.json`, `.claude/.mcp.json` |

MCP configs support environment variable expansion: `${VAR}`.

### Compatibility Toggles

Disable specific features:

```
{
  "claude_code": {
    "mcp": false,
    "commands": false,
    "skills": false,
    "agents": false,
    "hooks": false,
    "plugins": false
  }
}
```

| Toggle | Disables |
| --- | --- |
| `mcp` | `.mcp.json` files (keeps built-in MCPs) |
| `commands` | Command loading from Claude Code paths |
| `skills` | Skill loading from Claude Code paths |
| `agents` | Agent loading from Claude Code paths (keeps built-in agents) |
| `hooks` | settings.json hooks |
| `plugins` | Claude Code marketplace plugins |

Disable specific plugins:

```
{
  "claude_code": {
    "plugins_override": {
      "claude-mem@thedotmack": false
    }
  }
}
```

## Manifesto

The principles and philosophy behind oh-my-openagent (OmO).

Project reality check:

-   Name: oh-my-openagent (renamed from oh-my-opencode; both npm packages still publish in tandem during the transition)
-   Domain: [https://omo.dev](https://omo.dev/) (legacy [https://ohmyopenagent.com](https://ohmyopenagent.com/), [https://ohmyopencode.org](https://ohmyopencode.org/), [https://ulw.dev](https://ulw.dev/), [https://ultrawork.ai](https://ultrawork.ai/), [https://ultrawork.dev](https://ultrawork.dev/), [https://ultrawork.engineer](https://ultrawork.engineer/) all 301 to omo.dev)
-   Building in Public: [https://discord.gg/PUwSMR9XNk](https://discord.gg/PUwSMR9XNk)
-   Maintained by Jobdori, an AI assistant running on a heavily customized OpenClaw fork
-   Sisyphus Labs: [https://sisyphuslabs.ai](https://sisyphuslabs.ai/)

___

## Human Intervention is a Failure Signal

**HUMAN IN THE LOOP = BOTTLENECK**

Think about autonomous driving. When a human has to take over the wheel, that's not a feature. It's a failure of the system. The car couldn't handle the situation on its own.

**Why is coding any different?**

When you find yourself:

-   Fixing the AI's half-finished code
-   Manually correcting obvious mistakes
-   Guiding the agent step-by-step through a task
-   Repeatedly clarifying the same requirements

That's not "human-AI collaboration." That's the AI failing to do its job.

**Oh My OpenAgent is built on this premise**: Human intervention during agentic work is fundamentally a wrong signal. If the system is designed correctly, the agent should complete the work without requiring you to babysit it.

___

## Indistinguishable Code

**Goal: Code written by the agent should be indistinguishable from code written by a senior engineer.**

Not "AI-generated code that needs cleanup." Not "a good starting point." The actual, final, production-ready code.

This means:

-   Following existing codebase patterns exactly
-   Proper error handling without being asked
-   Tests that actually test the right things
-   No AI slop (over-engineering, unnecessary abstractions, scope creep)
-   Comments only when they add value

If you can tell whether a commit was made by a human or an agent, the agent has failed.

___

## Token Cost vs Productivity

**Higher token usage is acceptable if it significantly increases productivity.**

Using more tokens to:

-   Have multiple specialized agents research in parallel
-   Get the job done completely without human intervention
-   Verify work thoroughly before completion
-   Accumulate knowledge across tasks

That's a worthwhile investment when it means 10x, 20x, or 100x productivity gains.

**However:**

Unnecessary token waste is not pursued. The system optimizes for:

-   Using cheaper models (Haiku, Flash) for simple tasks
-   Avoiding redundant exploration
-   Caching learnings across sessions
-   Stopping research when sufficient context is gathered

Token efficiency matters. But not at the cost of work quality or human cognitive load.

___

## Minimize Human Cognitive Load

**The human should only need to say what they want. Everything else is the agent's job.**

Two approaches achieve this:

### Approach 1: Prometheus (Interview Mode)

You say: "I want to add authentication."

Prometheus:

-   Researches your codebase to understand existing patterns
-   Asks clarifying questions based on actual findings
-   Surfaces edge cases you hadn't considered
-   Documents decisions as you make them
-   Generates a complete work plan

**You provide intent. The agent provides structure.**

### Approach 2: Ultrawork (Just Do It Mode)

You say: "ulw add authentication"

The agent:

-   Figures out the right approach
-   Researches best practices
-   Implements following conventions
-   Verifies everything works
-   Keeps going until complete

**You provide intent. The agent handles everything.**

In both cases, the human's job is to **express what they want**, not to manage how it gets done.

___

## Predictable, Continuous, Delegatable

**The ideal agent should work like a compiler**: markdown document goes in, working code comes out.

### Predictable

Given the same inputs:

-   Same codebase patterns
-   Same requirements
-   Same constraints

The output should be consistent. Not random, not surprising, not "creative" in ways you didn't ask for.

### Continuous

Work should survive interruptions:

-   Session crashes? Resume with `/start-work`
-   Need to step away? Progress is tracked
-   Multi-day project? Context is preserved

The agent maintains state. You don't have to.

### Delegatable

Just like you can assign a task to a capable team member and trust them to handle it, you should be able to delegate to the agent.

This means:

-   Clear acceptance criteria, verified independently
-   Self-correcting behavior when something goes wrong
-   Escalation (to Oracle, to user) only when truly needed
-   Complete work, not "mostly done"

___

## The Core Loop

```
Human Intent → Agent Execution → Verified Result
       ↑                              ↓
       └──────── Minimum ─────────────┘
          (intervention only on true failure)
```

Everything in Oh My OpenAgent is designed to make this loop work:

| Feature | Purpose |
| --- | --- |
| Prometheus | Extract intent through intelligent interview |
| Metis | Catch ambiguities before they become bugs |
| Momus | Verify plans are complete before execution |
| Orchestrator | Coordinate work without human micromanagement |
| Todo Continuation | Force completion, prevent "I'm done" lies |
| Category System | Route to optimal model without human decision |
| Background Agents | Parallel research without blocking user |
| Wisdom Accumulation | Learn from work, don't repeat mistakes |

___

## What This Means in Practice

**You should be able to:**

1.  Describe what you want (high-level or detailed, your choice)
2.  Let the agent interview you if needed
3.  Confirm the plan (or just let ultrawork handle it)
4.  Walk away
5.  Come back to completed, verified, production-ready work

**If you can't do this, something in the system needs to improve.**

___

## The Future We're Building

A world where:

-   Human developers focus on **what** to build, not **how** to get AI to build it
-   Code quality is independent of who (or what) wrote it
-   Complex projects are as easy as simple ones (just take longer)
-   "Prompt engineering" becomes as obsolete as "compiler debugging"

**The agent should be invisible.** Not in the sense that it's hidden, but in the sense that it just works. Like electricity, like running water, like the internet.

You flip the switch. The light turns on. You don't think about the power grid.

That's the goal.

___

## Further Reading

-   [Overview](https://omo.dev/docs#overview)
-   [Orchestration Guide](https://omo.dev/docs#orchestration)
