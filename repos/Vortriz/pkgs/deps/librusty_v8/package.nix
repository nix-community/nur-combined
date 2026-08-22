{
    stdenv,
    fetchurl,
    gzip,
}:
stdenv.mkDerivation rec {
    pname = "librusty_v8";
    version = "152.2.0";

    src = fetchurl {
        url = "https://github.com/denoland/rusty_v8/releases/download/v${version}/librusty_v8_release_x86_64-unknown-linux-gnu.a.gz";
        hash = "sha256-tmg+mvy3f72MssOs9F001SApqyFrMyUiyVF5wS8P7Tw=";
    };

    nativeBuildInputs = [ gzip ];

    dontUnpack = true;

    installPhase = ''
        gzip -d -c $src > $out
    '';

    passthru.yanseu = {
        version = "stable";
    };
}
