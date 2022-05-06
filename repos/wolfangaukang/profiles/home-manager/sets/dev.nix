{ pkgs, ... }:

{
  imports = [
    ../common/git.nix
    ../common/gpg.nix
    ../common/vscode.nix
  ];

  home = {
    packages = with pkgs; [
      # Python settings
      (python38.withPackages (ps: with ps; [pycodestyle virtualenv]))
      shellcheck
    ];
  };
}
