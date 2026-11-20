{ lastbook }:

# lastbook with PR #38, "Maps: Australian capital and state/territory extract
# areas" (draft, stacked on #30's region-map support): eight capital-area and
# eight state/territory boxes, region maps grouped by country in setup, and the
# packaging tools that build them.
#
# 0001 is the PR diff rebased onto the released tag (only the region-map docs
# hunk needed a manual merge with v1.1.13's newer docs). 0002 lets setup accept
# the review maps' GitHub release assets, which the product's allowlist would
# otherwise refuse; the SHA-256 in the manifest still checks every byte. The
# manifest this variant installs is upstream's plus those eight maps, generated
# by make-manifest.py, so setup offers them instead of only US states.
#
# 0003 lets the person go past "Not enough room" (the setup page asks with a
# "Continue anyway" checkbox, and `start` takes `force: true`): the estimates at
# start, per file and at unpack are skipped, so only a disk that actually fills
# stops the job. Upstream keeps that guard on purpose; this variant trusts the
# person's own judgement about the space they have.
#
# The update script bumps the base version and regenerates the manifest; it does
# not regenerate or re-check the patches, so rebase them when lastbook moves.
# Its GUI smoke test is `checks.x86_64-linux.lastbook-patched-setup`.
lastbook.overrideAttrs (old: {
  pname = "lastbook_patched";

  patches = (old.patches or [ ]) ++ [
    ./0001-australian-capital-and-state-territory-maps.patch
    ./0002-review-download-hosts.patch
    ./0003-continue-without-enough-room.patch
  ];

  postInstall = (old.postInstall or "") + ''
    install -Dm644 ${./manifest-v1.json} "$out/share/lastbook/setup/manifest-v1.json"
  '';

  passthru = (old.passthru or { }) // {
    updateScript = ./update.sh;
  };
})
