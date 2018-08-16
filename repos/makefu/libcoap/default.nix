{ lib, stdenv, fetchFromGitHub, autoreconfHook, autoconf-archive, pkgconfig,
gettext, asciidoc, doxygen, libxml2, libxslt, docbook_xsl, ... }:
stdenv.mkDerivation rec {
  name = "libcoap-${version}";
  version = "4.1.2";

  src = fetchFromGitHub {
    owner = "obgm";
    repo = "libcoap";
    rev = "v${version}";
    sha256 = "0f0qq15480ja1s03vn8lzw4b3mzdgy46hng4aigi6i6qbzf29kf5";
  };

  patchPhase = ''
    sed -i 's/$(A2X)/& --no-xmllint/' examples/Makefile.am
  '';
  buildInputs = [ gettext asciidoc doxygen libxml2.bin libxslt docbook_xsl];
  nativeBuildInputs = [ autoreconfHook  autoconf-archive pkgconfig ];

  meta = {
    description = "";
    homepage = http://coap.technology;
    license = stdenv.lib.licenses.gpl2;
    platforms = stdenv.lib.platforms.linux;
    maintainers = with stdenv.lib.maintainers; [ makefu ];
  };
}
