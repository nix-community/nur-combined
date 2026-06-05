{
  mimeo,
  static-nix-shell,
}: static-nix-shell.mkPython3 {
  pname = "mimeo-open-desktop";
  srcRoot = ./.;
  pkgs = {
    inherit mimeo;
  };
}
