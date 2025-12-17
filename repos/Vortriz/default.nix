{
    pkgs ? import <nixpkgs> { },
}:
let
    inherit (pkgs) lib;
    inherit (lib) recurseIntoAttrs packagesFromDirectoryRecursive;
    inherit (pkgs) callPackage;

    lib' = import ./lib.nix pkgs;
    inherit (lib') callYaziPlugin callZoteroAddon;

in
(packagesFromDirectoryRecursive {
    inherit callPackage;
    directory = ./pkgs/by-name;
})
// (packagesFromDirectoryRecursive {
    inherit callPackage;
    directory = ./pkgs/deps;
})
// {
    espansoPackages = pkgs.lib.packagesFromDirectoryRecursive {
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
}
