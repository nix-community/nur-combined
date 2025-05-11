{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libsockcanpp";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "SimonCahill";
    repo = "libsockcanpp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qIjFEbBRnVFZ5NQlFgjljgtWutWCn2EEymfpJ5LuLQU=";
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
