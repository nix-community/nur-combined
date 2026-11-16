{
  coreutils,
  gnugrep,
  ruff,
  shfmt-sane,
  static-nix-shell,
}:
static-nix-shell.mkBash {
  pname = "treefmt-nix-shell";
  srcRoot = ./.;
  packages = {
    inherit
      coreutils
      gnugrep
      ruff
      shfmt-sane
      ;
  };
}
