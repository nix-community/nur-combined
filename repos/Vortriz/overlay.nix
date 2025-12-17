let
    lib' = import ./lib.nix;
in
{
    default =
        final: prev:
        (prev.lib.packagesFromDirectoryRecursive {
            callPackage = prev.lib.callPackageWith final;
            directory = ./pkgs/by-name;
        });

    espansoPackages = final: prev: {
        espansoPackages = prev.lib.packagesFromDirectoryRecursive {
            callPackage = prev.lib.callPackageWith final;
            directory = ./pkgs/espansoPackages;
        };
    };

    fonts = final: prev: {
        fonts = prev.lib.packagesFromDirectoryRecursive {
            callPackage = prev.lib.callPackageWith final;
            directory = ./pkgs/fonts;
        };
    };

    yaziPlugins = _final: prev: {
        yaziPlugins =
            prev.yaziPlugins
            // (prev.lib.packagesFromDirectoryRecursive {
                callPackage = (lib' prev).callYaziPlugin;
                directory = ./pkgs/yaziPlugins;
            });
    };

    zoteroAddons = _final: prev: {
        zoteroAddons = prev.lib.packagesFromDirectoryRecursive {
            callPackage = (lib' prev).callZoteroAddon;
            directory = ./pkgs/zoteroAddons;
        };
    };
}
