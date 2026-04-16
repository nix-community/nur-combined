{ pkgs, sources, ... }: {
  codex = pkgs.callPackage ./build.nix { inherit sources; };
  codex-bin = pkgs.callPackage ./bin.nix { inherit sources; };
}
