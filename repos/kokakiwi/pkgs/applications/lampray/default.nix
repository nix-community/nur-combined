{ lib, stdenv

, fetchFromGitHub

, cmake
, pkg-config

, SDL2
, curl
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "lampray";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "CHollingworth";
    repo = "Lampray";
    tag = "v${finalAttrs.version}";
    hash = "sha256-q6XoGbP1PvNY/0j7EhIHE3nY/iwmxyb/JkgNEp90PZU=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    SDL2
    curl.dev
  ];

  hardeningDisable = [ "format" ];

  meta = {
    description = "Linux Application Modding Platform. A native Linux mod manager";
    homepage = "https://github.com/CHollingworth/Lampray";
    changelog = "https://github.com/CHollingworth/Lampray/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.unlicense;
    mainProgram = "lampray";
    platforms = lib.platforms.all;
  };
})
