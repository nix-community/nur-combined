{
  openssh,
  sane-secrets-dump,
  static-nix-shell,
}:
static-nix-shell.mkBash {
  pname = "sane-private-unlock-remote";
  srcRoot = ./.;
  packages = {
    inherit openssh;
    "sane-secrets-dump" = sane-secrets-dump;
  };
}
