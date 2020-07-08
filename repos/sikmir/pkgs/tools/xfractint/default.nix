{ stdenv, fetchurl, xlibsWrapper }:
let
  version = "20.04p14";
in
stdenv.mkDerivation {
  pname = "xfractint";
  inherit version;

  src = fetchurl {
    url = "https://fractint.org/ftp/current/linux/xfractint-${version}.tar.gz";
    sha256 = "0jdqr639z862qrswwk5srmv4fj5d7rl8kcscpn6mlkx4jvjmca0f";
  };

  buildInputs = [ xlibsWrapper ];

  makeFlags = [ "PREFIX=$(out)" ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace "/usr/bin/gcc" "gcc" \
      --replace "/usr/bin/install" "install"
  '';

  meta = with stdenv.lib; {
    description = "Fractal generator";
    homepage = "https://fractint.org/";
    license = licenses.free;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.linux;
    skip.ci = true;
  };
}
