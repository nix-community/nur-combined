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
    # zhyiheihei's NUR Packages

    ![Build and populate cache](https://github.com/zhyiheihei/zhyi-packages/workflows/Build%20and%20populate%20cache/badge.svg)

    ## About

    This repository follows
    [xddxdd/nur-packages](https://github.com/xddxdd/nur-packages) as its
    upstream reference for project structure and workflows, and supplements
    personal packages that are not natively available in nixpkgs.

    Packages already provided by nixpkgs (such as seerr, freshrss, halo,
    home-assistant, linkwarden, memos and metacubexd) are intentionally not
    duplicated here.

    ## Binary Cache

    Build artifacts are cached in the Attic binary cache:

    ```nix
    {
      nix.settings.substituters = [ "${_meta.atticUrl}" ];
      nix.settings.trusted-public-keys = [ "${_meta.atticPublicKey}" ];
    }
    ```

    ## How to use

    ```nix
    # flake.nix
    {
      inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        zhyi-packages = {
          url = "github:zhyiheihei/zhyi-packages";
          inputs.nixpkgs.follows = "nixpkgs";
        };
      };

      outputs = { self, nixpkgs, ... }@inputs: {
        nixosConfigurations.default = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            inputs.zhyi-packages.nixosModules.setupOverlay
          ];
        };
      };
    }
    ```

    ## Packages

    ${uncategorizedOutput}

    ${packageSetsOutput}
  '';
  meta = {
    maintainers = [
      {
        github = "zhyiheihei";
        name = "zhyiheihei";
      }
    ];
    description = "README.md for zhyiheihei's NUR Repo";
    homepage = "https://github.com/zhyiheihei/zhyi-packages";
    license = lib.licenses.unlicense;
  };
}
