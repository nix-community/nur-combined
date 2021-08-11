{ config, pkgs, ... }: {
  imports = [ ./common.nix ./dev.nix ];
  home.packages = [ pkgs.taskwarrior ];

  programs.kakoune.config.colorScheme = pkgs.lib.mkForce "default";
}
