{ static-nix-shell }:
static-nix-shell.mkPython3 {
  # name is `sxmo_suspend.sh` because that's the binary this intends to replace
  pname = "sxmo_suspend.sh";
  srcRoot = ./.;
  pkgs = [ "rtl8723cs-wowlan" "util-linux" ];
  extraMakeWrapperArgs = [ "--add-flag" "--verbose" ];
}


