{
    lib,
    stdenvNoCC,
    fetchFromGitHub,
}:
stdenvNoCC.mkDerivation rec {
    pname = "super-sub-scripts";
    version = "unstable-2026-07-02";

    src = fetchFromGitHub {
        owner = "jpmvferreira";
        repo = "espanso-mega-pack";
        rev = "862cbeddfafa8b48a40f2c4d11e3a1bbae2c2e28";
        sparseCheckout = [ pname ];
        hash = "sha256-ltmRSm6U8emTIkh28JkoXGKRBwjrhNnJdOV52Xe4ars=";
    };

    installPhase = ''
        cp -r ${pname} $out
    '';

    meta = {
        description = "A collection of curated home built packages for the cross-platform text expander Espanso";
        homepage = "https://github.com/jpmvferreira/espanso-mega-pack";
        license = lib.licenses.mit;
    };
}
