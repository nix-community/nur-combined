{
  lib,
  stdenv,
  fetchFromGitHub,

  cmake,
  pkg-config,

  boost,
  curl,
  doctest,
  fmt,
  httplib,
  libzip,
  lua5_3,
  nlohmann_json,
  openssl,
  rapidjson,
  sol2,
  toml11,
  zlib,
}:

let
  commandlineSrc = fetchFromGitHub {
    owner = "lionkor";
    repo = "commandline";
    rev = "04952e4811e7d44708e64986bbc82fdc3485c800";
    hash = "sha256-otZtis4vf7DQL7nNyHKApTgCHx0vhz6fj9+1wKt9Kbo=";
  };
  sol2_3_3_1 = (sol2.override { lua = lua5_3; }).overrideAttrs (_old: {
    version = "3.3.1";
    src = fetchFromGitHub {
      owner = "ThePhD";
      repo = "sol2";
      rev = "v3.3.1";
      hash = "sha256-7QHZRudxq3hdsfEAYKKJydc4rv6lyN6UIt/2Zmaejx8=";
    };
  });
in
stdenv.mkDerivation (finalAttrs: {
  pname = "beammp-server";
  version = "3.9.0";

  src = fetchFromGitHub {
    owner = "BeamMP";
    repo = "BeamMP-Server";
    rev = "v${finalAttrs.version}";
    hash = "sha256-XV/F5BU2PpeIilq3GlSVgiGEx0njlFr6PTyLsR57gAc=";
  };

  strictDeps = true;

  patches = [
    ../../patches/beammp-server-zlib.patch
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    boost
    curl
    doctest
    fmt
    httplib
    libzip
    lua5_3
    nlohmann_json
    openssl
    rapidjson
    sol2_3_3_1
    toml11
    zlib
  ];

  postPatch = ''
    rm -rf deps/commandline
    mkdir -p deps/commandline
    cp -r ${commandlineSrc}/. deps/commandline/

    substituteInPlace CMakeLists.txt \
      --replace 'include(cmake/Vcpkg.cmake) # needs to happen before project()' "" \
      --replace 'find_package(CURL CONFIG REQUIRED)' 'find_package(CURL REQUIRED)' \
      --replace 'add_subdirectory("deps/toml11")' 'find_package(toml11 CONFIG REQUIRED)'

    substituteInPlace cmake/StandardSettings.cmake \
      --replace 'CHECKOUT_GIT_SUBMODULES "If git is found, initialize all submodules." ON' \
                'CHECKOUT_GIT_SUBMODULES "If git is found, initialize all submodules." OFF'
  '';

  cmakeFlags = [
    "-DCMAKE_TOOLCHAIN_FILE="
    "-DBeamMP-Server_CHECKOUT_GIT_SUBMODULES=OFF"
    "-DBeamMP-Server_ENABLE_UNIT_TESTING=OFF"
  ];

  installPhase = ''
    runHook preInstall

    : ''${cmakeBuildDir:=build}
    if [ -d "$cmakeBuildDir" ]; then
      cd "$cmakeBuildDir"
      licensePath="../LICENSE"
    else
      licensePath="../LICENSE"
    fi

    install -Dm755 BeamMP-Server "$out/bin/BeamMP-Server"
    install -Dm644 "$licensePath" -t "$out/share/doc/beammp-server"

    runHook postInstall
  '';

  broken = stdenv.isDarwin;

  meta = {
    description = "Server for the BeamMP multiplayer mod for BeamNG.drive";
    homepage = "https://github.com/BeamMP/BeamMP-Server";
    license = lib.licenses.agpl3Only;
    mainProgram = "BeamMP-Server";
    maintainers = with lib.maintainers; [
    ];
    platforms = lib.platforms.linux;
  };
})
