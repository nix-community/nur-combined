{ static-nix-shell }:
static-nix-shell.mkPython3 {
  pname = "eg25-control";
  srcRoot = ./.;
  pkgs = [ "curl" "modemmanager-split.mmcli" "python3.pkgs.libgpiod" ];
}
