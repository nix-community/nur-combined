{
    lib,
    stdenvNoCC,
    fetchFromGitHub,
}:
stdenvNoCC.mkDerivation rec {
    pname = "greek-letters-improved";
    version = "unstable-2025-06-25";

    src = fetchFromGitHub {
        owner = "jpmvferreira";
        repo = "espanso-mega-pack";
        rev = "abb8e9f8baaf3196e876f2c54b246e2fabe42947";
        sparseCheckout = [ pname ];
        hash = "sha256-j+P/LUhjkhpY1Zca6Q+78JtfMrBlX8HW8PZiGCX8vT4=";
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
