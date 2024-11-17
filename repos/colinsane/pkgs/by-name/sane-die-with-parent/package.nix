{ static-nix-shell }:
static-nix-shell.mkPython3 {
  pname = "sane-die-with-parent";
  srcRoot = ./.;
  pkgs = [ "python3.pkgs.psutil" ];
}
