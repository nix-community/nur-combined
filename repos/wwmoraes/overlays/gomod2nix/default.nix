final: prev: {
  gomod2nix = prev.gomod2nix.overrideAttrs (prevAttrs: {
    patches = (prevAttrs.patches or [ ]) ++ [
      ./nix-eval-impure.patch
    ];
  });
}
