{inputs, ...}: {
  imports = [
    inputs.flake-root.flakeModule
    inputs.treefmt-nix.flakeModule
  ];

  perSystem = {
    self',
    config,
    pkgs,
    ...
  }: {
    treefmt.config = {
      inherit (config.flake-root) projectRootFile;
      package = pkgs.treefmt;
      flakeFormatter = false;
      programs = {
        shfmt.enable = true;
        prettier.enable = true;
        alejandra.enable = true;
      };
    };
  };
}
