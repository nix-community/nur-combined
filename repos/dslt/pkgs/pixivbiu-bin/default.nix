{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pixivbiu-bin";
  version = "3.0.1";

  src = fetchurl {
    url = "https://github.com/txperl/PixivBiu/releases/download/v${finalAttrs.version}/PixivBiu_${finalAttrs.version}_linux_amd64.tar.gz";
    hash = "sha256-dgA1LV1P7U/lYMcuNwRdPpdH1/ul1qt0QLOcVVP147M=";
  };

  sourceRoot = ".";

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    install -Dm755 pixivbiu $out/bin/pixivbiu

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/pixivbiu \
      --run 'export PIXIVBIU_DATA_DIR="''${PIXIVBIU_DATA_DIR:-''${XDG_DATA_HOME:-$HOME/.local/share}/pixivbiu}"'
  '';

  meta = {
    description = "Pixiv auxiliary tool, prebuilt binary release";
    homepage = "https://github.com/txperl/PixivBiu";
    changelog = "https://github.com/txperl/PixivBiu/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "pixivbiu";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
  };
})
