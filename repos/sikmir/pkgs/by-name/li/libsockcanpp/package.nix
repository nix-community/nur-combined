{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libsockcanpp";
  version = "1.8.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "SimonCahill";
    repo = "libsockcanpp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Io+FUImqeEK3//HsLrWtfYRVYFRVKckHW3ijRjnR4AM=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail ''$\{CMAKE_INSTALL_PREFIX\}/ ""
  '';

  nativeBuildInputs = [ cmake ];

  meta = {
    description = "A C++ wrapper around Linux's socketcan featureset";
    homepage = "https://github.com/SimonCahill/libsockcanpp";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
