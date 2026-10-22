# Repository instructions

## Multiple nixpkgs versions

This repository is built against multiple versions of nixpkgs. The source of
truth for the supported inputs and their URLs is the matrix in
[.github/workflows/build.yml](.github/workflows/build.yml).

Read that matrix before changing or validating Nix packaging. The flake's
locked nixpkgs input is not the complete compatibility target. Check evaluation
and relevant builds against every matrix input affected by a change, including
inputs where a conditional workaround is inactive. Record the exact resolved
nixpkgs revisions and distinguish completed checks from unverified inputs.

## Workaround reviews

Temporary workarounds use `autoreview` comments linked to records under
`docs/workarounds`. Follow
[the workaround procedure](docs/workarounds/README.md) when adding a workaround
or when asked to review open issues or workarounds.

For a review, discover all markers and delegate one subagent per distinct
workaround ID. Each subagent reads the corresponding record, checks current
upstream status and the supported nixpkgs inputs, and reports whether to keep,
update, or remove the workaround, with evidence and verification gaps. The
parent agent checks coverage and combines the findings. If subagents are not
available, state that limitation and review each record separately.
