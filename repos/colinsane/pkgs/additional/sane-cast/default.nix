{ static-nix-shell }:
static-nix-shell.mkPython3Bin {
  pname = "sane-cast";
  srcRoot = ./.;
  pyPkgs = [ ];
}

