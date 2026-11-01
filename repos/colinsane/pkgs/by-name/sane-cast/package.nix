{
  go2tv,
  sblast,
  static-nix-shell,
}:
static-nix-shell.mkPython3 {
  pname = "sane-cast";
  packages = {
    inherit
      go2tv
      sblast
      ;
  };
  srcRoot = ./.;
}

