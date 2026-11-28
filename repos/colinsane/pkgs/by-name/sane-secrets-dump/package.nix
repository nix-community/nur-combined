{
  gnugrep,
  oath-toolkit,
  sops,
  static-nix-shell,
}:
static-nix-shell.mkBash {
  pname = "sane-secrets-dump";
  srcRoot = ./.;
  packages = {
    inherit
      gnugrep
      sops
      oath-toolkit
      ;
  };
}
