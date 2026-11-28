{
  static-nix-shell,
}:
static-nix-shell.mkPython3 {
  pname = "sane-reclaim-boot-space";
  srcRoot = ./.;
}
