{ static-nix-shell }:
static-nix-shell.mkPython3 {
  pname = "clightning-sane";
  srcRoot = ./.;
  pkgs = [ "pyln-client" ];
}
