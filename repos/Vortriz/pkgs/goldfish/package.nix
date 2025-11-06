{
    sources,
    lib,
    rustPlatform,
}: let
    inherit (sources.goldfish) src pname date cargoLock;
in
    rustPlatform.buildRustPackage {
        inherit pname src;
        version = "unstable-${date}";

        cargoLock = cargoLock."Cargo.lock";

        meta = {
            description = "goldfish (`gf`) is a IPC file finder.";
            homepage = "https://github.com/sameoldlab/goldfish";
            license = lib.licenses.mpl20;
            mainProgram = "goldfish";
        };
    }
