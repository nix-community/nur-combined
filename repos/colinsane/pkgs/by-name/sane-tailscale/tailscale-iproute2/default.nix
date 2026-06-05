{
  iproute2,
  static-nix-shell,
  symlinkJoin,
  systemd,
}:
let
  ipCmd = static-nix-shell.mkYsh {
    pname = "ip";
    pkgs = {
      inherit
        iproute2
        systemd
        ;
    };
    srcRoot = ./.;
    doInstallCheck = false;  #< doesn't implement required `--help` command
  };
in symlinkJoin {
  name = "tailscale-iproute2";
  paths = [
    ipCmd
    iproute2
  ];
}
