{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, qt6Packages
, openssl
, pulseaudio
}:

stdenv.mkDerivation rec {
  pname = "librepods";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "kavishdevar";
    repo = "librepods";
    rev = "linux-v${version}";
    hash = "sha256-ZvHbSSW0rfcsNUORZURe0oBHQbnqmS5XT9ffVMwjIMU=";
  };

  sourceRoot = "${src.name}/linux";

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    openssl
    pulseaudio

    qt6Packages.qtbase
    qt6Packages.qtconnectivity
    qt6Packages.qtdeclarative
    qt6Packages.qtwayland
    qt6Packages.qttools
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
  ];

  meta = {
    description = "AirPods liberated from Apple's ecosystem (LibrePods Linux app)";
    homepage = "https://github.com/kavishdevar/librepods";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.linux;
    mainProgram = "librepods";
  };
}


