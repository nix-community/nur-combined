{
  rsync,
  static-nix-shell,
}:
static-nix-shell.mkBash {
  pname = "sane-rcp";
  srcRoot = ./.;
  packages = {
    inherit rsync;
  };
}
