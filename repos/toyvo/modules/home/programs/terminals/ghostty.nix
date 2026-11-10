{
  pkgs,
  lib,
  config,
  ...
}:
let
  ghosttyConfig = ''
    background-opacity = 0.8
    background-blur = true
    font-family = MonaspiceAr Nerd Font Mono
    font-feature = calt
    font-feature = ss01
    font-feature = ss02
    font-feature = ss03
    font-feature = ss04
    font-feature = ss05
    font-feature = ss06
    font-feature = ss07
    font-feature = ss08
    font-feature = ss09
    font-feature = liga
    theme = light:Catppuccin Latte,dark:Catppuccin Frappe
    command = ${lib.getExe pkgs.fish}
    confirm-close-surface = false
    quit-after-last-window-closed = true
  '';
in
{
  home.packages =
    with pkgs;
    lib.mkIf (stdenv.hostPlatform.isLinux && config.nixcfg.gui.enable) [
      ghostty
    ];
  xdg.configFile."ghostty/config" = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    text = ghosttyConfig;
  };
  # Ghostty on macOS reads ~/Library/Application Support/com.mitchellh.ghostty/config.ghostty,
  # not the XDG path, so manage that path on Darwin (same content, see hyper.nix pattern).
  home.file."Library/Application Support/com.mitchellh.ghostty/config.ghostty" =
    lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
      {
        text = ghosttyConfig;
      };
}
