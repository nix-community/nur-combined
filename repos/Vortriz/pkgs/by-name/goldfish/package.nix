{
    lib,
    rustPlatform,
    fetchFromGitHub,
}:
rustPlatform.buildRustPackage {
    pname = "goldfish";
    version = "unstable-2026-07-07";

    src = fetchFromGitHub {
        owner = "sameoldlab";
        repo = "goldfish";
        rev = "ac4a81a62931a4d855da4c5cbd95a84b11602b02";
        hash = "sha256-OLwD7695swlP27Ir+xKMU7FvGtK604GhdBwfzJugarY=";
    };

    cargoLock.lockFile = ./Cargo.lock;

    meta = {
        description = "goldfish (`gf`) is a IPC file finder.";
        homepage = "https://github.com/sameoldlab/goldfish";
        license = lib.licenses.mpl20;
        mainProgram = "goldfish";
    };
}
