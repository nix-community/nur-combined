# Scoped Security Checklist

Select only applicable items and record evidence:

- Inputs are validated and normalized at the boundary that owns them.
- Authentication proves identity; authorization is enforced on every protected resource and tenant boundary.
- Queries, templates, shell calls, paths, redirects, and parsers avoid injection and traversal.
- Secrets are absent from source, fixtures, logs, errors, diffs, and generated artifacts; configuration fails safely when required values are missing.
- Sensitive data collection, exposure, logging, transport, storage, retention, and deletion are minimized and intentional.
- Migrations and multi-step writes preserve integrity, support rollback or safe recovery, and handle interruption.
- Public or shared contracts authenticate callers as required, validate requests, bound resource use where risk demands it, and return safe errors.
- Dependencies and CI changes use trusted sources, least privilege, pinned or reviewed execution, and relevant vulnerability or provenance checks.
- Failure and abuse paths have tests or reproducible evidence, and independent review has no unresolved blocking finding.
