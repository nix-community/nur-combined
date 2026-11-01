{
  python3,
  static-nix-shell,
}:
static-nix-shell.mkPython3 {
  pname = "sane-die-with-parent";
  srcRoot = ./.;
  packages = {
    "python3.pkgs.psutil" = python3.pkgs.psutil;
  };
}
