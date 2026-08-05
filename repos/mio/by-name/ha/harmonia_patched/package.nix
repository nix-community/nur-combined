{ harmonia, fetchpatch }:

harmonia.overrideAttrs (oldAttrs: {
  pname = "harmonia-patched";

  patches = (oldAttrs.patches or [ ]) ++ [
    (fetchpatch {
      name = "cache-set-status-code-to-206-for-ranged-NAR.patch";
      url = "https://github.com/nix-community/harmonia/pull/1139.patch";
      hash = "sha256-B6U6PuW9QX6Tn+2VnoT1m2y4U2VQConKUR0K9r9SP18=";
    })
  ];
})
