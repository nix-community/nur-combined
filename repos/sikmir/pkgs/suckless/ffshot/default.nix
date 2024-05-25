{
  lib,
  stdenv,
  fetchFromGitHub,
  xorg,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ffshot";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "shinyblink";
    repo = "ffshot";
    rev = "v${finalAttrs.version}";
    hash = "sha256-lPHPwieotSgA6qF3EGDZk+lME0rqglOnEreYLk0/oUY=";
  };

  buildInputs = with xorg; [
    libxcb
    xcbutilimage
  ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "farbfeld screenshot utility";
    inherit (finalAttrs.src.meta) homepage;
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
