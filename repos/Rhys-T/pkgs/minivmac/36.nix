{ callPackage, ... }@args: let
    version = "36.04";
    hash = "sha256-m3NDzsh3Ixd6ID5prTuvIPSbTo8DYZ42bEvycFFn36Q=";
    options = callPackage ./options.nix {};
    minivmac = callPackage ./generic.nix (args // {
        inherit minivmac version options;
        src = callPackage ./fetch.nix {
            inherit version hash;
        };
    });
in minivmac
