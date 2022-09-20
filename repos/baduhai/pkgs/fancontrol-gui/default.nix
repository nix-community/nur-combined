{ lib, mkDerivation, fetchFromGitHub, cmake, extra-cmake-modules, qtbase, wrapQtAppsHook, qtquickcontrols2, qtdeclarative, lm_sensors, kirigami2, kdbusaddons, knotifications, kdeclarative, kauth, kpackage, ki18n, kconfig, systemd, kcmutils, plasma-framework }:

mkDerivation rec{
  pname = "fancontrol-gui";
  version = "0.8";
  
  src = fetchFromGitHub {
    owner = "Maldela";
    repo = "Fancontrol-GUI";
    rev = "v${version}";
    sha256 = "hJaU8SL0b6GmTONGSIzUzzbex6KxHf2Np0bCX8YSSVM=";
  };
  
  nativeBuildInputs = [ cmake extra-cmake-modules wrapQtAppsHook ];
  
  buildInputs = [ qtbase qtquickcontrols2 qtdeclarative lm_sensors kirigami2 kdbusaddons knotifications kdeclarative kauth kpackage ki18n kconfig systemd kcmutils plasma-framework ];
  
  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=/usr"
    "-DCMAKE_BUILD_TYPE=Release"
    "-DLIB_INSTALL_DIR=lib"
    "-DBUILD_TESTING=off"
    "-DSTANDARD_CONFIG_FILE=/etc/fancontrol"
    "-DSTANDARD_SERVICE_NAME=fancontrol"
    "-DBUILD_GUI=on"
    "-DBUILD_KCM=on"
    "-DBUILD_HELPER=on"
    "-DBUILD_PLASMOID=on"
    "-DINSTALL_SHARED=on"
  ];
  
#   sourceRoot = "source/src";
  
  meta = with lib; {
    description = "GUI for fancontrol and the fancontrol systemd service";
    homepage = "https://github.com/Maldela/Fancontrol-GUI";
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
