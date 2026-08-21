final: prev: {
  gomod2nix = prev.gomod2nix.overrideAttrs (prevAttrs: {
    meta.platforms = prev.lib.platforms.all;
    patches = (prevAttrs.patches or [ ]) ++ [
      ./nix-eval-impure.patch
    ];
  });
}
