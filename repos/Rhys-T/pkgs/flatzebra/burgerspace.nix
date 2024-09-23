{stdenv, lib, fetchurl, flatzebra, pkg-config, maintainers}: stdenv.mkDerivation {
    pname = "burgerspace";
    version = "1.10.0";
    src = fetchurl {
        urls = [
            "mirror://gentoo/distfiles/c8/burgerspace-1.10.0.tar.gz"
            "https://perso.b2b2c.ca/~sarrazip/dev/burgerspace-1.10.0.tar.gz"
            "http://perso.b2b2c.ca/~sarrazip/dev/burgerspace-1.10.0.tar.gz"
        ];
        hash = "sha256-zLgyCnGJ9tGaY/FHlPv4EcajujH/0ApUhTt5EsCozaM=";
    };
    postPatch = ''sed -i '1i\
#include <sstream>' src/BurgerSpaceEngine.cpp'';
    nativeBuildInputs = [pkg-config];
    buildInputs = [flatzebra];
    meta = {
        description = "Hamburger-smashing video game";
        homepage = "http://perso.b2b2c.ca/~sarrazip/dev/burgerspace.html";
        license = lib.licenses.gpl2Plus;
        maintainers = [maintainers.Rhys-T];
    };
}
