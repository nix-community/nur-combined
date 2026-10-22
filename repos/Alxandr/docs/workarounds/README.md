# Workarounds and automatic review

Temporary compatibility fixes must be discoverable and have enough context for
a later agent to decide whether they are still needed.

## Register a workaround

1. Choose a stable ID of the form `YYYY-MM-DD-short-description`, using the date
   the workaround was introduced.
2. Put a comment immediately above the workaround using the source language's
   comment syntax, for example:

   ```nix
   # autoreview: 2026-10-22-patchelf-bug
   ```

3. Create `docs/workarounds/<id>.md`. Record:
   - Status (`active`, `fixed upstream`, or `resolved`) and last review date.
   - Affected files, packages, versions, and the condition activating the fix.
   - Symptoms, reproduction steps, and upstream issue/fix links.
   - What the workaround changes and why it is scoped that way.
   - Evidence from verification, including exact nixpkgs revisions and gaps.
   - Concrete removal criteria and how to verify them.

Use the same ID at multiple locations belonging to one issue. Keep identifiers
unchanged during later reviews. Avoid putting a live marker in documentation;
the code comment is the discovery point.

## Status meanings

- `active`: the issue still requires a workaround and has no confirmed upstream
  fix.
- `fixed upstream`: upstream has fixed the issue, but the fix has not propagated
  to all supported nixpkgs inputs that need it. Keep the workaround and its
  markers until removal is verified across the matrix.
- `resolved`: the workaround has been removed after verification against all
  supported inputs. Retain the record as history.

Both `active` and `fixed upstream` are open workarounds and must be included in
reviews. For `fixed upstream`, focus on propagation into the supported inputs
and the remaining removal criteria.

## Review open issues and workarounds

A request such as "Review open issues/workarounds" invokes this procedure.
It covers registered workarounds and their linked upstream issues.

1. Discover markers from the repository root:

   ```sh
   rg -n 'autoreview: [0-9]{4}-[0-9]{2}-[0-9]{2}-[a-z0-9-]+' --glob '!docs/**' --glob '!AGENTS.md' .
   ```

   Deduplicate IDs and check that every marker has a matching record. Also
   check records for `active` or `fixed upstream` entries without markers.
   Report missing records, orphaned open records, and resolved records that
   still have live markers.
2. Read the current matrix in `.github/workflows/build.yml`. Resolve the exact
   nixpkgs revisions used for the review; do not assume the flake lock covers
   the matrix or that moving branch URLs still resolve as in an older review.
3. Spawn one subagent per distinct ID. Give each agent its marker locations,
   record path, and the matrix inputs. Each agent must:
   - Read the record and the current implementation.
   - Check linked upstream issues, merged fixes, release contents, and whether
     the fix has reached each relevant nixpkgs input.
   - Check whether the activation condition still occurs across the matrix.
   - Where removal appears possible, test the affected package without the
     workaround in an isolated temporary copy or expression. Keep the working
     tree unchanged during the review.
   - Report `keep`, `update`, or `remove`, with reasons, current source links,
     exact revisions, checks performed, and outstanding uncertainty. An
     upstream issue closing is not sufficient proof that removal is safe.
4. Aggregate the reports and confirm every ID was reviewed. If a check cannot
   be completed, say so and retain the workaround pending evidence. A review
   reports recommendations; implement changes when requested.

## Update or retire a workaround

When implementing a review result, update the record's last review date,
evidence, activation condition, and removal criteria as appropriate.

Remove the code and its markers together only after validating removal against
all supported inputs. Mark the record `resolved`, record the date and evidence,
and retain it as history. Resolved records without markers are expected and do
not need a subagent in subsequent reviews.
