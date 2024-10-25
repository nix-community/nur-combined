{stdenvNoCC, lib, fetchurl, perl, ncurses, makeBinaryWrapper, maintainers}: stdenvNoCC.mkDerivation {
    pname = "konify";
    version = "0-unstable-2011-12-09";
    src = fetchurl {
        url = "https://xyne.dev/scripts/graphics/konify/konify.pl";
        hash = "sha256-YHXAEkVByTcfRmY1rGW7Bu3EekUkZ3cbi/G5681etH0=";
    };
    nativeBuildInputs = [makeBinaryWrapper];
    buildInputs = [(perl.withPackages (ps: with ps; [ImageMagick]))];
    dontUnpack = true;
    wrapPath = lib.makeBinPath [ncurses]; # for `tput` command
    preferLocalBuild = true;
    installPhase = ''
    mkdir -p "$out"/bin
    install -m755 "$src" "$out"/bin/konify
    wrapProgram "$out"/bin/konify --prefix PATH : "$wrapPath"
    '';
    meta = {
        description = "Script to generate semi-random desktop backgrounds";
        homepage = "https://xyne.dev/scripts/graphics/konify/";
        license = lib.licenses.gpl2Plus;
        maintainers = [maintainers.Rhys-T];
    };
}
