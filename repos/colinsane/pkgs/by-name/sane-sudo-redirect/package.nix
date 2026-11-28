{
  coreutils-full,
  static-nix-shell,
}:
static-nix-shell.mkBash {
  pname = "sane-sudo-redirect";
  srcRoot = ./.;
  packages = {
    inherit coreutils-full;
  };
}
