---
name: ac:review:security
description: "Orchestrator command for security vulnerabilities and secure coding practices. Reviews OWASP rules, injection risks, and authorization errors."
category: review
complexity: advanced
mcp-servers: []
personas: [security-reviewer]
---

# Security Review Orchestrator

This command is a category orchestrator triggered by `/ac:review`. Its task is to assign the relevant security agents (`security-reviewer`) to review the provided files from a **security vulnerabilities** perspective.

## Scope
- **Input Validation**: SQL Injection, XSS, Command Injection risks
- **Authentication/Authorization**: Authorization errors, sensitive data exposure
- **Data Protection**: Insecure encryption, hardcoded secrets
- **Configuration**: Insecure default settings

## Workflow
1. Receives target files from `/ac:review`.
2. Passes these files to the `security-reviewer` agent for a detailed vulnerability scan.
3. Collects the identified findings and (if possible) **Refactored Code** outputs that resolve the vulnerability, and returns them to the main `/ac:review` command.
