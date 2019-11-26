{ stdenv, callPackage, fetchgit, lilypond, ghostscript, gyre-fonts }:

let

  version = "2.19.83";

  self = lilypond.overrideAttrs (oldAttrs: {
    inherit version;

    src = fetchgit {
      url = "https://git.savannah.gnu.org/r/lilypond.git";
      rev = "release/${version}-1";
      sha256 = "1ycyx9x76d79jh7wlwyyhdjkyrwnhzqpw006xn2fk35s0jrm2iz0";
    };

    configureFlags = [
      "--disable-documentation"
      "--with-urwotf-dir=${ghostscript}/share/ghostscript/fonts"
      "--with-texgyre-dir=${gyre-fonts}/share/fonts/truetype/"
    ];
  });

in

self // rec {
  with-fonts = fonts: callPackage ./with-fonts.nix {
    inherit fonts;
    lilypond = self;
  };
  passthru = { inherit with-fonts; };
}
