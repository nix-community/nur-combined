{ stdenv, fetchurl, perlSupport, libX11, libXt, libXft, ncurses, perl,
  fontconfig, freetype, pkgconfig, libXrender, gdkPixbufSupport, gdk_pixbuf,
  unicode3Support }:

let
  pname = "rxvt-unicode";
  version = "9.22";
in

stdenv.mkDerivation (rec {

  name = "${pname}${if perlSupport then "-with-perl" else ""}${if unicode3Support then "-with-unicode3" else ""}-${version}";

  src = fetchurl {
    url = "http://dist.schmorp.de/rxvt-unicode/Attic/rxvt-unicode-${version}.tar.bz2";
    sha256 = "1pddjn5ynblwfrdmskylrsxb9vfnk3w4jdnq2l8xn2pspkljhip9";
  };

  buildInputs =
    [ libX11 libXt libXft ncurses /* required to build the terminfo file */
      fontconfig freetype pkgconfig libXrender ]
    ++ stdenv.lib.optional perlSupport perl
    ++ stdenv.lib.optional gdkPixbufSupport gdk_pixbuf;

  outputs = [ "out" "terminfo" ];


  patches = [
    # NixOS upstream patches
    # ./rxvt-unicode-9.06-font-width.patch
    # ./rxvt-unicode-256-color-resources.patch

    # display-wide-glyphs patches, to support some fontawesome icons (and other wide icons)
    # see: https://github.com/blueyed/rxvt-unicode/tree/display-wide-glyphs
    ./font-width-fix.patch
    ./line-spacing-fix.patch
    ./enable-wide-glyphs.patch

    # 24-bit color patch, based on https://github.com/spudowiar/rxvt-unicode
    (fetchurl {
      url = "https://gist.githubusercontent.com/Shados/ea28a7c5e6176053d047d09c2180a2d5/raw/70c6343d1c0b3bca0aba4f587ed501e6cbd98d00/24-bit-color.patch";
      sha256 = "06bn0b12hi2mzk7k0vm9zp43h6wq5d2y38mpwb0ksk8jf3jszq7f";
    })
  ];

  # Handle varying patch levels
  patchPhase = ''
    for i in $patches; do
      echo "Applying patch $i"
      patch -p1 < $i || patch -p0 < $i
    done
  '';

  configureFlags = [
    "--enable-wide-glyphs"
    "--with-terminfo=$terminfo/share/terminfo"
    # "--enable-256-color"
    "--enable-24-bit-color"
    ''${if perlSupport then "--enable-perl" else "--disable-perl"}''
    ''${if unicode3Support then "--enable-unicode3" else "--disable-unicode3"}''
  ];

  preConfigure =
    ''
      mkdir -p $terminfo/share/terminfo
      export TERMINFO=$terminfo/share/terminfo # without this the terminfo won't be compiled by tic, see man tic
      NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I${freetype.dev}/include/freetype2"
      NIX_LDFLAGS="$NIX_LDFLAGS -lfontconfig -lXrender -lpthread "
    ''
    # make urxvt find its perl file lib/perl5/site_perl is added to PERL5LIB automatically
    + stdenv.lib.optionalString perlSupport ''
      mkdir -p $out/$(dirname ${perl.libPrefix})
      ln -s $out/lib/urxvt $out/${perl.libPrefix}
    '';

  postInstall = ''
    mkdir -p $out/nix-support
    echo "$terminfo" >> $out/nix-support/propagated-user-env-packages
  '';

  meta = {
    description = "A clone of the well-known terminal emulator rxvt";
    homepage = "http://software.schmorp.de/pkg/rxvt-unicode.html";
    maintainers = [ stdenv.lib.maintainers.arobyn ];
  };
})
