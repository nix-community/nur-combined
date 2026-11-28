{
  dconf,
  libsecret,
  procps,
  static-nix-shell,
  systemdMinimal,
}:
static-nix-shell.mkBash {
  pname = "sane-wipe";
  srcRoot = ./.;
  packages = {
    inherit
      dconf
      libsecret
      procps
      systemdMinimal
      ;
  };
}
