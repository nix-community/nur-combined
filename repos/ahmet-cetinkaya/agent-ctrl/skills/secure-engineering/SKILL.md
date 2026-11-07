---
name: secure-engineering
description: Apply threat-boundary analysis and scoped security checks to auth, input, secrets, sensitive data, migrations, APIs, dependencies, and CI. Use when those triggers are present; do not use as a generic checklist for unrelated low-risk changes.
---

# Secure Engineering

## Trigger

Use for authentication or authorization, untrusted input or uploads, secrets, personal or sensitive data, persistence or migrations, public or shared APIs, dependency or supply-chain changes, payments, infrastructure, deployment, or CI permissions.

## Non-trigger

Do not activate merely because code changed, and do not impose unrelated controls such as rate limiting every endpoint. The baseline safety rule still applies to all work.

## Workflow

1. Identify assets, actors, trust boundaries, data flow, privileges, and failure consequences.
2. Use [risk triggers](references/risk-triggers.md) to select applicable threats and an independent review depth.
3. Design controls at boundaries and owners: validation, authorization, least privilege, safe secret use, data minimization, atomicity, rollback, and safe errors or logs.
4. Implement the minimum correct controls following project conventions.
5. Run the scoped [checklist](references/checklist.md), including secret scanning and adversarial or failure-path tests where relevant.
6. Route security, auth, sensitive data, migrations, shared APIs, or CI changes through independent advisor review before readiness.

Never place secret values in prompts, source, logs, tests, screenshots, or reports. If exposure is found, stop propagation and report containment and rotation needs without repeating the value.
