{
  lib,
  stdenv,
  fetchFromGitHub,
  libxcb,
  xcbutilimage,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ffshot";
  version = "1.0.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "shinyblink";
    repo = "ffshot";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lPHPwieotSgA6qF3EGDZk+lME0rqglOnEreYLk0/oUY=";
  };

  buildInputs = [
    libxcb
    xcbutilimage
  ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "farbfeld screenshot utility";
    homepage = "https://github.com/shinyblink/ffshot";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
