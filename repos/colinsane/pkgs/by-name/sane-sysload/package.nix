{ static-nix-shell }:
static-nix-shell.mkPython3 {
  pname = "sane-sysload";
  srcRoot = ./.;
}
