{
  sane-bt,
  static-nix-shell,
}:
static-nix-shell.mkPython3 {
  pname = "sane-bt-show";
  srcRoot = ./.;
  packages = {
    inherit sane-bt;
  };
}
