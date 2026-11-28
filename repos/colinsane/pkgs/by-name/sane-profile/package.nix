{
  flamegraph,
  perf,
  static-nix-shell,
}:
static-nix-shell.mkYsh {
  pname = "sane-profile";
  srcRoot = ./.;
  packages = {
    inherit
      flamegraph
      perf
      ;
  };
}
