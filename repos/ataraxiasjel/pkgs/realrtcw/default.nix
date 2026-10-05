{
  stdenv,
  lib,
  fetchFromGitHub,
  makeWrapper,
  pkg-config,
  which,
  curl,
  ffmpeg_8,
  freetype,
  libjpeg,
  libogg,
  libopus,
  libvorbis,
  openal,
  opusfile,
  sdl3,
  zlib,
  nix-update-script,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "realrtcw";
  version = "5.44c";

  src = fetchFromGitHub {
    owner = "wolfetplayer";
    repo = "RealRTCW";
    tag = finalAttrs.version;
    hash = "sha256-L1/Fk8AHoGNvrOJrMASHztm2SwOFpq2LPRR0lPBO+0c=";
  };

  enableParallelBuilding = true;

  nativeBuildInputs = [
    makeWrapper
    pkg-config
    which
  ];

  buildInputs = [
    curl
    ffmpeg_8
    freetype
    libjpeg
    libogg
    libopus
    libvorbis
    openal
    opusfile
    sdl3
    zlib
  ];

  installTargets = [ "copyfiles" ];

  makeFlags = [
    "COPYDIR=${placeholder "out"}/opt/realrtcw"
    "USE_INTERNAL_LIBS=0"
    "USE_OPENAL_DLOPEN=0"
    "USE_CURL_DLOPEN=0"
    "STEAM=0"
  ];

  postInstall = ''
    for bin in $out/opt/realrtcw/RealRTCW.*; do
        makeWrapper "$bin" $out/bin/realrtcw \
          --chdir "$out/opt/realrtcw"
      done
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "RealRTCW mod based on ioRTCW engine";
    homepage = src.meta.homepage;
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ataraxiasjel ];
    mainProgram = "realrtcw";
  };
})
