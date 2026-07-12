{
  writeTextFile,
  callPackage,
  lib,
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

        supportAllPlatforms = builtins.foldl' (a: b: a && b) true (
          builtins.map (p: isTargetPlatform' p v) allPlatforms
        );
        platformTags = lib.flatten (
          builtins.map (p: if isTargetPlatform' p v then [ p ] else [ ]) allPlatforms
        );
        tags = (lib.optional broken "Broken") ++ (lib.optionals (!supportAllPlatforms) platformTags);
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

            # Binary cache (optional, see guide below)
            inputs.nur-xddxdd.nixosModules.nix-cache-attic
          ];
        };
      };
    }
    ```

    ## Binary Cache

    This NUR automatically builds and pushes build artifacts to my binary cache. You can use it to speed up your build.

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
