{ super, ... }:
super.lib.eachDefaultSystems (pkgs: with pkgs; {
  default = mkShell {
    packages = [
      just
      nixos-rebuild
      sops
    ];
  };

  ci = mkShell {
    packages = [
      nixos-rebuild
    ];
  };

  update = mkShell {
    packages = [
      just
      nix-prefetch-docker
    ];
  };
})
