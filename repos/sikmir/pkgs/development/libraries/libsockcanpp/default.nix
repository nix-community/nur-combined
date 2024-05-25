{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libsockcanpp";
  version = "0-unstable-2024-03-06";

  src = fetchFromGitHub {
    owner = "SimonCahill";
    repo = "libsockcanpp";
    rev = "f2463f9ac320e457bdb3dd1f406511fb75916f2a";
    hash = "sha256-n3dmkxhdEQXD4ekanfgPZ/BT+p1oYZJowr2m87W5BZ4=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail ''$\{CMAKE_INSTALL_PREFIX\}/ ""
  '';

  nativeBuildInputs = [ cmake ];

  meta = {
    description = "A C++ wrapper around Linux's socketcan featureset";
    inherit (finalAttrs.src.meta) homepage;
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
