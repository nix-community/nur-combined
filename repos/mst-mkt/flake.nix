{
  outputs =
    inputs:
    let
      forAllSystems = inputs.nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    in
    {
      packages = forAllSystems (
        system:
        let
          allPkgs = import ./. {
            pkgs = inputs.nixpkgs.legacyPackages.${system};
          };
        in
        inputs.nixpkgs.lib.filterAttrs (
          _: pkg: !(pkg ? meta.platforms) || builtins.elem system pkg.meta.platforms
        ) allPkgs
      );

      checks = inputs.self.packages;

      overlays.default = final: _prev: import ./. { pkgs = final; };

      homeModules.omniwm = import ./modules/omniwm.nix;

      formatter = forAllSystems (system: inputs.nixpkgs.legacyPackages.${system}.nixfmt-tree);
    };

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
  };
}
