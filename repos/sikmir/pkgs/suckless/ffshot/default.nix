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

  meta = with lib; {
    description = "farbfeld screenshot utility";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.isc;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
