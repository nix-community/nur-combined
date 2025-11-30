{
    lib,
    rustPlatform,
    fetchFromGitHub,
}:

rustPlatform.buildRustPackage {
    pname = "batteryd";
    version = "0-unstable-2025-07-04";

    src = fetchFromGitHub {
        owner = "Naxdy";
        repo = "batteryd";
        rev = "7cef1d94f473d2ff70801898e3146650b7dae2fe";
        hash = "sha256-jgkcxbXC0lK1+H23asZlZwAAN1mAPc3wKKyTgvpP/XA=";
    };

    cargoHash = "sha256-puaKo14ni6F8AI/c3D5ndDPPTFe6EFim3xV7Ao65HXc=";

    meta = {
        description = "Simple battery status notification daemon";
        homepage = "https://github.com/Naxdy/batteryd";
        license = lib.licenses.mit;
        mainProgram = "batteryd";
    };
}
