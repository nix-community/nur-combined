{ lib
, stdenv
, fetchgit

# Required build tools
, autoconf
, automake
, bison
, flex
, gettext
, help2man
, libtool
, makeWrapper
, pkg-config
, texinfo

# Required runtime libraries
, boehmgc
, readline

# Optional runtime libraries
# TODO: Enable guiSupport by default once it's been fully implemented
# TODO: Add nbdSupport, requires packaging libndb
, guiSupport ? false, tcl, tcllib, tk
, miSupport ? true, json_c
, textStylingSupport ? true

# Test libraries
, dejagnu
}:

stdenv.mkDerivation rec {
  pname = "poke";
  version = "unstable-2021-02-14";
  jitter-version = "0.9.251";

  src = fetchgit {
    url = "git://git.savannah.gnu.org/poke.git";
    rev = "d446afcb23fc2b8800de77caf07304fd3e0f0c49";
    fetchSubmodules = true;
    sha256 = "13nms0wwr45d08m5ya8b5l4mfixs0q4jysxy49w374ywpip65q89";
  };

  patches = [
    ./fix-tcl-tk-includes.patch
  ];

  postPatch = ''
    patchShebangs .
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoconf
    automake
    bison
    flex
    gettext
    help2man
    libtool
    makeWrapper
    pkg-config
    texinfo
  ];

  buildInputs = [ boehmgc dejagnu readline ]
  ++ lib.optional guiSupport tk
  ++ lib.optional miSupport json_c
  ++ lib.optional textStylingSupport gettext;

  preConfigure = ''
    ./bootstrap \
      --skip-po \
      --no-git \
      --gnulib-srcdir=gnulib \
      --jitter-srcdir=jitter
  '';

  configureFlags = lib.optionals guiSupport [
    "--with-tcl=${tcl}/lib"
    "--with-tk=${tk}/lib"
    "--with-tkinclude=${tk.dev}/include"
  ];

  buildFlags = [
    "JITTER_VERSION=${jitter-version}"
  ];

  enableParallelBuilding = true;

  doCheck = true;
  checkInputs = [ dejagnu ];

  postFixup = lib.optionalString guiSupport ''
    wrapProgram "$out/bin/poke-gui" \
      --prefix TCLLIBPATH ' ' ${tcllib}/lib/tcllib${tcllib.version}
  '';

  meta = with lib; {
    description = "Interactive, extensible editor for binary data";
    homepage = "http://www.jemarch.net/poke";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ metadark ];
    platforms = platforms.unix;
  };
}
