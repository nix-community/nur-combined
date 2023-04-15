{inputs, ...}: {
  imports = [
    inputs.mission-control.flakeModule
  ];

  perSystem = {
    self',
    config,
    pkgs,
    ...
  }: {
    mission-control.scripts = {
      spdx = {
        description = "Conform with REUSE";
        exec = pkgs.reuse;
        category = "Legal";
      };
      fmt = {
        description = "Format the source tree";
        exec = config.treefmt.build.wrapper;
        category = "Development";
      };
      pkg = {
        description = "Update nvfetcher pkgs";
        exec = ''
          ${pkgs.nvfetcher}/bin/nvfetcher \
            -c "$FLAKE_ROOT/scrolls/packages/pkgs/_sources/nvfetcher.toml" \
            -o "$FLAKE_ROOT/scrolls/packages/pkgs/_sources"
        '';
        category = "Development";
      };
    };

    devShells.default = pkgs.mkShell {
      inputsFrom = [
        config.flake-root.devShell
        config.mission-control.devShell
      ];
    };
  };
}
