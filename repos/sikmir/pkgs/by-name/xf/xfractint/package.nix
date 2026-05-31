{
  lib,
  stdenv,
  fetchurl,
  libx11,
  libxft,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xfractint";
  version = "20.04p16";

  __structuredAttrs = true;

  src = fetchurl {
    url = "https://fractint.org/ftp/current/linux/xfractint-${finalAttrs.version}.tar.gz";
    hash = "sha256-TlQBz+wOb/odqzjjwXfhRFdyCWy+VUIAxRLt7qI8R60=";
  };

  buildInputs = [
    libx11
    libxft
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail "/usr/bin/gcc" "gcc" \
      --replace-fail "/usr/bin/install" "install"
  '';

  env.NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";

  meta = {
    description = "Fractal generator";
    homepage = "https://fractint.org/";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = true;
  };
})
