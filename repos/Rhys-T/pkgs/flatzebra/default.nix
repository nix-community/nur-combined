{stdenv, lib, fetchurl, SDL2, SDL2_gfx, SDL2_image, SDL2_mixer, SDL2_ttf, pkg-config, maintainers}: stdenv.mkDerivation {
    pname = "flatzebra";
    version = "0.2.0";
    src = fetchurl {
        urls = [
            "mirror://gentoo/distfiles/49/flatzebra-0.2.0.tar.gz"
            # "https://perso.b2b2c.ca/~sarrazip/dev/flatzebra-0.2.0.tar.gz"
            # "http://perso.b2b2c.ca/~sarrazip/dev/flatzebra-0.2.0.tar.gz"
            "http://sarrazip.com/dev/flatzebra-0.2.0.tar.gz"
        ];
        hash = "sha256-I3GiuIXOFzqKXS0tY+SRbQbTAcmn1iS2ISrVU058Mdw=";
    };
    nativeBuildInputs = [pkg-config];
    buildInputs = [SDL2 SDL2_gfx SDL2_image SDL2_mixer SDL2_ttf];
    outputs = ["out" "dev"];
    meta = {
        description = "Generic game engine for 2D double-buffering animation";
        # homepage = "http://perso.b2b2c.ca/~sarrazip/dev/burgerspace.html";
        homepage = "http://sarrazip.com/dev/burgerspace.html";
        license = lib.licenses.gpl2Plus;
        maintainers = [maintainers.Rhys-T];
    };
}
