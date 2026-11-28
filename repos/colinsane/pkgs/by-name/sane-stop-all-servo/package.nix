{
  static-nix-shell,
  systemd,
}:
static-nix-shell.mkYsh {
  pname = "sane-stop-all-servo";
  srcRoot = ./.;
  packages = {
    inherit systemd;
  };
}
