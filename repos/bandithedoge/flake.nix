{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };
  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        flake-parts.flakeModules.easyOverlay
        flake-parts.flakeModules.partitions
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      partitions.dev = {
        extraInputsFlake = ./dev;
        module = { inputs, ... }: {
          imports = [
            inputs.treefmt-nix.flakeModule
            ./dev/perSystem.nix
          ];
        };
      };

      partitionedAttrs = {
        checks = "dev";
        devShells = "dev";
        treefmt = "dev";
        formatter = "dev";
      };

      perSystem =
        {
          pkgs,
          system,
          ...
        }:
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            config = {
              allowAliases = false;
              allowUnfree = true;
            };
          };

          legacyPackages =
            let
              lib = import ./lib.nix { inherit (pkgs) lib; };
              allPackages = lib.flattenTree (import ./all.nix { inherit pkgs; });

              isBuildable =
                pkg:
                (
                  (builtins.tryEval pkg).success
                  && !(
                    (if pkgs.lib.hasAttrByPath [ "meta" "broken" ] pkg then pkg.meta.broken else false)
                    || (if pkgs.lib.hasAttrByPath [ "meta" "insecure" ] pkg then pkg.meta.insecure else false)
                  )
                );
              isCacheable =
                pkg:
                isBuildable pkg
                && pkg.meta.license.free or true
                && !(pkg.preferLocalBuild or false)
                && !(pkgs.lib.any (prov: !prov.isSource) (pkg.meta.sourceProvenance or [ ]));

              buildable = pkgs.lib.filterAttrs (_: isBuildable) allPackages;
              cacheable = pkgs.lib.filterAttrs (_: isCacheable) allPackages;
              uncacheable = pkgs.lib.filterAttrs (
                x: _: !builtins.elem x (builtins.attrNames cacheable)
              ) buildable;
            in
            import ./default.nix { inherit pkgs; }
            // {
              _BUILDABLE = buildable;
              _CACHEABLE = cacheable;
              _UNCACHEABLE = uncacheable;
              _DUPES = import ./_dupes.nix { inherit pkgs; };

              _LIST = ''
                - ✔️ - cached
                - 🆗 - buildable
                - ❌ - broken

                | Name | Version | Description | License(s) |
                | ---- | ------- | ----------- | ---------- |
              ''
              + pkgs.lib.concatMapAttrsStringSep "\n" (
                name: value:
                let
                  name' =
                    let
                      path = "`${builtins.replaceStrings [ "/" ] [ "." ] name}`";
                      status =
                        if isCacheable value then
                          "✔️"
                        else if isBuildable value then
                          "🆗"
                        else
                          "❌";
                    in
                    if (pkgs.lib.hasAttrByPath [ "meta" "homepage" ] value) then
                      "${status} [${path}](${value.meta.homepage})"
                    else
                      path;

                  version' = pkgs.lib.optionalString (builtins.hasAttr "version" value) value.version;

                  value' = pkgs.lib.optionalString (pkgs.lib.hasAttrByPath [ "meta" "description" ] value) (
                    pkgs.lib.trim (builtins.elemAt (pkgs.lib.splitString "\n" value.meta.description) 0)
                  );

                  license' = pkgs.lib.optionalString (pkgs.lib.hasAttrByPath [ "meta" "license" ] value) (
                    let
                      license = value.meta.license;
                    in
                    if (builtins.isString license) then
                      license
                    else
                      (
                        let
                          fmt = l: if (builtins.hasAttr "url" l) then "[${l.fullName}](${l.url})" else l.fullName;
                        in
                        if (builtins.isList license) then (pkgs.lib.concatMapStringsSep ", " fmt license) else fmt license
                      )
                  );
                in
                "| ${name'} | ${version'} | ${value'} | ${license'} |"
              ) allPackages;

            };
        };
    };
  nixConfig = {
    extra-substituters = [ "https://bandithedoge.cachix.org" ];
    extra-trusted-public-keys = [
      "bandithedoge.cachix.org-1:ZtcHw1anyEa4t6H8m3o/ctYFrwYFPAwoENSvofamE6g="
    ];
  };
}
