# Spec Quality

Run these passes before presenting a spec. Fix findings in place, at most three rounds; carry anything still open as a `[NEEDS CLARIFICATION]` marker or an Assumption.

## Defaults before questions

Apply [the question filter](question-filter.md) first: repository evidence and defensible defaults answer most questions. Do not ask about details with an industry-standard default — data retention for the domain, ordinary performance expectations, user-friendly error messages with a fallback, the project's existing authentication and integration patterns. Record each default under Assumptions.

What survives is prioritized:

1. **Scope** — what is in or out, which user stories exist, what the P1 slice is.
2. **Security and privacy** — who may do what, which data is sensitive, what must be audited.
3. **User experience** — visible behavior on success, failure, and empty states.
4. **Technical constraints the user owns** — compatibility, external systems, data shape.

Never ask how to implement: technology, architecture, and task breakdown belong to the plan.

## Asking a question

Every question, when creating or refining:

- Starts with `**Question:**` and a complete interrogative ending in `?`, optionally followed by the affected ID in parentheses: `**Question:** Who may export reports? (FR-004)`. A topic label or a bare ID is not a question.
- Follows with one plain sentence on why it matters for acceptance or shipping.
- Gives the recommended answer first with one or two sentences of reasoning: `**Recommended:** Option B — <reason>`.
- Offers two to five mutually exclusive options in an `Option | Answer | Implications` table, or asks for a short answer of at most five words with a suggested value when no discrete options exist.
- Accepts "yes" or "recommended" as the recommended answer. An ambiguous reply gets one disambiguation that does not count as a new question.

When creating a spec, ask at most three surviving questions, all in one message. When refining an existing spec, follow the refinement protocol below.

## Success criteria

Each `SC-###` is measurable (time, percentage, count, or rate), technology-agnostic, user-focused, and verifiable without knowing the implementation. Mix quantitative outcomes with qualitative ones such as task completion. "Users complete checkout in under three minutes" and "95% of searches return results in under one second" qualify; "API response time under 200 ms", "the cache hit rate exceeds 80%", or "components render efficiently" do not — they describe internals, so restate them as what the user observes.

## Requirements checklist

Write the result to `checklists/requirements.md` beside the spec on every creation and refinement, so the quality state is reviewable. Mark each item `[x]` or `[ ]`; under `## Notes`, quote the spec text behind every failing item.

Content quality:

- [ ] No implementation detail: no language, framework, storage, API, or file names.
- [ ] Focused on user value and business need, readable by a non-technical stakeholder.
- [ ] Sections that do not apply are removed, not left as "N/A," except User experience.

Requirement completeness:

- [ ] Every `FR-###` uses an EARS pattern with `SHALL` and one observable behavior.
- [ ] Every `FR-###` traces to a user story; every story has a priority reason, an independent test, and at least one scenario.
- [ ] Every `SC-###` meets the success-criteria rules above.
- [ ] User experience lists the flow, states, a fixed design link when a design exists, and accessibility, with every state covered by a scenario or `FR-###`; or it states `none — no user interface`.
- [ ] Edge cases cover empty, invalid, boundary, concurrent, unauthorized, and failure inputs.
- [ ] Key entities are listed when the change involves data.
- [ ] Changes to existing behavior include `PRESERVED` statements (at least two).
- [ ] Assumptions and dependencies are listed; no silent guess remains in the requirement text.
- [ ] Scope is bounded by explicit out-of-scope entries.

Readiness:

- [ ] At most three `[NEEDS CLARIFICATION]` markers; none inside an approved spec.
- [ ] No vague words ("works," "fast," "secure," "robust," "intuitive") and no placeholders (`TODO`, `???`, `<…>`) without an observable.
- [ ] Terminology is consistent across stories, requirements, entities, and criteria.
- [ ] The spec meets the spec contract's Size rule, or Out of scope records the declined split.

## Hostile-reader pass

Read the spec as someone who wants to implement it wrongly while still satisfying the text. For each requirement ask: could two reasonable engineers build different things from this sentence? Which input or state is not covered? What would a careless or malicious user try? Every gap found becomes a sharper requirement, an edge case, or an Assumption — never a comment.

## Coverage taxonomy

When refining, rate each area `Clear`, `Partial`, or `Missing`; only `Partial` or `Missing` areas may produce questions, and only when the answer would change the requirements, the tests, or the acceptance decision.

- Functional scope: core goals, success signal, out-of-scope declarations, roles and personas.
- Domain and data: entities, attributes, relationships, identity and uniqueness rules, lifecycle and state transitions, volume and scale.
- Interaction: critical journeys, error, empty, and loading states, accessibility and localization.
- Quality attributes: performance, scalability, reliability and recovery, observability, security and privacy, compliance.
- Integrations: external services and their failure modes, import and export formats, protocol and versioning assumptions.
- Edge cases: negative scenarios, rate limiting, conflict resolution such as concurrent edits.
- Constraints and tradeoffs the user owns, including rejected alternatives.
- Terminology: canonical terms and avoided synonyms.
- Completion signals: testable acceptance and measurable done criteria.
- Placeholders and unquantified adjectives.
- Preserved behavior, for changes to existing capabilities.

## Refinement protocol

1. Build a private queue of at most five questions, ordered by impact × uncertainty; cover the highest-impact unresolved area before two low-impact ones. If nothing qualifies, say "No critical ambiguities worth clarifying", show a compact coverage summary, and stop.
2. Ask exactly one question at a time and never reveal the queued ones. Stop early when the remaining questions became unnecessary or the user says done, stop, or proceed.
3. After each accepted answer, write it immediately:
   - Append `- Q: <question> → A: <answer>` under `## Clarifications` → `### Session <YYYY-MM-DD>`, one bullet per answer.
   - Apply it to the owning section: a functional answer to Requirements, an actor or flow to User stories, a data answer to Key entities, a non-functional target to Success criteria as a measurable value, a negative flow to Edge cases.
   - Replace any statement the answer invalidates rather than adding beside it, and remove the marker it resolves. Normalize a renamed term everywhere, noting `(formerly "X")` once.
   - Save the spec after each answer.
4. When the five questions are spent and high-impact areas remain `Partial` or `Missing`, list them under Deferred with the reason.
5. Re-evaluate `checklists/requirements.md` against the updated spec, toggling only the items whose state changed, and report the newly passing items, regressions, still-failing items, and the before → after pass count.
