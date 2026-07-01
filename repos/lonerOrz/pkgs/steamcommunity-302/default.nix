{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  libglvnd,
  libX11,
  libXext,
  libICE,
  libSM,
  libXtst,
  openssl,
  icu,
  zlib,
  fontconfig,
  libxkbcommon,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "steamcommunity-302";
  version = "14.0.02";

  src = fetchurl {
    url = "https://www.dogfight360.com/blog/wp-content/uploads/2026/02/steamcommunity_302_Linux_AMD64_V14.0.02.tar.gz";
    hash = "sha256-XgBvAVyAdnnvgAqH+nt4hWKQGtBNeJmt4mSPgrTEoR8=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    libglvnd
    libX11
    libXext
    libICE
    libSM
    libXtst
    stdenv.cc.cc.lib
    openssl
    icu
    zlib
    fontconfig
    libxkbcommon
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/steamcommunity-302
    cp -r ./* $out/opt/steamcommunity-302/

    chmod +x $out/opt/steamcommunity-302/Steamcommunity_302

    makeWrapper $out/opt/steamcommunity-302/Steamcommunity_302 $out/bin/steamcommunity-302 \
      --run "cd $out/opt/steamcommunity-302" \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          icu
          libX11
          libXext
          libICE
          libSM
          libXtst
          libxkbcommon
          libglvnd
          fontconfig
        ]
      }

    runHook postInstall
  '';

  passthru.autoUpdate = false;

  meta = {
    description = "Steamcommunity 302 for Linux";
    homepage = "https://www.dogfight360.com/blog/";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
    binaryNativeCode = true;
  };
})
