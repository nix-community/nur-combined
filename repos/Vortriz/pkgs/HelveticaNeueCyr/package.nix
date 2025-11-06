{
    sources,
    stdenvNoCC,
}: let
    inherit (sources.HelveticaNeueCyr) src pname date;
in
    stdenvNoCC.mkDerivation {
        inherit pname src;
        version = date;

        phases = ["unpackPhase" "installPhase"];

        sourceRoot = "./";
        unpackCmd = "tar xvf $curSrc/HelveticaNeueCyr.tar.gz";

        installPhase = ''
            install -Dm644 HelveticaNeueCyr/*.otf -t $out/share/fonts/opentype
        '';
    }
