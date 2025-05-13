{
  lib,
  static-nix-shell,
}:
let
  self = static-nix-shell.mkBash {
    pname = "nixpkgs-bootstrap-updater";
    srcRoot = ./.;
    pkgs = [ "common-updater-scripts" "curl" "jq" "nix-prefetch-github" ];
    passthru.makeUpdateScript = { branch }: [
      (lib.getExe self)
      branch
    ];
  };
in self
