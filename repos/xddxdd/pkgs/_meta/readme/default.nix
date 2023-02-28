{
  writeTextFile,
  lib,
  _meta,
  newScope,
  packages,
  ...
}: let
  nurPackages =
    builtins.removeAttrs
    (lib.makeScope newScope packages)
    [
      "newScope"
      "callPackage"
      "overrideScope"
      "overrideScope'"
      "packages"
    ];

  shouldRecurseForDerivations = p: lib.isAttrs p && p.recurseForDerivations or false;

  packageTraverse = prefix: packageSet:
    lib.mapAttrsToList
    (n: v: let
      path =
        if prefix != ""
        then "${prefix}.${n}"
        else n;
    in
      if lib.hasPrefix "_" n
      then []
      else if shouldRecurseForDerivations v
      then packageTraverse path v
      else if lib.isDerivation v
      then {
        inherit path;
        pname = v.pname or n;
        version = v.version or "";
        description = v.meta.description or "";
        broken = v.meta.broken or false;
        platforms = v.meta.platforms or [];
        url = v.meta.homepage or null;
      }
      else [])
    packageSet;

  packageSets = lib.filterAttrs (n: v: !(lib.hasPrefix "_" n) && (shouldRecurseForDerivations v)) nurPackages;

  packageList = prefix: ps:
    builtins.map
    (v: let
      tags =
        lib.optional v.broken "Broken"
        # Golang packages set a lot of architectures
        # ++ builtins.map (v: "Arch: ${v}") v.platforms
        ;
    in "| ${lib.concatMapStringsSep " " (v: "`${v}`") tags} | ${
      if v.url != null
      then "[${v.pname}](${v.url})"
      else v.pname
    } | ${v.version} | `${v.path}` | ${v.description} |")
    (lib.flatten (packageTraverse prefix ps));

  packageSetOutput = name: path: v: let
    list = packageList path v;
  in ''
    <details>
    <summary>Package set: ${name} (${builtins.toString (builtins.length list)} packages)</summary>

    | State | Name | Version | Path | Description |
    | ----- | ---- | ------- | ---- | ----------- |
    ${builtins.concatStringsSep "\n" list}
    </details>
  '';

  uncategorizedOutput = packageSetOutput "(Uncategorized)" "" (lib.filterAttrs (n: lib.isDerivation) nurPackages);

  packageSetsOutput = builtins.concatStringsSep "\n" (lib.mapAttrsToList (n: v: packageSetOutput n n v) packageSets);
in
  writeTextFile {
    name = "";
    text = ''
      # Lan Tian's NUR Packages

      ![Build and populate cache](https://github.com/xddxdd/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

      [![Cachix Cache](https://img.shields.io/badge/cachix-xddxdd-blue.svg)](https://xddxdd.cachix.org)

      ## Warning

      This NUR contains packages customized for my own use. These packages reside in `lantianCustomized`, `lantianLinuxXanmod` and `lantianPersonal` categories. I do not ensure that they stay backwards compatible or functionally stable, nor do I accept any requests to tailor them for public use.

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
                nix.settings.substituters = [ "${_meta.url}" ];
                nix.settings.trusted-public-keys = [ "${_meta.publicKey}" ];
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
        nix.settings.substituters = [ "${_meta.url}" ];
        nix.settings.trusted-public-keys = [ "${_meta.publicKey}" ];
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
    '';
    meta = {
      description = "README.md for Lan Tian's NUR Repo";
      homepage = "https://github.com/xddxdd/nur-packages";
      license = lib.licenses.unlicense;
    };
  }
