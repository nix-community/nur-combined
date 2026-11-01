{
  coreutils,
  killall,
  playerctl,
  procps,
  sane-open,
  static-nix-shell,
  sway,
  util-linux,
  wireplumber,
}:
static-nix-shell.mkYsh {
  pname = "sane-input-handler";
  srcRoot = ./.;
  packages = {
    inherit coreutils killall playerctl procps sane-open sway util-linux wireplumber;
  };
}
