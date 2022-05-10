{ pkgs, ... }:

{
  imports = [
    ../common/bashblog.nix
    ../common/git.nix
    ../common/gpg.nix
    ../common/neovim.nix
    ../common/pass.nix
    ../common/ssh.nix
  ];

  home.packages = with pkgs; [
    tree p7zip nixpkgs-review
  ];
}
