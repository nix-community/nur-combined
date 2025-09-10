{stdenv, lib, fetchurl, fetchpatch, ncurses, maintainers}: import ./generic.nix rec {
    inherit stdenv lib ncurses maintainers;
    version = "0.2.2";
    src = fetchurl {
        url = "https://web.archive.org/web/20200807032528id_/http://jwm-art.net/art/archive/XorCurses-${version}.tar.bz2";
        hash = "sha256-Us4oxOtNEP1RZo0I4X6eKlTVIPHYZLsrZZ28+OAYeWk=";
    };
    patches = [(fetchpatch {
        name = "0001-fix-multi-defs-error.patch";
        url = "https://github.com/jwm-art-net/XorCurses/commit/e6b81ad0b2a211533919f568618bad9720d80dc0.patch";
        hash = "sha256-EmIBV9WMyOUc3ZlRp1NI0TGL0qikAjql3t3nesMM5Js=";
    })];
    homepage = "https://web.archive.org/web/20200924115723/http://jwm-art.net/?p=XorCurses";
}
