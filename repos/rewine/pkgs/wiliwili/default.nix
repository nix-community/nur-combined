{ lib
, stdenv
, fetchFromGitHub
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
, useSdl ? false
}:
stdenv.mkDerivation rec {
  pname = "wiliwili";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "xfangfang";
    repo = "wiliwili";
    rev = "v${version}";
    fetchSubmodules = true;
    hash = "sha256-erORsg8RZbSQ43W60R+e1PrL3EPQSx1qe7RSNZ9kKbU=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
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
    xorg.libXi
    mbedtls
    openssl
  ] ++ lib.optionals useSdl [
    SDL2
  ];

  cmakeFlags = [
    "-DPLATFORM_DESKTOP=ON"
    "-DUSE_SYSTEM_CURL=ON"
    "-DWIN32_TERMINAL=OFF"
    "-DINSTALL=ON"
    "-DUSE_SDL2=${if useSdl then "ON" else "OFF"}"
  ];

  meta = with lib; {
    description = "Yet another Bilibili client";
    homepage = "https://github.com/xfangfang/wiliwili";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ rewine ];
  };
}

