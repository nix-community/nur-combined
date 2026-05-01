{
    lib,
    rustPlatform,
    fetchFromGitHub,
}:
rustPlatform.buildRustPackage {
    pname = "goldfish";
    version = "unstable-2026-04-30";

    src = fetchFromGitHub {
        owner = "sameoldlab";
        repo = "goldfish";
        rev = "84402bb43fdad781fea7d4374afb67a3cf6d77b6";
        hash = "sha256-5WlcO6ixbiyVf187Ae7i+JENbtS+1YWKm9h6IYVha1M=";
    };

    cargoLock.lockFile = ./Cargo.lock;

    meta = {
        description = "goldfish (`gf`) is a IPC file finder.";
        homepage = "https://github.com/sameoldlab/goldfish";
        license = lib.licenses.mpl20;
        mainProgram = "goldfish";
    };
}
