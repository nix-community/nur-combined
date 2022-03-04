{ pkgs }: import ./pkgs { inherit pkgs; } // {
  overlays.all = final: prev: import ./pkgs { pkgs = prev; };
  modules = import ./modules;
}
