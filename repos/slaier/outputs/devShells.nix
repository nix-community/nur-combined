{ super, ... }:
super.lib.eachDefaultSystems (pkgs: {
  default = with pkgs; mkShell {
    packages = [
      colmena
      just
    ];
  };

  update = with pkgs; mkShell {
    packages = [
      just
      nix-prefetch-docker
    ];
  };
})
