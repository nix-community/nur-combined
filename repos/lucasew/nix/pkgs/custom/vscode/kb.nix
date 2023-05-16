{ pkgs ? import <nixpkgs> {}, ...}:
{
  identifier = "kb";
  imports = [
    ./common.nix
  ];
  extensions = [
    {
      publisher = "foam";
      name = "foam-vscode";
      version = "0.15.2";
      sha256 = "sha256-toaXVrnyuSo/DTUNLONGQlkBBapPFbFIwcp7xteP1IU=";
    }
  ];
}
