{
    stdenvNoCC,
    fetchzip,
}:
stdenvNoCC.mkDerivation {
    pname = "HelveticaNeueCyr";
    version = "1.0";

    src = fetchzip {
        url = "https://github.com/Vortriz/fonts/raw/main/HelveticaNeueCyr.zip";
        sha256 = "sha256-fQPmPYKux2vBxQa6DixnXj1OYQ/zN2210rMLVvlC1BI=";
        stripRoot = false;
    };

    installPhase = ''
        runHook preInstall

        mkdir -p $out/share/fonts/opentype

        install -Dm644 ./*.otf -t $out/share/fonts/opentype

        runHook postInstall
    '';
}
