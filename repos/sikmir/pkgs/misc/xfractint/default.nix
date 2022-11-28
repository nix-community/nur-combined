{ lib, stdenv, fetchurl, xlibsWrapper }:

stdenv.mkDerivation (finalAttrs: {
  pname = "xfractint";
  version = "20.04p16";

  src = fetchurl {
    url = "https://fractint.org/ftp/current/linux/xfractint-${finalAttrs.version}.tar.gz";
    hash = "sha256-TlQBz+wOb/odqzjjwXfhRFdyCWy+VUIAxRLt7qI8R60=";
  };

  buildInputs = [ xlibsWrapper ];

  makeFlags = [ "PREFIX=$(out)" ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace "/usr/bin/gcc" "gcc" \
      --replace "/usr/bin/install" "install"
  '';

  meta = with lib; {
    description = "Fractal generator";
    homepage = "https://fractint.org/";
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = true;
  };
})
