{ static-nix-shell }:
static-nix-shell.mkBash {
  pname = "sane-open-desktop";
  srcRoot = ./.;
  pkgs = [ "glib" ];
}
