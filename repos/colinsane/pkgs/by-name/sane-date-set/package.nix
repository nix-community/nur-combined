{
  coreutils,
  static-nix-shell,
  systemd,
}:
static-nix-shell.mkBash {
  pname = "sane-date-set";
  srcRoot = ./.;
  packages = { inherit coreutils systemd; };
}
