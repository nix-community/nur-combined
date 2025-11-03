{
    stdenvNoCC,
    fetchzip,
}:
stdenvNoCC.mkDerivation {
    pname = "SFMono";
    version = "1.0";

    src = fetchzip {
        url = "https://github.com/Vortriz/fonts/raw/main/SFMono.zip";
        sha256 = "0p2gb500fgs3xhdd55wimw6zpjg4g0w3ry4nlvrdmf8qm03wn0qk";
        stripRoot = false;
    };

    installPhase = ''
        runHook preInstall

        mkdir -p $out/share/fonts/opentype

        install -Dm644 ./*.otf -t $out/share/fonts/opentype

        runHook postInstall
    '';
}
