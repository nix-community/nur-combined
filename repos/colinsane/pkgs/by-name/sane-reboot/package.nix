{
  net-tools,
  static-nix-shell,
  systemd,
}:
static-nix-shell.mkBash {
  pname = "sane-reboot";
  srcRoot = ./.;
  packages = {
    inherit
      net-tools
      systemd
      ;
  };
}
