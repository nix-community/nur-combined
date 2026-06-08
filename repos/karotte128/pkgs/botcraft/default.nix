{ lib
, stdenv
, fetchFromGitHub
, fetchurl
, cmake
, pkg-config
, asio
, openssl
, zlib
, gameVersion ? "latest"
}:

let
  mcData =
    builtins.fromJSON
      (builtins.readFile ./minecraft-data.json);

  resolvedVersion =
    if gameVersion == "latest"
    then mcData.latest
    else gameVersion;

  versionData =
    mcData.versions.${resolvedVersion}
      or (throw "Unsupported Minecraft version: ${resolvedVersion}");

  clientJar = fetchurl {
    url = versionData.client.url;
    hash = versionData.client.hash;
  };
in

stdenv.mkDerivation rec {
  pname = "botcraft";
  version = "unstable-2026-05-21";

  src = fetchFromGitHub {
    owner = "adepierre";
    repo = "Botcraft";
    rev = "926e4dddd48f99af7f18c4cfed06f982be63c4c0";
    hash = "sha256-nbGFIpRzhhbVWx2TSY4CnkEOS5xjHY5vUXCIFBo0NzU=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    asio
    openssl
    zlib
  ];

  postPatch = ''
    substituteInPlace botcraft/cmake/botcraft-config.cmake.in \
    --replace-fail "find_package(Threads)" \
              "include(CMakeFindDependencyMacro)
              find_dependency(Threads)
              find_dependency(protocolCraft CONFIG REQUIRED)"

    substituteInPlace cmake/mc_urls.cmake \
      --replace-fail \
        'function(get_mc_version_urls game_version)' \
        'function(get_mc_version_urls game_version)
            set(VERSION_CLIENT_URL "file://${clientJar}" PARENT_SCOPE)
            set(VERSION_SERVER_URL "" PARENT_SCOPE)
            return()'

    # patch runtime asset path for nix store
    substituteInPlace cmake/assets.cmake \
      --replace-fail \
        'set(ASSET_DIR ./Assets/''${BOTCRAFT_GAME_VERSION})' \
        'set(ASSET_DIR "''${CMAKE_INSTALL_PREFIX}/bin/Assets/''${BOTCRAFT_GAME_VERSION}")'
  '';

  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"

    "-DBOTCRAFT_GAME_VERSION=${resolvedVersion}"

    "-DBOTCRAFT_BUILD_EXAMPLES=OFF"
    "-DBOTCRAFT_BUILD_TESTS=OFF"
    "-DBOTCRAFT_BUILD_DOC=OFF"

    "-DBOTCRAFT_COMPRESSION=ON"
    "-DBOTCRAFT_ENCRYPTION=ON"

    "-DBOTCRAFT_USE_OPENGL_GUI=OFF"
    "-DBOTCRAFT_USE_IMGUI=OFF"
  ];

  meta = with lib; {
    description = "Minecraft bot framework/library in C++";
    homepage = "https://github.com/adepierre/Botcraft";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}