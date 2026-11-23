{
  lib,
  pkgs,
  ...
}:

let

  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;

  coreutils = pkgs.coreutils;
  findutils = pkgs.findutils;
  osc = pkgs.osc;
  wlclip = pkgs.wl-clipboard;
  xclip = pkgs.xclip;

  # based on https://github.com/nikitabobko/dotfiles/blob/main/.bin/cb

  # macOS: assume pbcopy/pbpaste are present; use realpath from Nix coreutils
  cbDarwin = pkgs.writeShellScriptBin "cb" ''
    set -euo pipefail

    paste() { pbpaste; }
    copy()  { pbcopy; }

    if [ "$#" -eq 1 ]; then
      "${coreutils}/bin/realpath" "$1" | "${findutils}/bin/xargs" "${coreutils}/bin/echo" -n | copy
    elif [ ! -t 0 ]; then
      copy
    else
      paste
    fi
  '';

  cbLinux = pkgs.writeShellScriptBin "cb" ''
    set -euo pipefail

    is_wayland() { [ -n "''${WAYLAND_DISPLAY:-}" ] || [ -n "''${SWAYSOCK:-}" ]; }
    is_x11()     { [ -n "''${DISPLAY:-}" ]; }

    copy() {
      if is_wayland; then
        "${wlclip}/bin/wl-copy"
      elif is_x11; then
        "${xclip}/bin/xclip" -selection clipboard
      else
        "${osc}/bin/osc" copy
      fi
    }

    paste() {
      if is_wayland; then
        "${wlclip}/bin/wl-paste"
      elif is_x11; then
        "${xclip}/bin/xclip" -selection clipboard -o
      else
        "${osc}/bin/osc" paste
      fi
    }

    if [ "$#" -eq 1 ]; then
      "${coreutils}/bin/realpath" "$1" | "${findutils}/bin/xargs" "${coreutils}/bin/echo" -n | copy
    elif [ ! -t 0 ]; then
      copy
    else
      paste
    fi
  '';

  cb = (if isDarwin then cbDarwin else cbLinux).overrideAttrs (_: {
    meta = {
      description = "Cross-platform clipboard utility";
      homepage = "https://github.com/nikitabobko/dotfiles";
      license = lib.licenses.mit;
      platforms = lib.platforms.linux ++ lib.platforms.darwin;
      mainProgram = "cb";
    };
  });

in
cb
