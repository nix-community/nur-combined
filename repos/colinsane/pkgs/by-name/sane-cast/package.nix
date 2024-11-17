{ static-nix-shell }:
static-nix-shell.mkPython3 {
  pname = "sane-cast";
  pkgs = [ "blast-ugjka" "go2tv" ];
  srcRoot = ./.;
}

