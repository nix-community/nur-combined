{
  rtl8723cs-wowlan,
  static-nix-shell,
  util-linux,
}:
static-nix-shell.mkPython3 {
  # name is `sxmo_suspend.sh` because that's the binary this intends to replace
  pname = "sxmo_suspend.sh";
  srcRoot = ./.;
  pkgs = {
    inherit
      rtl8723cs-wowlan
      util-linux
      ;
  };
  extraMakeWrapperArgs = [ "--add-flag" "--verbose" ];
}


