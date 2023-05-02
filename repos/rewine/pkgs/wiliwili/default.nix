{ lib
, stdenv
, fetchFromGitHub
, libsForQt5
, pkg-config
, cmake
, mpv
, dbus
, libwebp
, python3
, xorg
, SDL2
, mbedtls
, openssl
, curl
, useDsl ? true
}:
let
  wrapQtAppsHook = libsForQt5.qt5.wrapQtAppsHook;
#  inherit ((builtins.getFlake "github:NixOS/nixpkgs/23485f23ff8536592b5178a5d244f84da770bc87").legacyPackages.${stdenv.system}) curl;
in
stdenv.mkDerivation rec {
  pname = "wiliwili";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "xfangfang";
    repo = "wiliwili";
    rev = "v${version}";
    fetchSubmodules = true;
    hash = "sha256-PO4qzdf71gNEpVI7809fhF0shky8CjXt1sttOWEDTDQ=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapQtAppsHook
    python3
  ];

  buildInputs = [ 
    mpv
    dbus
    curl
    libwebp
    xorg.libXrandr
    xorg.libXinerama
    xorg.libXcursor
    SDL2
    mbedtls
    openssl
  ];

  cmakeFlags = [
    "-DPLATFORM_DESKTOP=ON"
    "-DUSE_SYSTEM_CURL=ON"
    "-DWIN32_TERMINAL=OFF"
    "-DINSTALL=ON"
    "-DUSE_SDL2=${if useDsl then "ON" else "OFF"}"
  ];

  meta = with lib; {
    description = "Yet another Bilibili client";
    homepage = "https://github.com/xfangfang/wiliwili";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ rewine ];
  };
}

