{
  static-nix-shell,
}:
static-nix-shell.mkPython3 {
  pname = "make-docset-index";
  srcRoot = ./.;
}
