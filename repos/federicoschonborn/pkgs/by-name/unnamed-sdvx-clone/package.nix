{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  curl,
  freetype,
  libarchive,
  libcpr,
  libjpeg,
  libogg,
  libvorbis,
  openssl,
  rapidjson,
  SDL2,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "unnamed-sdvx-clone";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "Drewol";
    repo = "unnamed-sdvx-clone";
    rev = "v${finalAttrs.version}";
    hash = "sha256-wuf7xZztoxzNQJzlJOfH/Dc25/717NevBx7E0RDybho=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    curl
    freetype
    libarchive
    libcpr
    libjpeg
    libogg
    libvorbis
    openssl
    rapidjson
    SDL2
  ];

  cmakeFlags = [ (lib.cmakeBool "USE_SYSTEM_CPR" true) ];

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "usc-game";
    description = "A game based on K-Shoot MANIA and Sound Voltex";
    homepage = "https://github.com/Drewol/unnamed-sdvx-clone";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
})
