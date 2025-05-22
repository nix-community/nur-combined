{pkgs ? import <nixpkgs> {}}: {
  lib = import ./lib {inherit pkgs;};
  modules = import ./modules;
  overlays = import ./overlays;

  sketch = pkgs.callPackage ./pkgs/sketch {};
  reduce-algebra = pkgs.callPackage ./pkgs/reduce-algebra {};
  AutoLifter = pkgs.callPackage ./pkgs/AutoLifter {};
  parsynt = pkgs.callPackage ./pkgs/parsynt {};
  Synduce = pkgs.callPackage ./pkgs/Synduce {};
}
