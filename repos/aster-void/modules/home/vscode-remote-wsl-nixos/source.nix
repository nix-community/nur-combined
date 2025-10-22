{pkgs ? import <nixpkgs> {}}:
pkgs.fetchFromGitHub {
  owner = "sonowz";
  repo = "vscode-remote-wsl-nixos";
  rev = "69a0156a137fa74c06e3967e52c52a71ee7ddb71";
  hash = "sha256-VB4UuCz+EcCeNN8LABE/USz+RGCd3PLAP4/QYPlh8TY=";
}
