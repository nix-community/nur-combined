{
  lib,
  stdenv,
  cmake,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "bannertool";
  version = "2024-11-30";

  src = fetchFromGitHub {
    owner = "ihaveamac";
    repo = "3ds-bannertool";
    rev = "4959b38ee50a6de9c61a285213c955bdda8a5c79";
    sha256 = "sha256-jzsqy9mjo5vS8bDdVGJmOg5x/AkP22HKJtaw0lTx2Pc=";
  };

  nativeBuildInputs = [ cmake ];

  patches = lib.optional (stdenv.hostPlatform.isWindows) ./mingw-main-fix.patch;

  meta = with lib; {
    description = "A tool for creating 3DS banners. (Mix of Windows unicode fix and CMake build system)";
    homepage = "https://github.com/ihaveamac/3ds-bannertool";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "bannertool";
  };
}
