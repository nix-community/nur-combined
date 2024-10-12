{ pkgs, inputs, ... }:
{
  imports = [ inputs.nix-index-database.hmModules.nix-index ];

  home.packages = with pkgs; [
    nixd
    nixfmt-rfc-style
    statix
    hydra-check
    nix-output-monitor
    comma
    nix-tree
    nurl
    nix-init
    nixpkgs-review
    nix-fast-build
  ];

  programs.nix-index = {
    enable = true;
    enableBashIntegration = true;
  };
}
