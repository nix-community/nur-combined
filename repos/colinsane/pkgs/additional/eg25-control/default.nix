{ static-nix-shell }:
static-nix-shell.mkPython3Bin {
  pname = "eg25-control";
  srcRoot = ./.;
  pkgs = [ "curl" "modemmanager" ];
}
