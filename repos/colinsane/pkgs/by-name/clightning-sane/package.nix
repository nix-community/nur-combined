{
  pyln-client,
  static-nix-shell,
}:
static-nix-shell.mkPython3 {
  pname = "clightning-sane";
  srcRoot = ./.;
  packages = {
    inherit pyln-client;
  };
}
