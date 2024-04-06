{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  curl,
  freetype,
  libarchive,
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
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "Drewol";
    repo = "unnamed-sdvx-clone";
    rev = "v${finalAttrs.version}";
    hash = "sha256-PiX6R9v6Ris5B89TFCf6Mebe95SGGAdYcryxUTxAZ1E=";
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
    libjpeg
    libogg
    libvorbis
    openssl
    rapidjson
    SDL2
  ];

  postInstall = ''
    mkdir -p $out/bin $out/share/unnamed-sdvx-clone
    cp -r ../bin/. $out/share/unnamed-sdvx-clone
    ln -s $out/share/unnamed-sdvx-clone/usc-game $out/bin/usc-game
  '';

  env.NIX_CFLAGS_COMPILE = "-Wno-error";

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "usc-game";
    description = "A game based on K-Shoot MANIA and Sound Voltex";
    homepage = "https://github.com/Drewol/unnamed-sdvx-clone";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
})
