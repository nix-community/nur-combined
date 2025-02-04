{
  lib,
  stdenv,
  pkgsBuildBuild,
  fetchFromGitHub,
  cmake,
  nettle,
}:

stdenv.mkDerivation rec {
  pname = "rvthtool";
  version = "1.1.1-unstable-2025-02-01";

  src = fetchFromGitHub {
    owner = "GerbilSoft";
    repo = pname;
    rev = "3c240dde95538b8906a2541b99046afdd75578ae";
    hash = "sha256-nzX+AAEY0z3rrPyU0Y/49c2f7nc0nG4gn7B7NnEKSKo=";
  };

  postPatch = lib.optionalString (stdenv.buildPlatform != stdenv.hostPlatform) ''
    # this one depends on the host cc
    substituteInPlace src/libwiicrypto/CMakeLists.txt \
      --replace-fail "ADD_EXECUTABLE(bin2h bin2h.c)" "#ADD_EXECUTABLE(bin2h bin2h.c)" \
      --replace-fail "COMMAND bin2h" "COMMAND $PWD/build/bin/bin2h"
    ${lib.optionalString stdenv.hostPlatform.isWindows ''
      substituteInPlace cmake/platform/win32.cmake \
        --replace-fail WINVER=0x0501 WINVER=0x0601 \
        --replace-fail _WIN32_WINNT=0x0501 _WIN32_WINNT=0x0601
    ''}
    mkdir -p build/bin
    ${pkgsBuildBuild.stdenv.cc}/bin/cc -o build/bin/bin2h src/libwiicrypto/bin2h.c
  '';

  buildInputs = [ nettle ];
  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "Open-source tool for managing RVT-H Reader consoles";
    homepage = "https://github.com/GerbilSoft/rvthtool";
    license = licenses.gpl2Plus;
    platforms = platforms.all;
    broken = stdenv.hostPlatform.isWindows;
    mainProgram = "rvthtool";
  };
}
