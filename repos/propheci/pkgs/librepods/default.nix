{ lib
, fetchFromGitHub
, nix-filter
, stdenv
, cmake
, qt6
, openssl
, pkg-config
, libpulseaudio
}:

let
  version = "0.1.0";
  originalSource = nix-filter {
    name = "librepods";
    root = fetchFromGitHub {
      owner = "kavishdevar";
      repo = "librepods";
      rev = version;
      hash = "sha256-ZvHbSSW0rfcsNUORZURe0oBHQbnqmS5XT9ffVMwjIMU=";
    };
    include = [
      "linux"
    ];
  };
in stdenv.mkDerivation {
  name = "librepods";
  version = version;
  src = "${originalSource}/linux";

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.full
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    openssl.dev
    libpulseaudio
    qt6.qtbase
  ];

  qtWrapperArgs = [
    "--set" "QT_QPA_PLATFORM" "xcb"
  ];

  PKG_CONFIG_PATH = "${openssl.dev}/lib/pkgconfig";

  meta = with lib; {
    description = "Control Airpods from linux";
    homepage = "https://github.com/kavishdevar/librepods";
    changelog = "https://github.com/kavishdevar/librepods/releases/tag/linux-v${version}";
    license = licenses.gpl3;
    mainProgram = "librepods";
  };
}

