{
  pyln-client,
  static-nix-shell,
}:
static-nix-shell.mkPython3 {
  pname = "clightning-sane";
  srcRoot = ./.;
  pkgs = {
    inherit pyln-client;
  };
}
