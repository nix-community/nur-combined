{ static-nix-shell
, hostname-debian
, iw
, wirelesstools
}:

static-nix-shell.mkPython3Bin {
  pname = "rtl8723cs-wowlan";
  src = ./.;
  pkgs = {
    inherit hostname-debian iw wirelesstools;
  };
}

