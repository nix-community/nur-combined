{
  writeTextFile,
  callPackage,
  lib,
  newScope,
  packages,
  ...
}: let
  constants = import ./constants.nix;

  scopes = builtins.filter (v: v != null) (lib.unique (lib.mapAttrsToList (k: v:
    if lib.hasInfix "--" k
    then builtins.head (lib.splitString "--" k)
    else null)
  packages));

  packageSets = lib.genAttrs scopes (scope: lib.filterAttrs (k: v: lib.hasPrefix "${scope}--" k) packages);
  # Also filter out _meta helper package
  uncategorizedPackages = lib.filterAttrs (k: v: !lib.hasInfix "--" k && k != "_meta") packages;

  packageList = scopedPackages:
    builtins.map
    (v: let
      tags =
        lib.optional v.broken "Broken"
        # Golang packages set a lot of architectures
        # ++ builtins.map (v: "Arch: ${v}") v.platforms
        ;
    in "| ${lib.concatMapStringsSep " " (v: "`${v}`") tags} | `${v.path}` | ${
      if v.url != null
      then "[${v.pname}](${v.url})"
      else v.pname
    } | ${v.version} | ${v.description} |")
    (lib.mapAttrsToList
      (n: v: {
        path = n;
        pname = v.pname or v.name or n;
        version = v.version or "";
        description = v.meta.description or "";
        broken = v.meta.broken or false;
        platforms = v.meta.platforms or [];
        url = v.meta.homepage or null;
      })
      scopedPackages);

  packageSetOutput = scope: scopedPackages: let
    list = packageList scopedPackages;
  in ''
    <details>
    <summary>Package set: ${scope} (${builtins.toString (builtins.length list)} packages)</summary>

    | State | Path | Name | Version | Description |
    | ----- | ---- | ---- | ------- | ----------- |
    ${builtins.concatStringsSep "\n" list}
    </details>
  '';

  uncategorizedOutput =
    packageSetOutput
    "(Uncategorized)"
    uncategorizedPackages;

  packageSetsOutput = builtins.concatStringsSep "\n" (lib.mapAttrsToList packageSetOutput packageSets);
in ''
  # Lan Tian's NUR Packages

  ![Build and populate cache](https://github.com/xddxdd/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

  [![Cachix Cache](https://img.shields.io/badge/cachix-xddxdd-blue.svg)](https://xddxdd.cachix.org)

  [![built with garnix](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Fgarnix.io%2Fapi%2Fbadges%2Fxddxdd%2Fnur-packages)](https://garnix.io)

  ## IMPORTANT UPDATE 2024-02-24

  The packages in this repository has been reorganized into a flat structure. If you are using packages in a category, please replace the dots `.` in the package path with double minus signs `--`.

  For example: `pkgs.lantianCustomized.nginx` -> `pkgs."lantianCustomized--nginx"`

  If you are only using uncategorized packages, you are not affected.

  ## Maintenance and Backwards Compatibility

  A small number of packages in this NUR are customized for my own use. These packages reside in `lantianCustomized`, `lantianLinuxXanmod` and `lantianPersonal` categories. I do not ensure that they stay backwards compatible or functionally stable, nor do I accept any requests to tailor them for public use.

  Packages in all other categories are for public use. I will try my best to minimize changes/customizations on them, and accept issues and pull requests for them.

  ## How to use

  ```nix
  # flake.nix
  {
    inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
      flake-utils.url = "github:numtide/flake-utils";
      nur-xddxdd = {
        url = "github:xddxdd/nur-packages";
        inputs.flake-utils.follows = "flake-utils";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };

    outputs = { self, nixpkgs, ... }@inputs: {
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # Add packages from this repo
          inputs.nur-xddxdd.nixosModules.setupOverlay

          # Setup QEMU userspace emulation that works with Docker
          inputs.nur-xddxdd.nixosModules.qemu-user-static-binfmt

          # Binary cache (optional)
          ({ ... }: {
            nix.settings.substituters = [ "${constants.url}" ];
            nix.settings.trusted-public-keys = [ "${constants.publicKey}" ];
          })
        ];
      };
    };
  }
  ```

  ## Binary Cache

  This NUR has a binary cache. Use the following settings to access it:

  ```nix
  {
    nix.settings.substituters = [ "${constants.url}" ];
    nix.settings.trusted-public-keys = [ "${constants.publicKey}" ];
  }
  ```

  Or, use variables from this repository in case I change them:

  ```nix
  {
    nix.settings.substituters = [ nur.repos.xddxdd._meta.url ];
    nix.settings.trusted-public-keys = [ nur.repos.xddxdd._meta.publicKey ];
  }
  ```

  ## Packages

  ${uncategorizedOutput}

  ${packageSetsOutput}
''
