{
  pkgs,
  ...
}:

let
  inherit (pkgs) golangci-lint gorin;

in
{
  packages = [
    golangci-lint
    gorin
  ];
  languages = {
    go = {
      enable = true;
      lsp.enable = true;
    };
    nix.enable = true;
  };
}
