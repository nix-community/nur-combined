{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation (finalAttrs: {
  pname = "libsockcanpp";
  version = "0-unstable-2024-02-21";

  src = fetchFromGitHub {
    owner = "SimonCahill";
    repo = "libsockcanpp";
    rev = "621383ebefab3c154c05778315acc7e781924fdb";
    hash = "sha256-ohxSqM4fjti+02Z6ld3tKX/kzZgWn+spvHpPbq/KBSU=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail ''$\{CMAKE_INSTALL_PREFIX\}/ ""
  '';

  nativeBuildInputs = [ cmake ];

  preInstall = ''
    mv {,lib}sockcanppConfigVersion.cmake
  '';

  meta = with lib; {
    description = "A C++ wrapper around Linux's socketcan featureset";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
