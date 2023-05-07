{ config, lib, pkgs, ... }:
{
  programs.fish.loginShellInit = ''
    set TTY1 (tty)
    [ "$TTY1" = "/dev/tty1" ] && exec sway
  '';

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      swayidle
      swaylock
      wl-clipboard
    ];
  };

  environment.etc."sway/config".text = import ./_swayConfig.nix { inherit lib pkgs; };
  environment.etc."xdg/swayr/config.toml".text = import ./_swayrConfig.nix { inherit lib pkgs; };
}
