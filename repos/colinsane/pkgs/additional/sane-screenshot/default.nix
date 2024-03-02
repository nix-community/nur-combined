{ static-nix-shell }:
static-nix-shell.mkBash {
  pname = "sane-screenshot";
  srcRoot = ./.;
  pkgs = [ "libnotify" "swappy" "sway-contrib.grimshot" "util-linux" "wl-clipboard" ];
}
