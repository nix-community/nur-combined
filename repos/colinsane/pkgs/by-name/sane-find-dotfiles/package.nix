{
  findutils,
  static-nix-shell,
}:
static-nix-shell.mkBash {
  pname = "sane-find-dotfiles";
  srcRoot = ./.;
  packages = {
    inherit findutils;
  };
}
