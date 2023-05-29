{ super, ... }:
super.lib.eachDefaultSystems (pkgs: with pkgs; {
  default = mkShell {
    packages = [
      colmena
      just
      sops
    ];
  };

  ci = mkShell {
    packages = [
      colmena
    ];
  };

  update = mkShell {
    packages = [
      just
      nix-prefetch-docker
    ];
  };
})
