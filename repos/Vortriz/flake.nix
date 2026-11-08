{
    description = "My pkgs";

    outputs =
        { self, ... }@args:
        let
            inputs = (import ./.tack) { overrides = args.tackOverrides or { }; };
            date = builtins.concatStringsSep "-" (builtins.match "(.{4})(.{2})(.{2}).*" self.lastModifiedDate);
        in
        inputs.flake-parts.lib.mkFlake { inherit inputs self; } {
            systems = import inputs.systems;

            imports = [
                ./devshell.nix
                ./treefmt.nix
            ];

            perSystem =
                {
                    lib,
                    pkgs,
                    system,
                    ...
                }:
                let
                    inherit (lib.filesystem) packagesFromDirectoryRecursive;
                    inherit (lib.attrsets) recurseIntoAttrs;

                    mkZoteroAddon =
                        {
                            stdenvNoCC ? pkgs.stdenvNoCC,
                            pname,
                            version,
                            src,
                            addonId,
                            meta ? { },
                            ...
                        }:
                        stdenvNoCC.mkDerivation {
                            inherit pname version src;

                            preferLocalBuild = true;
                            allowSubstitutes = true;

                            buildCommand = ''
                                dst="$out/share/zotero/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
                                mkdir -p "$dst"
                                install -v -m644 "$src" "$dst/${addonId}.xpi"
                            '';

                            inherit meta;
                        };

                    callPackage = lib.callPackageWith (pkgs // { inherit inputs date; });
                    callYaziPlugin = lib.callPackageWith (
                        pkgs
                        // {
                            inherit inputs date;
                            inherit (pkgs.yaziPlugins) mkYaziPlugin;
                        }
                    );
                    callZoteroAddon = lib.callPackageWith (pkgs // { inherit inputs date mkZoteroAddon; });
                in
                {
                    _module.args.pkgs = import inputs.nixpkgs {
                        inherit system;
                        config.allowUnfree = true;
                    };

                    legacyPackages =
                        packagesFromDirectoryRecursive {
                            inherit callPackage;
                            directory = ./pkgs/by-name;
                        }
                        // {
                            espansoPackages = packagesFromDirectoryRecursive {
                                inherit callPackage;
                                directory = ./pkgs/espansoPackages;
                            };
                        }
                        // {
                            fonts = recurseIntoAttrs (packagesFromDirectoryRecursive {
                                inherit callPackage;
                                directory = ./pkgs/fonts;
                            });
                        }
                        // {
                            yaziPlugins = recurseIntoAttrs (packagesFromDirectoryRecursive {
                                callPackage = callYaziPlugin;
                                directory = ./pkgs/yaziPlugins;
                            });
                        }
                        // {
                            zoteroAddons = recurseIntoAttrs (packagesFromDirectoryRecursive {
                                callPackage = callZoteroAddon;
                                directory = ./pkgs/zoteroAddons;
                            });
                        };
                };

            flake = {
                overlays.default =
                    final: prev:
                    (prev.lib.packagesFromDirectoryRecursive {
                        callPackage = prev.lib.callPackageWith (final // { inherit inputs date; });
                        directory = ./pkgs/by-name;
                    });

                homeModules = import ./modules/home-manager;
            };
        };
}
