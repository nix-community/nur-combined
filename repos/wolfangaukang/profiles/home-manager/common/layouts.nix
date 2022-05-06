{ config, pkgs, lib, ... }:

{
  home.file = {
    ".xkb/symbols/colemak-bs_cl".source = ../../../misc/dotfiles/config/xkbmap/colemak-bs_cl;
    ".xkb/symbols/dvorak-bs_cl".source = ../../../misc/dotfiles/config/xkbmap/dvorak-bs_cl;
  };
}
