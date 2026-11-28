{
  coreutils-full,
  findutils,
  sops,
  static-nix-shell,
}:
static-nix-shell.mkBash {
  pname = "sane-secrets-update-keys";
  srcRoot = ./.;
  packages = {
    inherit
      coreutils-full
      findutils
      sops
      ;
  };
}
