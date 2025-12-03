{
  pkgs,
  ...
}:

let
  inherit (pkgs) golangci-lint gopls gorin;

in
{
  packages = [
    golangci-lint
    gopls
    gorin
  ];
  languages = {
    go.enable = true;
    nix.enable = true;
  };
}
