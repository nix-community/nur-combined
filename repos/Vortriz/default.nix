{
    pkgs ? import <nixpkgs> { },
}:
(pkgs.lib.packagesFromDirectoryRecursive {
    inherit (pkgs) callPackage;
    directory = ./pkgs/by-name;
})
// (pkgs.lib.packagesFromDirectoryRecursive {
    callPackage = pkgs.lib.callPackageWith (pkgs // { inherit (pkgs.yaziPlugins) mkYaziPlugin; });
    directory = ./pkgs/yaziPlugins;
})
