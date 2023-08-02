{ komikku
, fetchFromGitLab
, fetchpatch2
}:
komikku.overrideAttrs (upstream: {
  # src = fetchFromGitLab {
  #   owner = "valos";
  #   repo = "Komikku";
  #   rev = "7dcf2b3d0ba685396872780b1ce75d01cbe02ebe";
  #   hash = "sha256-LzgHPuIpxy0ropiNycdxZP6onjK2JpMRqkkdmJGA4nE=";
  # };
  patches = (upstream.patches or []) ++ [
    (fetchpatch2 {
      url = "https://git.uninsane.org/colin/mirror-komikku/commit/318fc0c975ba84ca4dcff405bc1bb8f5895bc5a6.diff";
      hash = "sha256-mn81hCt5xrypJMOOiCOg8NthLjglXntTDsYpcdCg0E8=";
    })
  ];
  passthru.unpatched = komikku;
})
