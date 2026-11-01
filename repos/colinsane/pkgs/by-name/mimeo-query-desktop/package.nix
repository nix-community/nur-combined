{
  mimeo,
  static-nix-shell,
}: static-nix-shell.mkPython3 {
  pname = "mimeo-query-desktop";
  srcRoot = ./.;
  packages = {
    inherit mimeo;
  };
}
