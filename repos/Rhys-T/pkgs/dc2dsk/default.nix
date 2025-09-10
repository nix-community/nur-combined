{stdenv, lib, fetchurl, maintainers}: stdenv.mkDerivation {
    pname = "dc2dsk";
    version = "0-unstable-2015-11-18";
    src = fetchurl {
        urls = [
            "https://web.archive.org/web/20250724212909id_/https://www.bigmessowires.com/dc2dsk.c"
            "https://www.bigmessowires.com/dc2dsk.c"
        ];
        hash = "sha256-D9pPJAjpiiv2fHoEmR4Ko0z4DiDIgKZLH+Up7N9PGQM=";
    };
    unpackPhase = ''
        runHook preUnpack
        cp "$src" dc2dsk.c
        echo 'all: dc2dsk' > Makefile
        runHook postUnpack
    '';
    # The various fprintf()s incorrectly use %i for size_t, so:
    postPatch = ''
        substituteInPlace dc2dsk.c --replace-fail '%i' '%zu'
    '';
    installPhase = ''
        runHook preInstall
        install -Dm755 dc2dsk -t "$out"/bin
        runHook postInstall
    '';
    meta = {
        description = "Tool to convert Disk Copy 4.2 images to raw .dsk format";
        homepage = "https://www.bigmessowires.com/2013/12/16/macintosh-diskcopy-4-2-floppy-image-converter/";
        license = lib.licenses.bsd3;
        mainProgram = "dc2dsk";
        maintainers = [maintainers.Rhys-T];
    };
}