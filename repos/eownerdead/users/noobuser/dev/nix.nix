{ pkgs, inputs, ... }: {
  imports = [ inputs.nix-index-database.hmModules.nix-index ];

  home.packages = with pkgs; [
    nixd
    nixfmt
    statix
    hydra-check
    nix-output-monitor
    comma
    nix-tree
    nurl
    nix-init
    nixpkgs-review
  ];

  programs.nix-index = {
    enable = true;
    enableBashIntegration = true;
  };
}

