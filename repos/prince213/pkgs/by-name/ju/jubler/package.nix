{
  lib,
  fetchFromGitHub,
  stdenv,

  # nativeBuildInputs
  cmake,
  pkg-config,
  qt6,

  # buildInputs
  ffmpeg,
  hunspell,
  mpv-unwrapped,
  openssl,
  zlib,

  # nativeCheckInputs
  writableTmpDirAsHomeHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "jubler";
  version = "11.0.0-alpha";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "teras";
    repo = "Jubler";
    tag = "v${finalAttrs.version}";
    hash = "sha256-grYyGXA8s6TMcaYhNuKqw6RBbqrxAimn+iBJ+5MsCJ4=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "0.0.0-SNAPSHOT" "${finalAttrs.version}"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.wrapQtAppsHook
  ];

  cmakeFlags = [
    (lib.cmakeBool "JUBLER_PACKAGED" true)
  ];

  buildInputs = [
    ffmpeg
    hunspell
    mpv-unwrapped
    openssl
    qt6.qtbase
    qt6.qtsvg
    qt6.qttools
    zlib
  ];

  doCheck = true;
  nativeCheckInputs = [ writableTmpDirAsHomeHook ];

  installPhase = lib.optionalString stdenv.hostPlatform.isDarwin ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r Jubler.app $out/Applications

    runHook postInstall
  '';

  postFixup = lib.optionalString stdenv.hostPlatform.isDarwin ''
    makeWrapper $out/Applications/Jubler.app/Contents/MacOS/Jubler $out/bin/jubler
  '';

  meta = {
    description = "Subtitle editor for text-based subtitles";
    homepage = "https://jubler.org/";
    downloadPage = "https://github.com/teras/Jubler/releases";
    changelog = "https://github.com/teras/Jubler/blob/v${finalAttrs.version}/Changelog.md";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ prince213 ];
    mainProgram = "jubler";
    platforms = with lib.platforms; darwin ++ linux;
  };
})
