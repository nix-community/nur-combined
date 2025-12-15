{
  writeTextFile,
  callPackage,
  pkgs,
  lib,
  inputs,
  _meta,
  _packages,
}:
let
  inherit (callPackage ../../../helpers/flatten-pkgs.nix { })
    isDerivation
    isHiddenName
    isTargetPlatform'
    flattenPkgs'
    ;

  packageSets = lib.filterAttrs (
    n: v: v != null && (builtins.tryEval v).success && !(isHiddenName n) && !(lib.isDerivation v)
  ) _packages;

  deprecatedPackages =
    let
      inherit
        (import ../../../helpers/group.nix {
          inherit pkgs lib inputs;
          mode = null;
        })
        createCallGroupDeps
        ;
      callGroupDeps = createCallGroupDeps _packages callPackage;
    in
    builtins.attrNames (import ../../deprecated callGroupDeps);

  allPlatforms = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  packageList =
    prefix: ps:
    let
      packageToMeta = n: v: rec {
        path = n;
        pname = v.pname or v.name or n;
        version = v.version or "";
        description = v.meta.description or "";
        broken = v.meta.broken or false;
        platforms = v.meta.platforms or [ ];
        url = v.meta.homepage or null;
        deprecated = builtins.elem n deprecatedPackages;

        supportAllPlatforms = builtins.foldl' (a: b: a && b) true (
          builtins.map (p: isTargetPlatform' p v) allPlatforms
        );
        platformTags = lib.flatten (
          builtins.map (p: if isTargetPlatform' p v then [ p ] else [ ]) allPlatforms
        );
        tags =
          (lib.optional broken "Broken")
          ++ (lib.optional deprecated "Deprecated")
          ++ (lib.optionals (!supportAllPlatforms) platformTags);
      };
      metaToString =
        v:
        "| ${lib.concatMapStringsSep " " (v: "`${v}`") v.tags} | `${v.path}` | ${
          if v.url != null then "[${v.pname}](${v.url})" else v.pname
        } | ${v.version} | ${v.description} |";
      isBadPackage = p: builtins.elem "Deprecated" p.tags || builtins.elem "Broken" p.tags;

      packageList = lib.mapAttrsToList packageToMeta (flattenPkgs' prefix "." ps);
      goodPackageList = builtins.filter (p: !isBadPackage p) packageList;
      badPackageList = builtins.filter isBadPackage packageList;
    in
    builtins.map metaToString (goodPackageList ++ badPackageList);

  packageSetOutput =
    name: path: v:
    let
      list = packageList path v;
    in
    ''
      <details>
      <summary>Package set: ${name} (${builtins.toString (builtins.length list)} packages)</summary>

      | State | Path | Name | Version | Description |
      | ----- | ---- | ---- | ------- | ----------- |
      ${builtins.concatStringsSep "\n" list}
      </details>
    '';

  uncategorizedOutput = packageSetOutput "(Uncategorized)" "" (
    lib.filterAttrs (n: v: (builtins.tryEval v).success && isDerivation v) _packages
  );

  packageSetsOutput = builtins.concatStringsSep "\n" (
    lib.mapAttrsToList (n: v: packageSetOutput n n v) packageSets
  );
in
writeTextFile {
  name = "README.md";
  text = ''
    # Lan Tian's NUR Packages

    ![Build and populate cache](https://github.com/xddxdd/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

    [![built with garnix](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Fgarnix.io%2Fapi%2Fbadges%2Fxddxdd%2Fnur-packages)](https://garnix.io)

    ## Warning

    This NUR contains packages customized for my own use. These packages reside categories starting with `lantian`. I do not ensure that they stay backwards compatible or functionally stable, nor do I accept any requests to tailor them for public use.

    Packages in all other categories are for public use. I will try my best to minimize changes/customizations on them, and accept issues and pull requests for them.

    ## How to use

    ```nix
    # flake.nix
    {
      inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        nur-xddxdd = {
          url = "github:xddxdd/nur-packages";
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

            # Binary cache (optional, choose any one, or see guide below)
            inputs.nur-xddxdd.nixosModules.nix-cache-attic
            inputs.nur-xddxdd.nixosModules.nix-cache-garnix
          ];
        };
      };
    }
    ```

    ## Binary Cache

    This NUR automatically builds and pushes build artifacts to several binary caches. You can use any one of them to speed up your build.

    ### Self-hosted (Attic)

    ```nix
    {
      nix.settings.substituters = [ "${_meta.atticUrl}" ];
      nix.settings.trusted-public-keys = [ "${_meta.atticPublicKey}" ];
    }
    ```

    Or, use variables from this repository in case I change them:

    ```nix
    {
      nix.settings.substituters = [ nur.repos.xddxdd._meta.atticUrl ];
      nix.settings.trusted-public-keys = [ nur.repos.xddxdd._meta.atticPublicKey ];
    }
    ```

    ### Garnix.io

    ```nix
    {
      nix.settings.substituters = [ "${_meta.garnixUrl}" ];
      nix.settings.trusted-public-keys = [ "${_meta.garnixPublicKey}" ];
    }
    ```

    Or, use variables from this repository in case I change them:

    ```nix
    {
      nix.settings.substituters = [ nur.repos.xddxdd._meta.garnixUrl ];
      nix.settings.trusted-public-keys = [ nur.repos.xddxdd._meta.garnixPublicKey ];
    }
    ```

    ## Packages

    ${uncategorizedOutput}

    ${packageSetsOutput}
  '';
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "README.md for Lan Tian's NUR Repo";
    homepage = "https://github.com/xddxdd/nur-packages";
    license = lib.licenses.unlicense;
  };
}
