{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  imgui,
  libGL,
  libogg,
  libvorbis,
  libzip,
  nlohmann_json,
  SDL2,
  SDL2_net,
  spdlog,
  tinyxml-2,
  xorg,
  yaml-cpp,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "spaghettikart";
  version = "Latest2";

  src = fetchFromGitHub {
    owner = "HarbourMasters";
    repo = "SpaghettiKart";
    tag = finalAttrs.version;
    hash = "sha256-/QbV68JoJugMKk9glTKkD23DKBVqZGJbaimfGs0V1ns=";
    fetchSubmodules = true;
  };

  drlibs = fetchFromGitHub {
    owner = "mackron";
    repo = "dr_libs";
    rev = "92844c5c07f05b21855e37b482ed0b3143256cf6";
    hash = "sha256-Wr8Nh/8rg2s17FaSx8JFXLQlIvf8g9IUMIaVlhoB4vQ=";
  };

  threadpool = fetchFromGitHub {
    owner = "bshoshany";
    repo = "thread-pool";
    tag = "v5.0.0";
    hash = "sha256-1TTpt6u3NVIMSExl0ttuwH2owQCetujolnR/t8hDMh0=";
  };

  prism = fetchFromGitHub {
    owner = "KiritoDv";
    repo = "prism-processor";
    rev = "bbcbc7e3f890a5806b579361e7aa0336acd547e7";
    hash = "sha256-jRPwO1Vub0cH12YMlME6kd8zGzKmcfIrIJZYpQJeOks=";
  };

  libgfxd = fetchFromGitHub {
    owner = "glankk";
    repo = "libgfxd";
    rev = "008f73dca8ebc9151b205959b17773a19c5bd0da";
    hash = "sha256-AmHAa3/cQdh7KAMFOtz5TQpcM6FqO9SppmDpKPTjTt8=";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    libGL
    libogg
    libvorbis
    libzip
    nlohmann_json
    SDL2
    SDL2_net
    spdlog
    tinyxml-2
    xorg.libX11
    yaml-cpp
  ];

  cmakeFlags = [
    # spaghettikart
    (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_DR_LIBS" "${finalAttrs.drlibs}")
    # libultraship
    (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_IMGUI" "${imgui.src}")
    (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_THREADPOOL" "${finalAttrs.threadpool}")
    (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_PRISM" "${finalAttrs.prism}")
    (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_LIBGFXD" "${finalAttrs.libgfxd}")
    # torch
    (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_YAML-CPP" "${yaml-cpp.src}")
    (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_TINYXML2" "${tinyxml-2.src}")
    (lib.cmakeBool "libgfxd_POPULATED" true)
    (lib.cmakeFeature "libgfxd_SOURCE_DIR" "${finalAttrs.libgfxd}")
  ];

  meta = {
    mainProgram = "spaghettikart";
    description = "Mario Kart 64 PC port";
    homepage = "https://github.com/HarbourMasters/SpaghettiKart";
    # No license.
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ federicoschonborn ];
    # Torch can't find libgfxd...
    broken = true;
  };
})
