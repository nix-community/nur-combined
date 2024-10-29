{stdenv, lib, version, src, patches ? [], ncurses, homepage, maintainers}: stdenv.mkDerivation rec {
    pname = "xorcurses";
    inherit version src patches;
    postPatch = ''
        substituteInPlace Makefile --replace-fail 'CC:=' '#CC:='
        for file in *.c; do
            sed -E -i 's/mvwprintw\(([^,]+, [^,]+, [^,]+), ([^"][^,)]+)\)/mvwprintw(\1, "%s", \2)/g' "$file"
        done
    '';
    makeFlags = ["PREFIX=$(out)/" "LIBS=-lncurses"];
    buildInputs = [ncurses];
    preInstall = "mkdir -p \"$out\"/bin";
    meta = {
        description = "Puzzle game set inside a series of mazes";
        longDescription = ''
            Based on the game XOR by Astral Software (C) 1987
            Xor is a puzzle game set inside a series of mazes.
            XorCurses is a console/terminal ASCII character
            game written for Linux in C and uses the ncurses
            library.
        '';
        inherit homepage;
        license = lib.licenses.gpl3Only;
        mainProgram = "xorcurses";
        maintainers = [maintainers.Rhys-T];
    };
}
