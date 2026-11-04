{
  lib,
  fetchurl,
  stdenvNoCC,

  # nativeBuildInputs
  libarchive,
  unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "steam";
  version = "6.1";

  src = fetchurl {
    url = "https://client-update.steamstatic.com/appdmg_osx.zip.984652b88a9737e3f4e77c656d9ffa67d5042c2c";
    hash = "sha256-i/TOi0vLxQ9kKYjJVVWfYF56h3NyEW56Kz/RNVAEvts=";
  };

  nativeBuildInputs = [
    libarchive
    unzip
  ];

  unpackPhase = ''
    runHook preUnpack

    unzip $src
    bsdtar xf SteamMacBootstrapper.tar.gz

    runHook postUnpack
  '';

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r Steam.app $out/Applications

    runHook postInstall
  '';

  meta = {
    description = "Digital distribution platform";
    homepage = "https://store.steampowered.com/";
    downloadPage = "https://store.steampowered.com/about/";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ prince213 ];
    mainDarwinApp = "Steam.app";
    platforms = lib.platforms.darwin;
  };
})
