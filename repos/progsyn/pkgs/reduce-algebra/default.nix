{
  fetchurl,
  lib,
  makeWrapper,
  stdenv,
  autoconf,
  automake,
  libtool,
  ncurses,
  zlib,
  bzip2,
  libiconv,
  which,
  darwin,
  brotli,
  fontconfig,
  freetype,
  gettext,
  libffi,
  libpng,
  ccache,
  coreutils,
  perl,
  xorg,
  expat,
}:
stdenv.mkDerivation {
  name = "reduce-algebra";
  version = "r6860";
  src = fetchurl {
    url = "https://sourceforge.net/projects/reduce-algebra/files/snapshot_2024-08-12/Reduce-svn6860-src.tar.gz";
    sha1 = "q81l4MA2h+4ky4Rwt26Vl0QPf5c=";
  };
  patches = [./fox.patch];

  nativeBuildInputs =
    [
      autoconf
      automake
      ccache
      coreutils
      libtool
      perl
      ncurses
      zlib
      bzip2
      libiconv
      which
      makeWrapper

      # homebrew package
      expat
      brotli
      fontconfig
      freetype
      gettext
      libffi
      libpng
      xorg.libX11
      xorg.libXau
      xorg.libxcb
      xorg.libXcursor
      xorg.libXdmcp
      xorg.libXext
      xorg.libXfixes
      xorg.libXft
      xorg.libXi
      xorg.libXrandr
      xorg.libXrender
    ]
    ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.Carbon
      darwin.stubs.rez
    ];

  preConfigure = ''
    # Configuration: Rewrite CSL hard-coded paths to use dynamic libraries
    substituteInPlace csl/cslbase/configure csl/cslbase/configure.ac \
      --replace '$LL/libbz2.a' '-lbz2' \
      --replace '$LL/libcurses.a' '-lncurses' \
      --replace '$LL/libexpat.a' '-lexpat' \
      --replace '$LL/libiconv.a' '-liconv' \
      --replace '$LL/libz.a' '-lz' \
      --replace '-lcurses' '-lncurses'

    # Configuration: Avoid configuring or building the REDUCE-bundled libffi
    substituteInPlace configure configure.ac \
      --replace '$SHELL $abssrcdir/libraries/libffi/configure ' 'true '
    substituteInPlace csl/cslbase/Makefile.am csl/cslbase/Makefile.in \
      --replace '-+$(TRACE)@$(MAKE) -C ../libffi install' '@true' \
      --replace '$(TRACE)@cd ../libffi && $(MAKE) install' '@true'

    # Configuration: Rewrite CSL hard-coded paths to use Nix-provided libffi
    substituteInPlace csl/cslbase/Makefile.am csl/cslbase/Makefile.in \
      --replace '../lib/libffi.a' ' ' \
      --replace '../include/ffi.h' ' ' \
      --replace 'LDADD += ' 'LDADD += -lffi '

    # Configuration: Rewrite CSL hard-coded paths to avoid polluting the build environment
    substituteInPlace csl/cslbase/configure.ac \
      --replace '$HOME/ports' '/dev/null' \
      --replace '/opt/local' '/dev/null' \
      --replace '/opt/X11' '/dev/null'

    # Configuration: Rewrite FOX hard-coded paths to use Nix-provided libraries
    substituteInPlace csl/fox/configure.ac \
      --replace '-I/usr/local/include ' ' ' \
      --replace '-I/usr/include/freetype2' '-I${freetype.outPath}/lib' \
      --replace '-I/usr/local/include/freetype2' '-I${freetype.outPath}/lib' \
      --replace '-I/opt/local/include/freetype2' '-I${freetype.outPath}/lib'

    # Configuration: Rewrite CSL hard-coded paths to use Nix-provided libraries
    substituteInPlace csl/cslbase/configure.ac \
      --replace '-I/opt/local/include/freetype2' '-I${freetype.outPath}/lib' \
      --replace '$LL/libbrotlicommon-static.a' '-lbrotlicommon' \
      --replace '$LL/libbrotlidec-static.a' '-lbrotlidec' \
      --replace '$LL/libfontconfig.a' '-lfontconfig' \
      --replace '$LL/libfreetype.a' '-lfreetype' \
      --replace '$LL/libintl.a' '-lintl' \
      --replace '$LL/libpng.a' '-lpng' \
      --replace '$LL/libX11.a' '-lX11' \
      --replace '$LL/libXau.a' '-lXau' \
      --replace '$LL/libxcb.a' '-lxcb' \
      --replace '$LL/libXcursor.a' '-lXcursor' \
      --replace '$LL/libXdmcp.a' '-lXdmcp' \
      --replace '$LL/libXext.a' '-lXext' \
      --replace '$LL/libXfixes.a' '-lXfixes' \
      --replace '$LL/libXft.a' '-lXft' \
      --replace '$LL/libXrandr.a' '-lXrandr' \
      --replace '$LL/libXrender.a' '-lXrender'

    # Configuration: Fix zlib not listed in LIBS
    substituteInPlace csl/configure csl/configure.ac \
      --replace 'LIBS="-lncurses  $LIBS"' 'LIBS="-lncurses -lz $LIBS"'

    ./autogen.sh --fast --with-csl --with-psl
  '';

  configureFlags = [
    "--disable-libtool-lock"
    "--disable-option-checking"
    "--with-ccache"
    "--with-csl"
    "--with-lto"
    "--with-psl"
    "--without-autogen"
  ];
  dontDisableStatic = true;

  installPhase =
    if stdenv.isDarwin
    then ''
      mkdir -p $out/csl $out/psl $out/bin
      cp -r cslbuild/*/csl/*.app $out/csl
      cp macbuild/runcsl.sh $out/csl/redcsl
      chmod +x $out/csl/redcsl

      cp cslbuild/*/redfront/rfcsl $out/csl/rfcsl
      chmod +x $out/csl/rfcsl
      cp macbuild/runcsllisp.sh $out/csl/csl
      chmod +x $out/csl/csl
      cp macbuild/runbootstrapreduce.sh $out/csl/bootstrapreduce
      chmod +x $out/csl/bootstrapreduce

      cp -r pslbuild/*/psl $out/psl
      cp -r pslbuild/*/red $out/psl
      cp macbuild/runpsl.sh $out/psl/redpsl
      chmod +x $out/psl/redpsl
      cp cslbuild/*/redfront/rfpsl $out/psl/rfpsl
      chmod +x $out/psl/rfpsl

      makeWrapper $out/csl/redcsl $out/bin/reduce \
        --argv0 "reduce" \
        --chdir $out

      makeWrapper $out/csl/redcsl $out/bin/redcsl \
        --argv0 "redcsl" \
        --chdir $out

      makeWrapper $out/psl/redpsl $out/bin/redpsl \
        --argv0 "redpsl" \
        --chdir $out
    ''
    else ''
      BUILD=$(scripts/findhost.sh $(./config.guess))

      mkdir -p $out/csl $out/psl $out/reduce.doc $out/bin

      cp scripts/cslhere.sh $out/redcsl
      cp scripts/pslhere.sh $out/redpsl

      cp -r xmpl $out
      cp cslbuild/$BUILD/csl/csl $out/csl
      cp cslbuild/$BUILD/csl/csl.img $out/csl
      cp cslbuild/$BUILD/csl/reduce $out/csl
      cp cslbuild/$BUILD/csl/reduce.img $out/csl
      cp -r cslbuild/$BUILD/csl/reduce.fonts $out/csl
      cp -r cslbuild/$BUILD/csl/reduce.resources $out/csl
      cp bin/rfcsl $out/bin
      cp cslbuild/$BUILD/csl/reduce.doc/BINARY-LICENSE.txt $out/reduce.doc
      cp cslbuild/$BUILD/csl/reduce.doc/BSD-LICENSE.txt $out/reduce.doc

      cp -r pslbuild/$BUILD/psl $out/psl
      cp -r pslbuild/$BUILD/red $out/psl
      cp bin/rfpsl $out/bin

      chmod +x $out/redcsl $out/bin/rfcsl
      chmod +x $out/redpsl $out/bin/rfpsl

      makeWrapper $out/redcsl $out/bin/reduce \
        --argv0 "reduce" \
        --chdir $out

      makeWrapper $out/redcsl $out/bin/redcsl \
        --argv0 "redcsl" \
        --chdir $out

      makeWrapper $out/redpsl $out/bin/redpsl \
        --argv0 "redpsl" \
        --chdir $out
    '';

  meta = with lib; {
    description = "A portable general-purpose computer algebra system";
    homepage = "https://reduce-algebra.sourceforge.io/";
    license = licenses.bsd2;
    platforms = platforms.unix;
  };
}
