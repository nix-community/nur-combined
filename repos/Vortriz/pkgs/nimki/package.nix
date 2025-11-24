{
    lib,
    stdenv,
    fetchFromGitHub,
    ncurses,
}:

stdenv.mkDerivation {
    pname = "nimki";
    version = "0.1.4-unstable-2025-11-23";

    src = fetchFromGitHub {
        owner = "Anik200";
        repo = "nimki";
        rev = "a824739d1789600c499889c251c90f51f39786a5";
        hash = "sha256-6oTi8NIt2msbvlBVgutPh+ckfoWwelzGYdrPiTlCEFc=";
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
