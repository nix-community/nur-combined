# Model Matrix Implementation Notes

This document translates the capability-focused recommendations in [`recommended-model-matrix.md`](./recommended-model-matrix.md) into the currently deployed routing configuration.

## Routing Rule

Use a direct model ID when only one provider exposes the required model and no stable routing abstraction is needed. Use an OmniRoute combo when multiple eligible providers or subscription connections exist, or when a stable family-level indirection is explicitly required.

## Claude Combo Policy

All Claude mappings use dedicated OmniRoute combos so model generations and subscription targets can change without rewriting agent/category mappings.

| Model tier    | OmniRoute combo                 | Deployed targets, in order                                   | Strategy     |
| ------------- | ------------------------------- | ------------------------------------------------------------ | ------------ |
| Claude Opus   | `omniroute/combo/claude-opus`   | `claude/claude-opus-5`                                       | `fill-first` |
| Claude Fable  | `omniroute/combo/claude-fable`  | `claude/claude-fable-5` → `kilocode/claude-fable-5`          | `fill-first` |
| Claude Sonnet | `omniroute/combo/claude-sonnet` | `claude/claude-sonnet-5`                                     | `fill-first` |
| Claude Haiku  | `omniroute/combo/claude-haiku`  | `claude/claude-haiku-4-5-20251001` → `kiro/claude-haiku-4.5` | `fill-first` |

Claude Opus and Sonnet route exclusively to their current Claude subscription targets. Claude Fable and Haiku retain their independently verified family fallbacks. An expired Claude connection was deliberately removed from these combos. When a newer Claude generation becomes available, update the combo target and leave agent/category mappings unchanged.

## GLM Combo Policy

GLM mappings use dedicated OmniRoute combos to keep the agent/category configuration stable while provider eligibility and family versions change.

| Model tier | OmniRoute combo           | Deployed targets, in order   | Strategy   |
| ---------- | ------------------------- | ---------------------------- | ---------- |
| GLM-5.2    | `omniroute/combo/glm-5.2` | `kiro/glm-5` → `zai/glm-5.2` | `priority` |

The GLM-5 combo intentionally treats GLM-5, GLM-5.1, and GLM-5.2 as one routing family, with the healthy Kiro allowance before the paid Z.AI Coding Plan. GLM-4.7 and GLM-4.7 Flash remain distinct. KiloCode's GLM-5.1, GLM-5 Turbo, and GLM-4.7 Flash endpoints were excluded after live probes returned unusable empty responses. Hugging Face's advertised GLM-5.2 endpoints were also excluded because live requests reported that the models did not exist.

## Direct Model Policy

The Codex tiers, Gemini 3.1 Pro, and GLM-4.7 Flash currently use direct IDs because the required variants resolve through one eligible provider each:

| Model tier     | Direct configuration ID         |
| -------------- | ------------------------------- |
| GPT-5.6 Sol    | `omniroute/codex/gpt-5.6-sol`   |
| GPT-5.6 Terra  | `omniroute/codex/gpt-5.6-terra` |
| GPT-5.6 Luna   | `omniroute/codex/gpt-5.6-luna`  |
| GPT-5.5        | `omniroute/codex/gpt-5.5`       |
| Gemini 3.1 Pro | `omniroute/agy/gemini-3.1-pro`  |
| GLM-4.7 Flash  | `omniroute/zai/glm-4.7-flash`   |
| Best Free      | `omniroute/auto/best-free`      |

## Model ID Mapping

Resolve the research matrix's model names as follows when writing configuration:

| Matrix name      | Configuration model ID          |
| ---------------- | ------------------------------- |
| Claude Opus 5    | `omniroute/combo/claude-opus`   |
| Claude Fable 5   | `omniroute/combo/claude-fable`  |
| Claude Sonnet 5  | `omniroute/combo/claude-sonnet` |
| Claude Haiku 4.5 | `omniroute/combo/claude-haiku`  |
| GPT-5.6 Sol      | `omniroute/codex/gpt-5.6-sol`   |
| GPT-5.6 Terra    | `omniroute/codex/gpt-5.6-terra` |
| GPT-5.6 Luna     | `omniroute/codex/gpt-5.6-luna`  |
| GPT-5.5          | `omniroute/codex/gpt-5.5`       |
| GLM-5.2          | `omniroute/combo/glm-5.2`       |
| GLM-4.7 Flash    | `omniroute/zai/glm-4.7-flash`   |
| Gemini 3.1 Pro   | `omniroute/agy/gemini-3.1-pro`  |
| Best Free        | `omniroute/auto/best-free`      |

## Oh My OpenAgent Runtime Fallback

Use Oh My OpenAgent's `runtime_fallback` only as a session-level resilience layer after the selected model or combo fails. It does not replace OmniRoute combo routing: keep the matrix's direct IDs and family combos as the primary mapping, then fall back through the configured Atlas models.

The active runtime configuration is `~/.omo/omo.jsonc`, under the `[opencode]` scope. The verified fallback chain is:

1. `omniroute/codex/gpt-5.6-sol`
2. `omniroute/combo/glm-5.2`
3. `omniroute/auto/best-free`

The active policy enables runtime fallback, permits three fallback attempts, uses a 60-second cooldown and a 30-second timeout, notifies on fallback, and keeps the session on its successful fallback (`restore_primary_after_cooldown: false`). This prevents long retries against an unavailable primary from blocking a task after the runtime recognizes a retryable provider failure.

## Validation Checklist

1. Confirm every configured model and combo ID is available.
2. Confirm each Claude combo starts with the latest corresponding Claude model tier.
3. Confirm Claude combos use `fill-first`, and use a fallback only where the combo policy explicitly permits it.
4. Confirm the GLM-5 family combo orders healthy allowance-backed targets before paid capacity.
5. Keep GLM-4.7 Flash isolated from GLM-4.7 and unverified aliases.
6. Test every proposed combo target individually before enabling it.
7. Run the Oh My OpenAgent configuration doctor.
8. Smoke-test one role from each model family:
   - Claude: Sisyphus or Metis.
   - Codex: Hephaestus or Oracle.
   - GLM: Explore or Quick.
   - Gemini: Multimodal-Looker or Artistry.
9. Re-check model, combo, entitlement, and provider health after routing changes.
10. When changing runtime fallback, restart OpenCode and induce or observe a retryable primary failure; confirm a fallback request begins within the configured 30-second timeout.

## Configuration Risks

- Model and combo catalogs are dynamic; verify availability before applying changes.
- Combo contents can change independently of agent/category mappings.
- A combo can remain syntactically valid while targeting an outdated model generation.
- Direct Claude provider IDs bypass subscription-level combo routing and should not be used for matrix mappings.
- Similar GLM family names do not guarantee identical context limits, tool behavior, or output quality.
- Provider catalogs can advertise endpoints that fail at runtime; a live probe is authoritative for deployment eligibility.
- Gemini 3.1 Pro uses the OpenCode-catalog-resolvable ID `agy/gemini-3.1-pro`.
- Free models are resilience fallbacks, not quality-equivalent replacements.
