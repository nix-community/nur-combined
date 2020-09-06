{ stdenv, fetchzip, pkg-config, libxcb }:

stdenv.mkDerivation rec {
  pname = "xcb-util";
  version = "0.4";

  src = fetchzip {
    url = "https://xcb.freedesktop.org/dist/xcb-util-0.4.0.tar.bz2";
    sha256 = "1sahmrgbpyki4bb72hxym0zvxwnycmswsxiisgqlln9vrdlr9r26";
  };

  preConfigure = "./autogen.sh";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libxcb ];

  meta = with stdenv.lib; {
    homepage = "https://xcb.freedesktop.org/XcbUtil/";
    description = "The xcb-util module provides a number of libraries which sit on top of libxcb, the core X protocol library, and some of the extension libraries";
    license = licenses.isc;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
