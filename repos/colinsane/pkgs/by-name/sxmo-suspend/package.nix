{
  rtl8723cs-wowlan,
  static-nix-shell,
  util-linux,
}:
static-nix-shell.mkPython3 {
  pname = "sxmo-suspend";
  srcRoot = ./.;
  packages = {
    inherit
      rtl8723cs-wowlan
      util-linux
      ;
  };
  extraMakeWrapperArgs = [
    "--add-flag"
    "--verbose"
  ];

  # `sxmo_suspend.sh` because that's the binary this intends to replace.
  # static-nix-shell will do the rename for us
  meta.mainProgram = "sxmo_suspend.sh";
}
