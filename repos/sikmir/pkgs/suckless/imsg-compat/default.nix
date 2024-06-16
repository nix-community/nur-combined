{
  lib,
  stdenv,
  fetchFromGitHub,
  validatePkgConfig,
}:

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
    substituteInPlace libimsg.pc.in --subst-var-by LIBDIR "lib"
  '';

  nativeBuildInputs = [ validatePkgConfig ];

  makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Unofficial port of OpenBSD's imsg utilities";
    homepage = "https://github.com/bsd-ac/imsg-compat";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
