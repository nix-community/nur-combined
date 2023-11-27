# SPDX-FileCopyrightText: 2023 Lin Yinfeng <lin.yinfeng@outlook.com>
# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ inputs, ... }: {
  imports = [
    inputs.flake-root.flakeModule
    inputs.treefmt-nix.flakeModule
  ];

  perSystem = { config, ... }: {
    formatter = config.treefmt.build.wrapper;

    treefmt = {
      inherit (config.flake-root) projectRootFile;

      settings.formatter.prettier = {
        excludes = [
          "secrets/**/*.{yaml,json,ini,env,txt}"
          "nix/pkgs/_sources/generated.{json,nix}"
        ];
      };

      programs = {
        shfmt.enable = true;
        prettier.enable = true;
        shellcheck.enable = true;
        nixpkgs-fmt.enable = true;
      };
    };
  };
}
