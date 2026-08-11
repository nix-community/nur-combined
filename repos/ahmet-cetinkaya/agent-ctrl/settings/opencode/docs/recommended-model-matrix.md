# Oh My OpenAgent Recommended Model Matrix

## Executive Summary

Assign model families to the roles that best match their behavior:

- **Claude**: orchestration, planning, instruction following, communication, and writing.
- **Codex/GPT**: deep technical reasoning, autonomous implementation, and complex coding.
- **GLM-4.7 Flash**: fast, high-volume, routine work.
- **GLM-5.2**: difficult fallback work; experimental for Sisyphus.
- **Gemini**: visual, frontend, design, and multimodal work.
- **Free models**: final resilience layer only.

This allocation keeps premium models away from continuous utility workloads and reserves them for low-frequency, high-impact roles.

## Selection Principles

### Match the model family to the agent

Model quality alone does not determine agent performance. Oh My OpenAgent prompts are tuned for distinct model behaviors:

- Claude follows long, mechanics-driven prompts reliably.
- GPT performs best with principle-driven, autonomous work.
- Gemini is the preferred family for visual and creative tasks.
- Fast utility models are better suited to retrieval, search, and trivial changes.

### Protect scarce premium capacity

Use the most expensive models for roles where a single high-quality pass can prevent substantial downstream work. Avoid assigning them to continuous search, retrieval, or routine execution.

### Preserve model-family diversity

Fallback chains should cross model-family boundaries where the agent supports them. This reduces correlated failures and preserves useful behavior when a model family is unavailable or constrained.

## Recommended Agent Matrix

| Agent               | Purpose                                                                                  | Primary             | Fallback order                                             | Rationale                                                                                                                                                      |
| ------------------- | ---------------------------------------------------------------------------------------- | ------------------- | ---------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `sisyphus`          | Main orchestrator that coordinates work, delegates tasks, and drives them to completion. | **Claude Opus 5**   | **Claude Sonnet 5** → **GPT-5.6 Sol** → **GLM-5.2**        | Claude best matches the long orchestration prompt. GPT-5.6 Sol is supported but can over-orchestrate bounded work. GLM-5.2 remains experimental for this role. |
| `hephaestus`        | Autonomous deep worker for complex, long-running implementation tasks.                   | **GPT-5.6 Sol**     | **GPT-5.6 Terra** → **GPT-5.5**                            | GPT-native autonomous implementation role requiring deep technical reasoning.                                                                                  |
| `oracle`            | Read-only specialist for architecture, debugging, and difficult technical decisions.     | **GPT-5.6 Sol**     | **Claude Opus 5** → **Gemini 3.1 Pro** → **GLM-5.2**       | Maximum reasoning quality for architecture and debugging, with cross-family resilience.                                                                        |
| `prometheus`        | Planning agent that gathers requirements and produces decision-complete work plans.      | **Claude Fable 5**  | **Claude Opus 5** → **GPT-5.6 Sol** → **GLM-5.2**          | Officially preferred family for high-accuracy planning.                                                                                                        |
| `metis`             | Pre-planning consultant that identifies ambiguity, hidden intent, and execution risks.   | **Claude Opus 5**   | **Claude Fable 5** → **Claude Sonnet 5** → **GPT-5.6 Sol** | Premium Claude capacity produces high leverage during low-frequency gap analysis.                                                                              |
| `momus`             | Critical reviewer that checks plans for clarity, completeness, and verifiability.        | **GPT-5.6 Terra**   | **GPT-5.6 Sol** → **Claude Opus 5** → **GLM-5.2**          | Strong plan review with a better capacity/quality balance than using Sol for every pass.                                                                       |
| `atlas`             | Execution coordinator that follows approved plans and tracks implementation progress.    | **Claude Sonnet 5** | **Claude Opus 5** → **GPT-5.6 Sol** → **GLM-5.2**          | Claude-style instruction following fits long execution and tracking workflows.                                                                                 |
| `sisyphus-junior`   | Focused delegated executor for a single bounded task without further delegation.         | **Claude Sonnet 5** | **GLM-5.2** → **GPT-5.6 Terra** → **Best Free**            | Strong delegated execution without spending Opus capacity on every task.                                                                                       |
| `explore`           | Fast local codebase search agent for locating files, symbols, and implementation paths.  | **GLM-4.7 Flash**   | **Claude Haiku 4.5** → **Best Free**                       | Search is parallel, frequent, and latency-sensitive; premium frontier models are unnecessary.                                                                  |
| `librarian`         | External research agent for official documentation, libraries, and open-source examples. | **GLM-4.7 Flash**   | **Claude Haiku 4.5** → **Best Free**                       | Documentation and repository retrieval favor speed and capacity efficiency.                                                                                    |
| `multimodal-looker` | Media analysis agent for images, diagrams, screenshots, and documents.                   | **Gemini 3.1 Pro**  | **Claude Sonnet 5** → **GPT-5.6 Sol**                      | Gemini is the strongest fit for visual and multimodal analysis.                                                                                                |

## Recommended Category Matrix

| Category             | Purpose                                                                                   | Primary             | Fallback order                                           | Rationale                                                                                    |
| -------------------- | ----------------------------------------------------------------------------------------- | ------------------- | -------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| `visual-engineering` | Frontend, UI/UX, styling, interaction, and visual-quality work.                           | **Claude Opus 5**   | **Gemini 3.1 Pro** → **Claude Sonnet 5**                 | Claude Opus provides strong implementation quality; Gemini provides visual specialization.   |
| `ultrabrain`         | Genuinely hard, logic-heavy tasks that demand maximum reasoning depth.                    | **GPT-5.6 Sol**     | **Claude Fable 5** → **Claude Opus 5** → **GLM-5.2**     | Maximum logical reasoning and difficult architecture decisions.                              |
| `deep`               | Autonomous problem solving for complex, research-heavy, or technically difficult work.    | **GPT-5.6 Terra**   | **GPT-5.6 Sol** → **Claude Opus 5** → **GLM-5.2**        | Strong autonomous problem solving with a balanced default and a higher-quality GPT fallback. |
| `artistry`           | Creative work that benefits from unconventional approaches and strong aesthetic judgment. | **Gemini 3.1 Pro**  | **Claude Opus 5** → **GPT-5.6 Sol** → **GLM-5.2**        | Gemini-native creative and visual reasoning.                                                 |
| `quick`              | Trivial, narrowly scoped changes with low reasoning requirements.                         | **GLM-4.7 Flash**   | **Claude Haiku 4.5** → **Best Free**                     | Trivial tasks should not consume premium capacity.                                           |
| `unspecified-low`    | General low-effort tasks that do not fit a specialized category.                          | **GPT-5.6 Luna**    | **GLM-4.7 Flash** → **Claude Haiku 4.5** → **Best Free** | Fast and efficient handling of lightweight general work.                                     |
| `unspecified-high`   | General high-effort tasks that do not fit a specialized category.                         | **Claude Opus 5**   | **GPT-5.6 Sol** → **GLM-5.2**                            | Claude compliance for complex general work with a strong GPT fallback.                       |
| `writing`            | Documentation, technical prose, editing, and other writing-focused work.                  | **Claude Sonnet 5** | **GLM-4.7 Flash** → **Claude Haiku 4.5** → **Best Free** | Strong prose quality with efficient lower-cost fallbacks.                                    |

## Capacity Strategy

### Claude

Prioritize Claude capacity for:

1. `sisyphus`
2. `prometheus`
3. `metis`
4. `atlas`
5. `visual-engineering`
6. `writing`

Use Claude only as a fallback for `explore`, `librarian`, and `quick`.

### Codex

Allocate the GPT-5.6 family by workload:

- **Sol**: highest-quality reasoning, difficult coding, architecture, and advanced workflows.
- **Terra**: everyday deep work with a better capacity/quality balance.
- **Luna**: lightweight or high-volume work.

Reserve Sol for `hephaestus`, `oracle`, and `ultrabrain`. Start `deep` and `momus` with Terra.

### Z.AI

Use GLM models by task complexity:

- **GLM-4.7 Flash** for `explore`, `librarian`, and `quick`.
- **GLM-5.2** as a difficult-task fallback.
- Do not use **GLM-5.2** as the Sisyphus primary while its support remains experimental.

## Research Caveats

- Model availability and capabilities evolve; revisit the matrix when a new model generation is released.
- Provider quotas and rate limits may vary by plan, task complexity, context size, and concurrency.
- **GLM-5.2** remains experimental for Sisyphus despite having a calibrated prompt path.
- **GPT-5.6 Sol** is supported for Sisyphus but is better used as fallback coverage than as the default orchestrator.
- Free models provide resilience, not equivalent quality.

## Sources

- [Oh My OpenAgent Agent-Model Matching Guide](https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/dev/docs/guide/agent-model-matching.md)
- [Oh My OpenAgent Features Reference](https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/dev/docs/reference/features.md)
- [Anthropic: Choose a Claude plan](https://support.claude.com/en/articles/11049762-what-is-the-max-plan)
- [Anthropic: Use Claude Code with your Pro or Max plan](https://support.claude.com/en/articles/11145838-use-claude-code-with-your-pro-or-max-plan)
- [OpenAI: Codex pricing and limits](https://developers.openai.com/codex/pricing)
- [Z.AI: GLM Coding Plan overview](https://docs.z.ai/devpack/overview)
