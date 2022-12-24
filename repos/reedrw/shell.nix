with import <nixpkgs> { };
with pkgs;
mkShell {
  name = "nur-packages";
  packages = [
    cargo
    gcc
    jq
    niv
    nix-prefetch
    nix-prefetch-github
    nix-update
    nodePackages.node2nix
    pre-commit
    shellcheck
  ];

  PRE_COMMIT_COLOR = "never";
  SHELLCHECK_OPTS = "-e SC1008";
}
