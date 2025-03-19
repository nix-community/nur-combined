{rev ? null, tag ? null, version, hash, stdenv, lib, fetchFromGitHub, fetchpatch, SDL_compat, SDL_mixer, xorg?null, yaml-cpp, maintainers}: let
    # Eliminate any trace of the real SDL1:
    SDL_compat_mixer = if builtins.elem SDL_compat SDL_mixer.buildInputs then SDL_mixer else let
        SDL_compat' = SDL_compat // {
            dev = lib.getDev SDL_compat;
        };
    in SDL_mixer.override (old: {
        SDL = SDL_compat';
        smpeg = (old.smpeg.override {
            SDL = SDL_compat';
        }).overrideAttrs (old: lib.optionalAttrs (builtins.length SDL_compat.propagatedBuildInputs == 0) {
            buildInputs = (old.buildInputs or []) ++ [xorg.libX11];
        });
    });
in stdenv.mkDerivation rec {
    pname = "asciiportal";
    inherit version;
    PDCursesVersion = "3.9";
    yamlCppVersion = yaml-cpp.version;
    src = fetchFromGitHub {
        owner = "cymonsgames";
        repo = "ASCIIpOrtal";
        inherit rev tag hash;
    };
    PDCursesSrc = fetchFromGitHub {
        owner = "wmcbrine";
        repo = "PDCurses";
        tag = PDCursesVersion;
        hash = "sha256-DNxIwNK6hsiZC+bjbmdUGEOkJM3/fEOEFJYZOUh/f0w=";
    };
    postUnpack = ''
        cp -r "$PDCursesSrc" "source/PDCurses-$PDCursesVersion"
        chmod -R u+rwX "source/PDCurses-$PDCursesVersion"
    '';
    patches = [ (fetchpatch {
        name = "0001-Fix-undefined-behaviour.patch";
        url = "https://patch-diff.githubusercontent.com/raw/cymonsgames/ASCIIpOrtal/pull/25.patch";
        hash = "sha256-gUe1n5TTE7Lm7Bj0hq8gYVt2x0Mioe1nMZtnRbQxvVg=";
    }) ];
    postPatch = ''
        sed -E -i '
            s/^CXX =/#&/
            s/libpdcurses\.a/pdcurses.a/g
            s/^\$\(PDCURSES_DIR\):/zzz_&/
            s/-L yaml-cpp //
            /^%\.o:/ s/ yaml-cpp//
            /^\$\(EXE_NAME\):/ {
                s@yaml-cpp/libyaml-cpp\.a @@
                n
                s/\$\^/& -lyaml-cpp/
            }
            s@\$\(DESTDIR\)/usr/@$(out)/@g
        ' Makefile.default
        substituteInPlace Makefile.common --replace-fail '-l yaml-cpp' '''
        if [[ -e README.md ]]; then
            substituteInPlace Makefile.default --replace-fail 'cp README CHANGELOG ' 'cp README.md CHANGELOG.md '
        fi
        echo '.PHONY: install' >> Makefile
        echo '.PHONY: install' >> Makefile.default
        substituteInPlace src/ap_filemgr.cpp --replace-fail '/usr/' "$out/"
    '';
    buildInputs = [ SDL_compat SDL_compat_mixer yaml-cpp ];
    preBuild = ''
        if grep -q '^everything:' Makefile; then
            buildFlagsArray+=(everything)
        fi
    '';
    makeFlags = [ "PDCURSES_VER=$(PDCursesVersion)" "YAML-CPP_VER=$(yamlCppVersion)" ];
    meta = {
        description = "It's like portal, but in ASCII. And 2D. Sweet look-through mechanic, tho.";
        longDescription = ''
            Grab your hand-held portal device and enter the test chambers for a
            non-euclidean good time.
            ASCIIpOrtal is a text based puzzle game inspired by the popular video game.
            In ASCIIpOrtal you overcome challenges by placing portal way-points, joining
            two points in the map. If the player or any object passes through one portal
            way-point it will seamlessly exit the other.
        '';
        homepage = "https://github.com/cymonsgames/ASCIIpOrtal";
        license = with lib.licenses; [
            # Repo contains a GPL-3.0 COPYING file.
            # There's nothing in the other files to clarify whether it's 'plus' or 'only'.
            # And the source files that _do_ have license comments seem to have an _MIT_ license in them.
            # :shrug: This seems like a safe guess for now.
            gpl3Only
            # A couple of the level packs use this:
            cc-by-sa-20
        ];
        mainProgram = "asciiportal";
        maintainers = [maintainers.Rhys-T];
    };
}
