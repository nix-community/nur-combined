{ callPackage, ... }@args: let
    version = "37.03";
    hash = "sha256-X4QPpZQ9rm3LbA2B0deDgXlbid4e/qM+nYGdCmdtGsc=";
    options = callPackage ./options.nix {};
    minivmac = callPackage ./generic.nix (args // {
        inherit minivmac version options;
        src = callPackage ./fetch.nix {
            inherit version hash;
        };
    });
in minivmac
