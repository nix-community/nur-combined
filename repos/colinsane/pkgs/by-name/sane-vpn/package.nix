{
  bunpen,
  iproute2,
  networkmanager-split,
  sane-ip-check,
  static-nix-shell,
  systemd,
}:
static-nix-shell.mkPython3 {
  pname = "sane-vpn";
  srcRoot = ./.;
  packages = {
    inherit
      bunpen
      iproute2
      systemd
      ;
    "networkmanager-split.nmcli" = networkmanager-split.nmcli;
    "sane-ip-check" = sane-ip-check;
  };
}
