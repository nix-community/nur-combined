# Backport https://github.com/Mic92/nix-update/pull/698 until nixpkgs includes it.
final: prev: {
  nix-update = prev.nix-update.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./nix-update-prefetch.patch ];
  });
}
