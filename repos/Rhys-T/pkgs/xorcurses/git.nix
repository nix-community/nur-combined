{stdenv, lib, fetchFromGitHub, ncurses, maintainers}: import ./generic.nix rec {
    inherit stdenv lib ncurses maintainers;
    version = "0.2.2-unstable-2023-01-31";
    src = fetchFromGitHub {
        owner = "jwm-art-net";
        repo = "XorCurses";
        rev = "fb2372a7a1f639a4129f5a6ccca5a8da3b5eb4c7";
        hash = "sha256-Nh3p2VdmRlcOblH4aPm/WoYuFTxLUno1sLoZ6xf315Y=";
    };
    homepage = "https://github.com/jwm-art-net/XorCurses";
}
