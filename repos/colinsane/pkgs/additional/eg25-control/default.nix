{ static-nix-shell }:
static-nix-shell.mkPython3Bin {
  pname = "eg25-control";
  src = ./.;
  pkgs = [ "curl" "modemmanager" ];
}
