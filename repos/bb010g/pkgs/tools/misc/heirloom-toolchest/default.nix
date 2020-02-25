{ stdenv, fetchurl, writeScript
, bzip2, ncurses, zlib
, heirloom-devtools, pkgconf
, shell ? heirloom-devtools.shell, posixShell ? heirloom-devtools.posixShell
}:

let
  inherit (stdenv) lib;
  inherit (lib) getOutput getBin getLib getDev;
in
stdenv.mkDerivation rec {
  pname = "heirloom";
  version = "070715";

  src = fetchurl {
    url = "mirror://sourceforge/heirloom/${pname}/${version}/${pname}-${version}.tar.bz2";
    sha256 = "03x3jr2f9hsfcd41qkif4wb7mia55maxgwa11871v6q1rh5zfczb";
  };
  patches = [
    ./format-security.patch
    ./pkgconf.patch
    ./disable-static.patch
  ];

  nativeBuildInputs = [
    (getBin heirloom-devtools)
    # TODO: on upstream, add pkg-config's setup hook to pkgconf
    (getBin pkgconf)
    (writeScript "pkgconf-setup-hook" ''
      addPkgConfigPath () {
          addToSearchPath PKG_CONFIG_PATH $1/lib/pkgconfig
          addToSearchPath PKG_CONFIG_PATH $1/share/pkgconfig
      }

      addEnvHooks "$targetOffset" addPkgConfigPath
    '')
  ];
  buildInputs = [
    (getDev bzip2)
    (getDev ncurses)
    (getDev zlib)
  ];

  outputs = [ "out" "lib" "man" ];

  configurePhase = ''
    runHook preConfigure

    substituteInPlace ./build/mk.config \
      --replace 'DEFBIN = /usr/5bin' "DEFBIN = \$($outputBin)/bin" \
      --replace 'SV3BIN = /usr/5bin' "SV3BIN = \$($outputBin)/5bin" \
      --replace 'S42BIN = /usr/5bin/s42' "S42BIN = \$($outputBin)/5bin/s42" \
      --replace 'SUSBIN = /usr/5bin/posix' \
        "SUSBIN = \$($outputBin)/5bin/posix" \
      --replace 'SU3BIN = /usr/5bin/posix2001' \
        "SU3BIN=\$($outputBin)/5bin/posix2001" \
      --replace 'UCBBIN = /usr/ucb' "UCBBIN = \$($outputBin)/ucb" \
      --replace 'CCSBIN = /usr/ccs/bin' "UCBBIN = \$($outputBin)/ccs/bin" \
      --replace 'DEFLIB = /usr/5lib' "LIBDIR = \$($outputLib)/lib" \
      --replace 'DEFSBIN = /usr/5bin' "LIBDIR = \$($outputLib)/bin" \
      --replace 'MANDIR = /usr/share/man/5man' \
        "MANDIR = \$($outputMan)/share/man" \
      --replace 'DFLDIR = /etc/default' \
        "DEFLDIR = \$($outputBin)/etc/default" \
      #

    sed -i ./build/mk.config \
      -e 's/\(`pkgconf[^`]*\s\+\)curses\([` \t]\)/\1ncurses\2/g' \
      -e 's/^#\(LIBBZ2\s*=\)/\1/' \
      -e 's/^\(USE_BZLIB\s*=\s*\)0\($\|\s*#.*\)/\11\2/'
      #

    substituteInPlace ./build/mk.config \
      --replace 'STRIP = strip' 'STRIP = true # strip' \
      #

    runHook postConfigure
  '';

  makeFlags = [
    "SHELL=${shell}"
    "POSIX_SHELL=${posixShell}"
  ];

  preBuild = ''
    ulimit -v unlimited
  '';

  meta = with stdenv.lib; {
    description =
      "The Heirloom Toolchest collection of standard Unix utilities";
    homepage = http://heirloom.sourceforge.net/tools.html;
    # ordered to follow /LICENSE/LICENSE
    license = with licenses; [
      zlib # newly written code & changes to existing code
      caldera # Unix 6th Edition, Unix 7th Edition, & Unix 32V
      bsdOriginalUC # 4BSD
      ccdl # OpenSolaris
      bsd3 # MINIX 2.0
      gpl2Plus # nawk (Caldera)
      lgpl21Plus # libuxre (Caldera)
      lpl-102 # deroff (Plan 9)
      # zlib # cpio's CRC-32 function (zlib 1.1.4)
      infozip # inflate's zip (Info-ZIP's zip 5.50)
      # infozip # unshrink's decompression (Info-ZIP's unzip 5.40)
      # zlib # blast decompression (zlib 1.2.1)
    ];
    maintainers = with maintainers; [ bb010g ];
    platforms = platforms.all;
  };
}
