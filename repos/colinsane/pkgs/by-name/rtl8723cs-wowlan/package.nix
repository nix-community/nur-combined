{ static-nix-shell
, hostname-debian
, iw
, wirelesstools
}:

static-nix-shell.mkPython3 {
  pname = "rtl8723cs-wowlan";
  srcRoot = ./.;
  pkgs = {
    inherit hostname-debian iw wirelesstools;
  };
}

