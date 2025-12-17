{
    lib,
    stdenvNoCC,
    fetchFromGitHub,
    nix-update-script,
}:
stdenvNoCC.mkDerivation rec {
    pname = "super-sub-scripts";
    version = "0-unstable-2025-06-25";

    src = fetchFromGitHub {
        owner = "jpmvferreira";
        repo = "espanso-mega-pack";
        rev = "abb8e9f8baaf3196e876f2c54b246e2fabe42947";
        sparseCheckout = [ pname ];
        sha256 = "sha256-ltmRSm6U8emTIkh28JkoXGKRBwjrhNnJdOV52Xe4ars=";
    };

    installPhase = ''
        cp -r ${pname} $out
    '';

    passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

    meta = {
        description = "A collection of curated home built packages for the cross-platform text expander Espanso";
        homepage = "https://github.com/jpmvferreira/espanso-mega-pack";
        license = lib.licenses.mit;
    };
}
