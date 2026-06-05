{
  curl,
  gitMinimal,
  lib,
  nix,
  patchutils,
  static-nix-shell,
}:
let
  self = static-nix-shell.mkBash {
    pname = "vendor-patch-updater";
    srcRoot = ./.;
    pkgs = {
      inherit
        curl
        gitMinimal
        nix
        patchutils
        ;
    };
    passthru.makeUpdateScript = { ident }: [
      (lib.getExe self)
      ident
    ];
  };
in self
