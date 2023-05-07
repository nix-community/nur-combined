{ super, ... }:
super.lib.eachDefaultSystems (pkgs: {
  default = with pkgs; mkShell {
    packages = [
      colmena
      just
      parallel
    ];
  };
})
