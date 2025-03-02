{ systemd, fetchpatch }:
systemd.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    # https://github.com/systemd/systemd/pull/35497
    (fetchpatch {
      url = "https://github.com/systemd/systemd/compare/6013dee98d6543ac290a2938c4ec8494e26531ab%5E...6013dee98d6543ac290a2938c4ec8494e26531ab.patch";
      hash = "sha256-DVDp+FkY0PdYfY8FG2eTjA7n6xczMvL+6B6hB0wLZgU=";
    })
  ];
})
