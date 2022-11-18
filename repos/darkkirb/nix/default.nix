{nix}:
nix.overrideAttrs (super: {
  patches =
    (super.patches or [])
    ++ [
      ./dedupNixCache.patch
    ];
})
