{
  nix,
  static-nix-shell,
}:
static-nix-shell.mkBash {
  pname = "sane-reclaim-disk-space";
  srcRoot = ./.;
  packages = { inherit nix; };
}
