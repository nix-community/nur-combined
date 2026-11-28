{
  static-nix-shell,
  util-linux,
}:
static-nix-shell.mkBash {
  pname = "sane-private-do";
  srcRoot = ./.;
  packages = {
    inherit util-linux;
  };
}
