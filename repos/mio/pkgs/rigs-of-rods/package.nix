{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  makeWrapper,
  python3,
  ogre,
  ois,
  mygui,
  fmt,
  rapidjson,
  openal,
  xorg,
  curl ? null,
  openssl ? null,
  angelscript ? null,
  discord-rpc ? null,
  socketw ? null,
  caelum ? null,
  pagedgeometry ? null,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rigs-of-rods";
  version = "2026.01";

  src = fetchFromGitHub {
    owner = "RigsOfRods";
    repo = "rigs-of-rods";
    rev = finalAttrs.version;
    hash = "sha256-DiH5zYoYDucMTlLgRqQvbktXk+WkgWtjdUN0yQoVnvA=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    makeWrapper
    python3
  ];

  buildInputs = [
    ogre
    ois
    mygui
    fmt
    rapidjson
    openal
    xorg.libX11
  ]
  ++ lib.optionals (curl != null) [ curl ]
  ++ lib.optionals (openssl != null) [ openssl ]
  ++ lib.optionals (angelscript != null) [ angelscript ]
  ++ lib.optionals (discord-rpc != null) [ discord-rpc ]
  ++ lib.optionals (socketw != null) [ socketw ]
  ++ lib.optionals (caelum != null) [ caelum ]
  ++ lib.optionals (pagedgeometry != null) [ pagedgeometry ];

  patches = [
    ./disable-peeroptions-without-socketw.patch
    ./fix-rornet-include.patch
    ./fix-dashboard-regex-include.patch
    ./fix-curlfailinfo.patch
  ];

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=17"
    "-DCMAKE_CXX_STANDARD_REQUIRED=ON"
    "-DROR_BUILD_DEV_VERSION=OFF"
    "-DROR_BUILD_INSTALLER=Off"
    "-DROR_BUILD_DOC_DOXYGEN=OFF"
    "-DROR_USE_PCH=OFF"
    "-DOIS_INCLUDE_DIR=${ois}/include/ois"
    "-DOIS_LIBRARY=${ois}/lib/libOIS.so"
  ];

  NIX_CFLAGS_COMPILE = "-Wno-error=delete-incomplete -Wno-delete-incomplete -DAS_DEPRECATED -Wno-error -Wno-error=format-security -Wno-error=format -Wno-error=format-extra-args";


  postInstall = ''
    mkdir -p "$out/bin"
    makeWrapper "$out/RunRoR" "$out/bin/rigs-of-rods" \
      --chdir "$out"
  '';

  meta = with lib; {
    description = "Open-source soft-body physics sandbox simulation game";
    homepage = "https://www.rigsofrods.org/";
    license = licenses.gpl3Plus;
    mainProgram = "rigs-of-rods";
    platforms = platforms.linux;
  };
})
