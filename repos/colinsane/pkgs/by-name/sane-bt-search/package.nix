{
  python3,
  static-nix-shell,
}:
static-nix-shell.mkPython3 {
  pname = "sane-bt-search";
  srcRoot = ./.;
  packages = {
    "python3.pkgs.requests" = python3.pkgs.requests;
  };
}
