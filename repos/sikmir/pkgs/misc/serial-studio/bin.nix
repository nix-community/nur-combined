{
  lib,
  stdenv,
  fetchfromgh,
  unzip,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "serial-studio-bin";
  version = "1.1.7";

  src = fetchfromgh {
    owner = "Serial-Studio";
    repo = "Serial-Studio";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Hl3HoBfDum4APCXpKwQTkrCdTu3UyCnbzHn1omxc9Nc=";
    name = "SerialStudio-${finalAttrs.version}-macOS.zip";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    unzip
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    mv *.app $out/Applications
    makeWrapper $out/{Applications/Serial\ Studio.app/Contents/MacOS/SerialStudio,bin/serial-studio}
    runHook postInstall
  '';

  meta = {
    description = "Multi-purpose serial data visualization & processing program";
    homepage = "https://serial-studio.github.io/";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    skip.ci = true;
  };
})
