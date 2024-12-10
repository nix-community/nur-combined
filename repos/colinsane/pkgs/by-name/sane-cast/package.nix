{ static-nix-shell }:
static-nix-shell.mkPython3 {
  pname = "sane-cast";
  pkgs = [ "go2tv" "sblast" ];
  srcRoot = ./.;
}

