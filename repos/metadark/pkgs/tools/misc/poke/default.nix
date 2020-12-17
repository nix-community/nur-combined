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
, guiSupport ? false, libX11 ? null, tcl ? null, tcllib ? null, tk ? null
, miSupport ? true, json_c ? null
, textStylingSupport ? true

# Test libraries
, dejagnu
}:

assert guiSupport -> libX11 != null && tcl != null && tcllib != null && tk != null;
assert miSupport -> json_c != null;

stdenv.mkDerivation rec {
  pname = "poke";
  version = "unstable-2020-12-17";
  jitter-version = "0.9.241";

  src = fetchgit {
    url = "git://git.savannah.gnu.org/poke.git";
    rev = "613453823b51ac836b4407717f513b48378aaebe";
    fetchSubmodules = true;
    sha256 = "14d5415ifijn0gi142n57bi81y6chql18kr1g4fj7277hjvc2b7n";
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
