{
  lib,
  stdenv,
  fetchFromGitLab,
  fetchzip,
  cmake,
  ninja,
  curl,
  game-music-emu,
  libopenmpt,
  libpng,
  SDL2,
  SDL2_mixer,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "srb2p";
  version = "1.3.6";

  srcs = [
    (fetchFromGitLab {
      name = "srb2p";
      domain = "git.do.srb2.org";
      owner = "SinnamonLat";
      repo = "SRB2";
      rev = "SRB2P-exe-${finalAttrs.version}";
      hash = "sha256-/c4Brej7ChhO9ObQCxpEjqpJXyOOS4VsvVXd/8kyGAI=";
    })

    (fetchzip {
      name = "srb2p-assets";
      url = "https://github.com/riomccloud/srb2p-assets/releases/download/${finalAttrs.version}/srb2p-assets.zip";
      stripRoot = false;
      hash = "sha256-lNmqMYUOf15ZjDPAlqybZKF86g0VnCnNcmKgjKEe0Kw=";
    })
  ];

  patches = [ ./wadlocation.patch ];

  sourceRoot = "srb2p";

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    curl
    game-music-emu
    libopenmpt
    libpng
    SDL2
    SDL2_mixer
    zlib
  ];

  cmakeFlags = [
    "-DGME_INCLUDE_DIR=${game-music-emu}/include"
    "-DOPENMPT_INCLUDE_DIR=${libopenmpt.dev}/include"
    "-DSDL2_INCLUDE_DIR=${SDL2.dev}/include/SDL2"
    "-DSDL2_MIXER_INCLUDE_DIR=${SDL2_mixer.dev}/include/SDL2"
  ];

  postPatch = ''
    substituteInPlace src/sdl/i_system.c --replace "@wadlocation@" $out/share/games/SRB2P
  '';

  preConfigure = ''
    mkdir assets/installer
    cp ../srb2p-assets/*.{pk3,wad} assets/installer
  '';

  postInstall = ''
    mkdir -p $out/bin $out/share/games/SRB2P
    mv $out/lsdlsrb2* $out/bin
    mv $out/*.{pk3,wad} $out/share/games/SRB2P
  '';

  meta = {
    mainProgram = "lsdlsrb2";
    description = "SRB2P is a recreation of Persona's general gameplay into Sonic Robo Blast 2";
    homepage = "https://git.do.srb2.org/SinnamonLat/SRB2";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
