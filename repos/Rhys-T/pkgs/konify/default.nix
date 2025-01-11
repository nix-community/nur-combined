{stdenvNoCC, lib, fetchurl, perl, ncurses, makeBinaryWrapper, maintainers}: stdenvNoCC.mkDerivation {
    pname = "konify";
    version = "0-unstable-2011-12-09";
    src = fetchurl {
        url = "https://xyne.dev/scripts/graphics/konify/konify.pl";
        hash = "sha256-YHXAEkVByTcfRmY1rGW7Bu3EekUkZ3cbi/G5681etH0=";
    };
    nativeBuildInputs = [makeBinaryWrapper];
    buildInputs = [(perl.withPackages (ps: with ps; let
        # perlPackages.ImageMagick fails to build after the main imagemagick package was updated to 7.1.1-43,
        # because PerlMagick is still an older version with different test files.
        # See <https://github.com/NixOS/nixpkgs/issues/371857>.
        # This was fixed in <https://github.com/NixOS/nixpkgs/pull/372231>, but hasn't made it into nixpkgs-unstable yet.
        # Work around it for now, but automatically switch back once the merge makes it onto non-master branches.
        imagemagick = builtins.elemAt ImageMagick.buildInputs 0;
        ImageMagick' = if ImageMagick.version != imagemagick.version && lib.versionAtLeast imagemagick.version "7.1.1-43" then ImageMagick.overrideAttrs (old: {
            postUnpack = (old.postUnpack or "") + ''
                rm -r "$sourceRoot"/t
                cp -R ${imagemagick.src}/PerlMagick/t "$sourceRoot"/t
                chmod -R u+w "$sourceRoot"/t
            '';
        }) else ImageMagick;
    in [ImageMagick']))];
    dontUnpack = true;
    wrapPath = lib.makeBinPath [ncurses]; # for `tput` command
    preferLocalBuild = true;
    installPhase = ''
        runHook preInstall
        mkdir -p "$out"/bin
        install -m755 "$src" "$out"/bin/konify
        wrapProgram "$out"/bin/konify --prefix PATH : "$wrapPath"
        runHook postInstall
    '';
    meta = {
        description = "Script to generate semi-random desktop backgrounds";
        homepage = "https://xyne.dev/scripts/graphics/konify/";
        license = lib.licenses.gpl2Plus;
        mainProgram = "konify";
        maintainers = [maintainers.Rhys-T];
    };
}
