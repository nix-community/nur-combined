{ pkgs, inputs, ... }: {
  imports = [ inputs.nix-index-database.hmModules.nix-index ];

  home.packages = with pkgs; [
    nixd
    nixfmt
    statix
    hydra-check
    cached-nix-shell
    nix-output-monitor
    comma
    nix-tree
    nurl
    nix-init
  ];

  programs.nix-index = {
    enable = true;
    enableBashIntegration = true;
  };
}

