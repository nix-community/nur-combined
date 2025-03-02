{stdenv, lib, fetchurl, xorg, maintainers}: stdenv.mkDerivation {
    pname = "xpenguins";
    version = "2.2";
    src = fetchurl {
        url = "http://xpenguins.seul.org/xpenguins-2.2.tar.gz";
        hash = "sha256-YIgbrBVBmqKHX7VvDB2PvbEsUIPbDh52FDYXi6qGEX4=";
    };
    postPatch = ''
        sed -i 's/^main()/int main()/' ./configure
        substituteInPlace src/xpenguins_theme.c --replace-fail \
            'snprintf(file_base, MAX_STRING_LENGTH, word);' \
            'snprintf(file_base, MAX_STRING_LENGTH, "%s", word);'
        sed -i '1i\
        #include <stdlib.h>\
        #line 1' src/toon_signal.c
    '';
    buildInputs = with xorg; [libX11 libXext libXpm libXt];
    meta = {
        description = "Cute little penguins that walk along the tops of your windows";
        homepage = "http://xpenguins.seul.org/";
        license = lib.licenses.gpl2Plus;
        mainProgram = "xpenguins";
        maintainers = [maintainers.Rhys-T];
    };
}
