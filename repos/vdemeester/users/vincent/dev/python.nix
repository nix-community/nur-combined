{ pkgs, ... }:

{
  home.packages = with pkgs; [
    python3
    pipenv
    python3Packages.python-lsp-server
  ];
}
