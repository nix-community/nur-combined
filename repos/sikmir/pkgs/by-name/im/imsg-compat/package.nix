{
  lib,
  stdenv,
  fetchFromGitHub,
  validatePkgConfig,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "imsg-compat";
  version = "8.0.0";

  src = fetchFromGitHub {
    owner = "bsd-ac";
    repo = "imsg-compat";
    tag = finalAttrs.version;
    hash = "sha256-v8z2WBK8P5otWYcpOLQErTXkni9JpXvzwWVnADpIJ/I=";
  };

  postPatch = ''
    substituteInPlace libimsg.pc.in --subst-var-by LIBDIR "lib"
  '';

  nativeBuildInputs = [ validatePkgConfig ];

  makeFlags = [ "PREFIX=$(out)" ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error=implicit-function-declaration";

  meta = {
    description = "Unofficial port of OpenBSD's imsg utilities";
    homepage = "https://github.com/bsd-ac/imsg-compat";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
