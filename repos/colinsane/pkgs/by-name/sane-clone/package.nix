{
  coreutils,
  git,
  nix,
  static-nix-shell,
}:
static-nix-shell.mkBash {
  pname = "sane-clone";
  srcRoot = ./.;
  packages = {
    inherit
      coreutils
      git
      nix
      ;
  };
  doInstallCheck = false; # TODO: implement --help flag
}
