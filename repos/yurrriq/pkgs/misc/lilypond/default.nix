{ stdenv, fetchgit, ghostscript, texinfo, imagemagick, texi2html, guile
, python2, gettext, flex, perl, bison, pkgconfig, autoreconfHook, dblatex
, fontconfig, freetype, pango, fontforge, help2man, zip, netpbm, groff
, callPackage, makeWrapper, rsync, t1utils
, texlive, tex ? texlive.combine {
    inherit (texlive) scheme-small lh metafont epsf;
  }
, withDocs ? false
}:

let

  version = "2.18.2";

  self = stdenv.mkDerivation {
    pname = "lilypond";
    inherit version;

    src = fetchgit {
      url = "https://git.savannah.gnu.org/r/lilypond.git";
      rev = "release/${version}-1";
      sha256 = "0fk045fmmb6fcv7jdvkbqr04qlwnxzwclr2gzx3gja714xy6a76x";
    };

    postInstall = ''
      for f in "$out/bin/"*; do
          # Override default argv[0] setting so LilyPond can find
          # its Scheme libraries.
          wrapProgram "$f" --set GUILE_AUTO_COMPILE 0 \
                           --set PATH "${ghostscript}/bin" \
                           --argv0 "$f"
      done
    '';

    configureFlags = [
      "--with-ncsb-dir=${ghostscript}/share/ghostscript/fonts"
    ] ++ stdenv.lib.optional (!withDocs) "--disable-documentation";

    preConfigure = ''
      sed -e "s@mem=mf2pt1@mem=$PWD/mf/mf2pt1@" -i scripts/build/mf2pt1.pl
      export HOME=$TMPDIR/home
    '';

    nativeBuildInputs = [ makeWrapper pkgconfig autoreconfHook ] ++
      stdenv.lib.optional withDocs rsync;

    autoreconfPhase = "NOCONFIGURE=1 sh autogen.sh";

    buildInputs =
      [ ghostscript texinfo imagemagick texi2html guile dblatex tex zip netpbm
        python2 gettext flex perl bison fontconfig freetype pango
        fontforge help2man groff t1utils
      ];

    enableParallelBuilding = true;

    meta = with stdenv.lib; {
      description = "Music typesetting system";
      homepage = http://lilypond.org/;
      license = licenses.gpl3;
      maintainers = with maintainers; [ marcweber yurrriq ];
      platforms = platforms.all;
      broken = stdenv.isDarwin;
    };

    patches = [ ./findlib.patch ];
  };

  with-fonts = fonts: callPackage ./with-fonts.nix {
    inherit fonts;
    lilypond = self;
  };

in

self // {
  passthru = { inherit with-fonts; };
  inherit with-fonts;
}
