{
  curl,
  modemmanager-split,
  python3,
  static-nix-shell,
}:
static-nix-shell.mkPython3 {
  pname = "eg25-control";
  srcRoot = ./.;
  pkgs = {
    inherit curl;
    "modemmanager-split.mmcli" = modemmanager-split.mmcli;
    "python3.pkgs.libgpiod" = python3.pkgs.libgpiod;
  };
}
