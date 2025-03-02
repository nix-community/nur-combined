{stdenv, lib, fetchurl, pkg-config, xorg, gtk3-x11, maintainers}: stdenv.mkDerivation (finalAttrs: let self = finalAttrs.finalPackage; in {
    pname = "xpenguins-ratrabbit";
    version = "3.2.3";
    src = fetchurl {
        urls = [
            "mirror://sourceforge/xpenguins/xpenguins-${self.version}.tar.gz"
            "https://ratrabbit.nl/downloads/xpenguins/xpenguins-${self.version}.tar.gz"
        ];
        hash = "sha256-NQ4TTiof8NuGA7F/nXRTA2z0ym/muhmrZQz4mnTmBPM=";
    };
    nativeBuildInputs = [pkg-config];
    buildInputs = with xorg; [libX11 libXext libXpm libXt gtk3-x11];
    meta = {
        description = "Cute little penguins that walk along the tops of your windows (updated fork by RatrabbiT)";
        homepage = "https://ratrabbit.nl/ratrabbit/software/xpenguins/";
        license = lib.licenses.gpl2Plus;
        mainProgram = "xpenguins";
        maintainers = [maintainers.Rhys-T];
    };
})
