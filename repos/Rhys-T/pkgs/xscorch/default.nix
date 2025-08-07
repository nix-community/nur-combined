{
    stdenv, lib, fetchurl,
    gtk2, gtk2-x11,
    perl, # needed for doc/make_text_data.pl
    unixtools, # for `col -b` to clean up readme
    pkg-config,
    maintainers
}: stdenv.mkDerivation rec {
    pname = "xscorch";
    version = "0.2.1";
    src = fetchurl {
        name = "xscorch-${version}.tar.gz";
        urls = [
            "mirror://debian/pool/main/x/xscorch/xscorch_${version}.orig.tar.gz"
            "http://www.xscorch.org/releases/xscorch-${version}.tar.gz"
        ];
        hash = "sha256-oxX3ABoCDGuPZE2xwdxWzPu54+/L8SxBrJ605edctfc=";
    };
    nativeBuildInputs = [perl pkg-config unixtools.col];
    buildInputs = [
        # The Quartz version of gtk2 doesn't implement text rendering.
        (if stdenv.hostPlatform.isDarwin then gtk2-x11 else gtk2)
    ];
    # Pull in Debian patches:
    # - overlapping-memcpy: Use memmove instead of memcpy for overlapping src/dst
    # - gdk-include: Avoid implicit declaration of functions leading to pointer truncation.
    # - gcc10: Fix FTBFS with GCC 10
    debian = fetchurl {
        url = "mirror://debian/pool/main/x/xscorch/xscorch_${version}-1+nmu6.debian.tar.xz";
        hash = "sha256-swlptLX8X/P0Kr3L+vJU/Dd6dbUBx/u1fhB8YzGg0Qw=";
    };
    prePatch = ''
    tar -xaf "$debian"
    patches="$(cat debian/patches/series | sed 's,^,debian/patches/,') $patches"
    '';
    postPatch = ''
        patchShebangs doc/make_text_data.pl
        substituteInPlace Makefile.in --replace-fail '@NETWORK_TRUE@am__EXEEXT_' '#am__EXEEXT_'
    '';
    postInstall = ''
    rmdir "$out"/include
    mkdir -p "$out"/share/applications "$out"/share/pixmaps "$out"/share/doc/xscorch
    cp debian/xscorch.desktop "$out"/share/applications
    cp debian/xscorch.xpm "$out"/share/pixmaps
    mv "$out"/share/xscorch/xscorch.txt "$out"/share/doc/xscorch/README.backspaces.txt
    col -b < "$out"/share/doc/xscorch/README.backspaces.txt > "$out"/share/doc/xscorch/README.txt
    mv "$out"/share/xscorch/copying.txt "$out"/share/doc/xscorch/COPYING
    '';
    meta = {
        description = "Clone of Scorched Earth";
        longDescription = ''
            Xscorch is a clone of the classic DOS game, "Scorched Earth". The basic goal 
            is to annihilate enemy tanks using overpowered guns :).  Basically, you buy 
            weapons, you target the enemy by adjusting the angle of your turret and 
            firing power, and you hope to destroy their tank before they destroy yours.
        '';
        homepage = "http://www.xscorch.org/";
        changelog = "http://www.xscorch.org/releases/ChangeLog-latest";
        license = lib.licenses.gpl2Only;
        mainProgram = "xscorch";
        maintainers = [maintainers.Rhys-T];
    };
}
