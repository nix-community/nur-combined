{
    stdenv,
    fetchurl,
    gzip,
}:
stdenv.mkDerivation rec {
    pname = "librusty_v8";
    version = "149.2.0";

    src = fetchurl {
        url = "https://github.com/denoland/rusty_v8/releases/download/v${version}/librusty_v8_release_x86_64-unknown-linux-gnu.a.gz";
        hash = "sha256-iu2YY323533Iv7i7R1nsW95HLQv3lD9Y4OYqNQlFxVk=";
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
