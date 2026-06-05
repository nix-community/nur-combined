# helper to deal with blast's interactive CLI
{
  sblast,
  static-nix-shell,
}:
static-nix-shell.mkPython3 {
  pname = "blast-to-default";
  pkgs = {
    inherit sblast;
  };
  srcRoot = ./.;
  doInstallCheck = false;  # TODO: fix parser to support --help
}
