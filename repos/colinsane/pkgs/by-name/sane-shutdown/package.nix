{
  net-tools,
  static-nix-shell,
  systemd,
}:
static-nix-shell.mkBash {
  pname = "sane-shutdown";
  srcRoot = ./.;
  packages = {
    inherit
      net-tools
      systemd
      ;
  };
}
