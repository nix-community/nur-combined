{
    lib,
    rustPlatform,
    fetchFromGitHub,
}:
rustPlatform.buildRustPackage {
    pname = "goldfish";
    version = "unstable-2025-11-02";

    src = fetchFromGitHub {
        owner = "sameoldlab";
        repo = "goldfish";
        rev = "4eb6d6964ef1c48fdfda87590c1041f71b58d36b";
        hash = "sha256-+FlRwwtLFlzxcgtkdD47G/yrqYKgzo0pWKH1RIBli8A=";
    };

    cargoLock.lockFile = ./Cargo.lock;

    meta = {
        description = "goldfish (`gf`) is a IPC file finder.";
        homepage = "https://github.com/sameoldlab/goldfish";
        license = lib.licenses.mpl20;
        mainProgram = "goldfish";
    };
}
