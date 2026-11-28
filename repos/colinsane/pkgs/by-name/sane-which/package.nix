{
  coreutils-full,
  file,
  gnugrep,
  static-nix-shell,
}:
static-nix-shell.mkBash {
  pname = "sane-which";
  srcRoot = ./.;
  packages = {
    inherit
      coreutils-full
      file
      gnugrep
      ;
  };
}
