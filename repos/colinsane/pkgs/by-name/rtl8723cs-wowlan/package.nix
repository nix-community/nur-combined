{
  hostname-debian,
  iw,
  static-nix-shell,
  wirelesstools,
}:

static-nix-shell.mkPython3 {
  pname = "rtl8723cs-wowlan";
  srcRoot = ./.;
  pkgs = {
    inherit hostname-debian iw wirelesstools;
  };
}

