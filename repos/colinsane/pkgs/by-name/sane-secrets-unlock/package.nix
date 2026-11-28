{
  coreutils-full,
  openssh,
  ssh-to-age,
  static-nix-shell,
}:
static-nix-shell.mkBash {
  pname = "sane-secrets-unlock";
  srcRoot = ./.;
  packages = {
    inherit
      coreutils-full
      openssh
      ssh-to-age
      ;
  };
}
