{ pkgs }: import ./pkgs { inherit pkgs; } // {
  overlays = import ./overlays;
  modules = import ./modules;
}
