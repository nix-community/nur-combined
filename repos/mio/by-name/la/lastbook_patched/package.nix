{ lastbook }:

# lastbook with PR #38, "Maps: Australian capital and state/territory extract
# areas" (draft, stacked on #30's region-map support): eight capital-area and
# eight state/territory boxes, region maps grouped by country in setup, and the
# packaging tools that build them.
#
# The patch is the PR diff rebased onto the released tag (only the region-map
# docs hunk needed a manual merge with v1.1.13's newer docs). The inherited
# update script bumps the base version and the setup manifest; it does not
# regenerate or re-check this patch, so rebase it when lastbook moves.
lastbook.overrideAttrs (old: {
  pname = "lastbook_patched";

  patches = (old.patches or [ ]) ++ [
    ./0001-australian-capital-and-state-territory-maps.patch
  ];
})
