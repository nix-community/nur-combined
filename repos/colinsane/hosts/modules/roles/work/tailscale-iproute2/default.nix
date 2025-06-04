{
  iproute2,
  static-nix-shell,
  symlinkJoin,
}:
let
  ipCmd = static-nix-shell.mkYsh {
    pname = "ip";
    pkgs = [ "iproute2" "systemdMinimal" ];
    srcRoot = ./.;
  };
in symlinkJoin {
  name = "tailscale-iproute2";
  paths = [
    ipCmd
    iproute2
  ];
}
