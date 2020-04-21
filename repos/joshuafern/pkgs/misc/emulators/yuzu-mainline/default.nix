{ stdenv, fetchgit, cmake, libressl, wrapQtAppsHook, SDL2, qtbase, python2 }:

stdenv.mkDerivation {
  pname = "yuzu-mainline";
  version = "unstable-2020-04-13";

  src = fetchgit {
    url = "https://github.com/yuzu-emu/yuzu-mainline";
    rev = "20c42dc9ea8bdc208d9d274350af2ff347876c76";
    sha256 = "0486nhpvl824ajksn496g0rfi9hismm8xzwdka5lplxrdmk961q2";
    leaveDotGit = true;
    fetchSubmodules = true;
  };

  enableParallelBuilding = true;
  nativeBuildInputs = [ cmake libressl wrapQtAppsHook ];
  cmakeFlags = "-DCMAKE_BUILD_TYPE=Release";
  buildInputs = [ SDL2 qtbase python2 ];

  meta = with stdenv.lib; {
    homepage = "https://yuzu-emu.org";
    description = "An experimental open-source emulator for the Nintendo Switch";
    license = licenses.gpl2;
    maintainers = with maintainers; [ ivar ];
    platforms = platforms.linux;
  };
}