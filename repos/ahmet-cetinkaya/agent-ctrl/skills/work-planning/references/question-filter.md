# Question Filter

Run every candidate question through two filters, in order:

1. **Could collected evidence answer it?** Explore the repository or research authoritative sources instead of asking.
2. **Could the stated intent plus a defensible default answer it?** Adopt the default, record it under Decisions, and do not ask.

An **owner-decision** always survives as a question even when a default exists:

- anything irreversible, destructive, or safety-critical;
- cross-cutting product choices the user lives with: public configuration surface, distribution or packaging, an external dependency or pinned version, data or schema shape, real budget or paid-service spend, expected scale or capacity, target audience or compliance limits.

Budget, mandated stack, scale, and audience leave no trace in the repository, so exploration cannot surface them: sweep these axes once per plan and record each as explored, defaulted, or asked. Default the reversible internals; surface the owner-decisions. If the user explicitly asks to be interviewed, the adopt-default filter turns off and every surviving fork is asked, with the reason the repository could not settle it.

When the outcome itself is fuzzy, asking offloads the planner's job onto the user: research best practice, adopt and announce defaults, and raise the independent-review bar instead of expanding the interview. Ask the few questions that survive together, each with a recommended default; never dump everything that could be asked.
