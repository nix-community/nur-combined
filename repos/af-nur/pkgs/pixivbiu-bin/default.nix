{
  lib,
  stdenv,
  sources,
  makeWrapper,
}:

let
  source = if stdenv.hostPlatform.isAarch64 then sources.pixivbiu-bin-aarch64 else sources.pixivbiu-bin-x86_64;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "pixivbiu-bin";
  inherit (source) version src;

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
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
})
