# `secure-engineering` composition

- **Target and responsibility:** Contextual threat-boundary design and verification for security-sensitive changes.
- **Sources:** [Everything Claude Code](https://github.com/affaan-m/ECC) `skills/security-review/SKILL.md`, auth, input, secrets, API, data, error, and dependency checks; [Everything Claude Code](https://github.com/affaan-m/ECC) `skills/safety-guard/SKILL.md`, destructive/shared-state awareness; [Everything Claude Code](https://github.com/affaan-m/ECC) `skills/intent-driven-development/SKILL.md`, risk-triggered acceptance criteria.
- **Behavior taken:** Risk triggers, assets/actors/boundaries, minimum controls, secret scanning, rollback/data integrity, adversarial evidence, and independent review.
- **Merge:** Security implementation and review move into one focused skill, while universal authorization and secret boundaries stay in `safety.md`.
- **Provider adaptation:** Hook-specific blocking and framework examples are replaced by behavioral gates usable with either provider.
- **Exclusions:** Rate limiting every endpoint, universal framework controls, blanket stop-the-world review, and tool-specific guard modes were omitted.
- **Attribution:** Original rewrite drawing on [Everything Claude Code](https://github.com/affaan-m/ECC) (MIT); no upstream prose is copied verbatim.
