# SPDX-FileCopyrightText: 2023 Lin Yinfeng <lin.yinfeng@outlook.com>
# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ inputs, ... }: {
  imports = [
    inputs.pre-commit-hooks-nix.flakeModule
    inputs.flat-flake.flakeModules.flatFlake
  ];

  perSystem.pre-commit = {
    check.enable = true;

    settings = {
      excludes = [
        "flake.lock"
        "secrets/.*/[^/]+\.(yaml|json|env|ini)$"
        "nix/pkgs/_sources/generated.(json|nix)$"
      ];

      hooks = {
        nil.enable = true;
        shfmt.enable = true;
        prettier.enable = true;
        shellcheck.enable = true;
        commitizen.enable = true;
        nixpkgs-fmt.enable = true;
      };
    };
  };
}
