{
    stdenvNoCC,
    fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
    pname = "HelveticaNeueCyr";
    version = "unstable-2025-11-06";

    src = fetchFromGitHub {
        owner = "Vortriz";
        repo = "fonts";
        rev = "54136ddb5b5d5ec19304c49cbd18dada96ab505b";
        sparseCheckout = [ "HelveticaNeueCyr.tar.gz" ];
        hash = "sha256-o1hyAerKyUQsifVls22UkwyV8ZfXAATIUkXkLxsIEHc=";
    };

    phases = [
        "unpackPhase"
        "installPhase"
    ];

    sourceRoot = "./";
    unpackCmd = "tar xvf $curSrc/HelveticaNeueCyr.tar.gz";

    installPhase = ''
        install -Dm644 HelveticaNeueCyr/*.otf -t $out/share/fonts/opentype
    '';
}
