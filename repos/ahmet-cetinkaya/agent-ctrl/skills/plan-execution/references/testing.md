# Testing Guidance

Discover the project's checks from instructions, manifests, task runners, CI, and neighboring tests. Prefer the narrowest meaningful proof first, then broaden for shared interfaces or risk.

For a bug, capture the reported failure or a regression test before the fix when practical, then show the same proof passing. For existing behavior changes, preserve intentional behavior with characterization evidence where useful. Test externally visible outcomes rather than mirroring implementation details.

Add hands-on QA for user-facing, CLI, data, configuration, or integration surfaces. State exact inputs and observables. Do not invent a universal coverage percentage; use the project's defined threshold and risk profile.
