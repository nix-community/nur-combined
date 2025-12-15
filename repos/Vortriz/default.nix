{
    pkgs ? import <nixpkgs> { },
}:
let
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

in
(pkgs.lib.packagesFromDirectoryRecursive {
    inherit (pkgs) callPackage;
    directory = ./pkgs/by-name;
})
// (pkgs.lib.packagesFromDirectoryRecursive {
    inherit (pkgs) callPackage;
    directory = ./pkgs/espansoPackages;
})
// (pkgs.lib.packagesFromDirectoryRecursive {
    callPackage = pkgs.lib.callPackageWith (pkgs // { inherit (pkgs.yaziPlugins) mkYaziPlugin; });
    directory = ./pkgs/yaziPlugins;
})
// (pkgs.lib.packagesFromDirectoryRecursive {
    callPackage = pkgs.lib.callPackageWith (pkgs // { inherit mkZoteroAddon; });
    directory = ./pkgs/zoteroAddons;
})
