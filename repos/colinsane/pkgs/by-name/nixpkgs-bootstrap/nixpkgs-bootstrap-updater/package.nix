{
  curl,
  jq,
  lib,
  nix-prefetch-git,
  nix-prefetch-github,
  static-nix-shell,
  update-source-version,
}:
let
  self = static-nix-shell.mkBash {
    pname = "nixpkgs-bootstrap-updater";
    srcRoot = ./.;
    # XXX(2025-12-30): nix-prefetch-github requires nix-prefetch-git ALSO be on path.
    # unclear why it doesn't wrap that.
    pkgs = {
      inherit
        curl
        jq
        nix-prefetch-git
        nix-prefetch-github
        update-source-version
      ;
    };
    passthru.makeUpdateScript = { branch }: [
      (lib.getExe self)
      branch
    ];
  };
in self
