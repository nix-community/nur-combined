{
    lib,
    rustPlatform,
    fetchFromGitHub,
}:
rustPlatform.buildRustPackage {
    pname = "goldfish";
    version = "0.1.0-unstable-2025-11-02";

    src = fetchFromGitHub {
        owner = "sameoldlab";
        repo = "goldfish";
        rev = "4eb6d6964ef1c48fdfda87590c1041f71b58d36b";
        fetchSubmodules = false;
        sha256 = "sha256-+FlRwwtLFlzxcgtkdD47G/yrqYKgzo0pWKH1RIBli8A=";
    };

    cargoHash = "sha256-OJEw436p+P1dW1JSxX1EbyuDJBf4fMbHhpmavrbzTsw=";

    meta = {
        description = "goldfish (`gf`) is a IPC file finder.";
        homepage = "https://github.com/sameoldlab/goldfish";
        license = lib.licenses.mpl20;
        mainProgram = "goldfish";
    };
}
