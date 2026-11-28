{
  coreutils-full,
  ifuse,
  rsync,
  static-nix-shell,
}:
static-nix-shell.mkZsh {
  pname = "sane-sync-from-iphone";
  srcRoot = ./.;
  packages = {
    inherit
      coreutils-full
      ifuse
      rsync
      ;
  };
}
