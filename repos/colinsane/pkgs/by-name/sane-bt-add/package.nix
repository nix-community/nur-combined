{
  python3,
  sane-bt,
  static-nix-shell,
}:
static-nix-shell.mkPython3 {
  pname = "sane-bt-add";
  srcRoot = ./.;
  packages = {
    inherit sane-bt;
    "python3.pkgs.requests" = python3.pkgs.requests;
  };
}
