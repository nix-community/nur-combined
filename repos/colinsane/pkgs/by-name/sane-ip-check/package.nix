{
  miniupnpc,
  python3,
  sane-ssdp,
  static-nix-shell,
}:
static-nix-shell.mkPython3 {
  pname = "sane-ip-check";
  srcRoot = ./.;
  packages = {
    inherit miniupnpc sane-ssdp;
    "python3.pkgs.requests" = python3.pkgs.requests;
  };
}
