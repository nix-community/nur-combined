{ static-nix-shell }:
static-nix-shell.mkPython3Bin {
  pname = "sane-die-with-parent";
  srcRoot = ./.;
  pyPkgs = [ "psutil" ];
}
