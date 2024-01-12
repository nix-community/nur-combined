# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ config, pkgs, ... }:
let
  yazi-themes = pkgs.fetchFromGitHub { owner = "yazi-rs"; repo = "themes"; rev = "8abf251851b9b7559f810a65932cd7735b202dfa"; sha256 = "sha256-f8Mwacw8FoZ5S0wUdQcmtFZwrxDyabJfL7kPKhmOD1A="; };
in
{
  home.file.".config/yazi/theme.toml".source = "${yazi-themes}/catppuccin/mocha.toml";

  programs = {
    zsh.shellAliases.ya = config.programs.bash.shellAliases.ya;
    bash.shellAliases.ya = ''
      tmp="$(mktemp -t "yazi-cwd.XXXXX")"
      yazi "$@" --cwd-file="$tmp"
      if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
      fi
      rm -f -- "$tmp"
    '';
    fish.shellAliases.ya = ''
      set tmp (mktemp -t "yazi-cwd.XXXXX")
      yazi $argv --cwd-file="$tmp"
      if set cwd (cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        cd -- "$cwd"
      end
      rm -f -- "$tmp"
    '';
    yazi = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
    };
  };
}
