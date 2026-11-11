{
    description = "My pkgs";

    outputs =
        { self, ... }@args:
        let
            inputs = (import ./.tack) { overrides = args.tackOverrides or { }; };

            # i don't understand how this cursed algorithm works, but it works
            # (stripped form of Howard Hinnant's civil-from-days algorithm)
            timestampToDate =
                ts:
                let
                    z = (ts / 86400) + 719468;
                    era = (if z >= 0 then z else z - 146096) / 146097;
                    doe = z - era * 146097;
                    yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365;
                    y = yoe + era * 400;
                    doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
                    mp = (5 * doy + 2) / 153;
                    d = doy - (153 * mp + 2) / 5 + 1;
                    m = mp + (if mp < 10 then 3 else -9);
                    year = y + (if m <= 2 then 1 else 0);

                    pad = n: if n < 10 then "0${toString n}" else toString n;
                in
                "${toString year}-${pad m}-${pad d}";
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

                    base = pkgs // {
                        inherit inputs timestampToDate;
                    };
                    callPackage = lib.callPackageWith base;
                    callYaziPlugin = lib.callPackageWith (base // { inherit (pkgs.yaziPlugins) mkYaziPlugin; });
                    callZoteroAddon = lib.callPackageWith (base // { inherit mkZoteroAddon; });
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
                            fonts = packagesFromDirectoryRecursive {
                                inherit callPackage;
                                directory = ./pkgs/fonts;
                            };
                        }
                        // {
                            yaziPlugins = packagesFromDirectoryRecursive {
                                callPackage = callYaziPlugin;
                                directory = ./pkgs/yaziPlugins;
                            };
                        }
                        // {
                            zoteroAddons = packagesFromDirectoryRecursive {
                                callPackage = callZoteroAddon;
                                directory = ./pkgs/zoteroAddons;
                            };
                        };
                };

            flake = {
                overlays.default =
                    final: prev:
                    (prev.lib.packagesFromDirectoryRecursive {
                        callPackage = prev.lib.callPackageWith (final // { inherit inputs timestampToDate; });
                        directory = ./pkgs/by-name;
                    });

                homeModules = import ./modules/home-manager;
            };
        };

    nixConfig = {
        extra-substituters = [ "https://cache.manic.systems" ];
        extra-trusted-public-keys = [
            "cache.manic.systems-1:s6OZanN8Us8vRi0jVivP3qlMn0cYHBjBALKrNe5nH8s="
        ];
    };
}
