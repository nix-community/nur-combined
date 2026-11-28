{
  coreutils-full,
  gnused,
  static-nix-shell,
}:
static-nix-shell.mkYsh {
  pname = "sane-deadlines";
  srcRoot = ./.;
  packages = {
    inherit
      coreutils-full
      gnused
      ;
  };
}
