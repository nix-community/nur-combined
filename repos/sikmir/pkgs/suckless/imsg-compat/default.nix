{ lib, stdenv, fetchFromGitHub, validatePkgConfig }:

stdenv.mkDerivation (finalAttrs: {
  pname = "imsg-compat";
  version = "7.4.0";

  src = fetchFromGitHub {
    owner = "bsd-ac";
    repo = "imsg-compat";
    rev = finalAttrs.version;
    hash = "sha256-t1nEdsqRtcXWBkkspUb/lQ0PXd2ziaTutnqgwSaxAR4=";
  };

  postPatch = ''
    substituteInPlace libimsg.pc.in \
      --subst-var-by LIBDIR "lib"
  '';

  nativeBuildInputs = [ validatePkgConfig ];

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "Unofficial port of OpenBSD's imsg utilities";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.isc;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
