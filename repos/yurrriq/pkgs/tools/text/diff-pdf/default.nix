{ stdenv, fetchFromGitHub,
  pkgconfig, automake, autoconf,
  Cocoa, libX11, wxmac, cairo, poppler }:

stdenv.mkDerivation rec {
  name = "diff-pdf-${version}";

  # version = "0.2";
  # src = fetchFromGitHub {
  #   owner = "vslavik";
  #   repo = "diff-pdf";
  #   rev = "v${version}";
  #   sha256 = "1jj7bg5hji3fhnwk9l3j33042gl8sc3pg8ylc2851wg3rrc10xym";
  # };
  #
  # patches = [ ./5aaedfa.patch ];

  version = "48416f3";

  src = fetchFromGitHub {
    owner = "vslavik";
    repo = "diff-pdf";
    rev = version;
    sha256 = "06r3600mj8ndqsnr8qnf1kddghzmwlppcxgq9rhwm6qn8c3jryd9";
  };

  nativeBuildInputs = [ pkgconfig automake autoconf ];

  buildInputs = [ Cocoa libX11 wxmac cairo poppler ];

  configurePhase = ''
    mkdir -p $out
    ./bootstrap
    ./configure --disable-dependency-tracking \
                --disable-silent-rules \
                --prefix=$out
  '';

  meta = with stdenv.lib; {
    description = "Visually compare two PDF files";
    inherit (src.meta) homepage;
    repositories.git = git://github.com/vslavik/diff-pdf.git;
    license = licenses.gpl2;
    maintainers = with maintainers; [ yurrriq ];
    platforms = platforms.unix;
  };
}
