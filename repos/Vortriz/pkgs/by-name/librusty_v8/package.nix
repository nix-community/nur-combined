{
    stdenv,
    fetchurl,
    gzip,
}:
let
    tag = "142.2.0";
in
stdenv.mkDerivation {
    name = "librusty_v8-${tag}";

    src = fetchurl {
        url = "https://github.com/denoland/rusty_v8/releases/download/v${tag}/librusty_v8_release_x86_64-unknown-linux-gnu.a.gz";
        sha256 = "sha256-xHmofo8wTNg88/TuC2pX2OHDRYtHncoSvSBnTV65o+0=";
    };

    nativeBuildInputs = [ gzip ];

    dontUnpack = true;

    installPhase = ''
        gzip -d -c $src > $out
    '';
}
