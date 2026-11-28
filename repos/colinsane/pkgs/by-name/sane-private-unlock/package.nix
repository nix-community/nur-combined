{
  coreutils,
  static-nix-shell,
  systemdMinimal,
}:
static-nix-shell.mkBash {
  pname = "sane-private-unlock";
  srcRoot = ./.;
  packages = {
    inherit
      coreutils
      systemdMinimal
      ;
  };
}
