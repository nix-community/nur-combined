{
  inetutils,
  miniupnpc,
  sane-ssdp,
  static-nix-shell,
}:
static-nix-shell.mkPython3 {
  pname = "sane-ip-port-forward";
  srcRoot = ./.;
  packages = {
    inherit
      inetutils
      miniupnpc
      sane-ssdp
      ;
  };
}
