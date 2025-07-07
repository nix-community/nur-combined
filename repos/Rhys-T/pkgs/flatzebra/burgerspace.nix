{stdenv, lib, fetchurl, removeReferencesTo, flatzebra, pkg-config, maintainers}: stdenv.mkDerivation {
    pname = "burgerspace";
    version = "1.10.0";
    src = fetchurl {
        urls = [
            "mirror://gentoo/distfiles/c8/burgerspace-1.10.0.tar.gz"
            # "https://perso.b2b2c.ca/~sarrazip/dev/burgerspace-1.10.0.tar.gz"
            # "http://perso.b2b2c.ca/~sarrazip/dev/burgerspace-1.10.0.tar.gz"
            "http://sarrazip.com/dev/burgerspace-1.10.0.tar.gz"
        ];
        hash = "sha256-zLgyCnGJ9tGaY/FHlPv4EcajujH/0ApUhTt5EsCozaM=";
    };
    postPatch = ''
        sed -i '1i\
        #include <sstream>' src/BurgerSpaceEngine.cpp
    '';
    nativeBuildInputs = [pkg-config removeReferencesTo];
    buildInputs = [flatzebra];
    # Inline functions in flatzebra's headers call `assert()`, which causes the
    # header path to be included in the error messages, adding `flatzebra.dev`
    # to the closure.
    # TODO see if there's a better way to fix this
    postFixup = ''
        remove-references-to -t ${flatzebra.dev} "$out"/bin/*
    '';
    disallowedRequisites = [flatzebra.dev];
    meta = {
        description = "Hamburger-smashing video game";
        # homepage = "http://perso.b2b2c.ca/~sarrazip/dev/burgerspace.html";
        homepage = "http://sarrazip.com/dev/burgerspace.html";
        license = lib.licenses.gpl2Plus;
        mainProgram = "burgerspace";
        maintainers = [maintainers.Rhys-T];
    };
}
