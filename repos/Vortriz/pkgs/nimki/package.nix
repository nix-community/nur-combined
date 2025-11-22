{
    lib,
    stdenv,
    fetchFromGitHub,
    ncurses,
}:

stdenv.mkDerivation {
    pname = "nimki";
    version = "0.1.3-unstable-2025-11-22";

    src = fetchFromGitHub {
        owner = "Anik200";
        repo = "nimki";
        rev = "4c239ade89236ef56f01e896b3cd967837f0443b";
        hash = "sha256-E0TiTnDduWbXrfHiZe4esvldic+5ymmSA+ZyXB8yR/I=";
    };

    nativeBuildInputs = [ ncurses ];

    installPhase = ''
        mkdir -p $out/bin
        cp nimki $out/bin
    '';

    meta = {
        description = "A simple text editor written in c";
        homepage = "https://github.com/Anik200/nimki";
        license = lib.licenses.gpl3Only;
        mainProgram = "nimki";
        platforms = lib.platforms.all;
    };
}
