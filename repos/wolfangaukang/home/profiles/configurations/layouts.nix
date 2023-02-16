{ inputs, ... }:

let
  inherit (inputs) dotfiles;

in {
  home.file = {
    ".xkb/symbols/colemak-bs_cl".source = "${dotfiles}/config/xkbmap/colemak-bs_cl";
    ".xkb/symbols/dvorak-bs_cl".source = "${dotfiles}/config/xkbmap/dvorak-bs_cl";
  };
}
