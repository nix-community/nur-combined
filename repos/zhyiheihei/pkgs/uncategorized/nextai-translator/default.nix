{
  lib,
  appimageTools,
  sources,
}:
let
  inherit (sources.nextai-translator) version src;
  pname = "nextai-translator";
  extracted = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs =
    pkgs: with pkgs; [
      webkitgtk_4_1
      libsoup_3
      libayatana-appindicator
      librsvg
      xdotool
    ];

  extraInstallCommands = ''
    install -Dm644 "${extracted}/usr/share/applications/NextAI Translator.desktop" \
      $out/share/applications/${pname}.desktop
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-fail "Exec=app" "Exec=${pname}" \
      --replace-fail "Icon=app" "Icon=${pname}"
    install -Dm444 "${extracted}/usr/share/icons/hicolor/32x32/apps/app.png" \
      $out/share/icons/hicolor/32x32/apps/${pname}.png
    install -Dm444 "${extracted}/usr/share/icons/hicolor/128x128/apps/app.png" \
      $out/share/icons/hicolor/128x128/apps/${pname}.png
    install -Dm444 "${extracted}/usr/share/icons/hicolor/256x256@2/apps/app.png" \
      $out/share/icons/hicolor/512x512/apps/${pname}.png
  '';

  meta = {
    changelog = "https://github.com/nextai-translator/nextai-translator/releases/tag/v${version}";
    description = "Selection translation desktop app powered by ChatGPT API";
    homepage = "https://github.com/nextai-translator/nextai-translator";
    license = lib.licenses.agpl3Only;
    mainProgram = "nextai-translator";
    platforms = [ "x86_64-linux" ];
    maintainers = [
      {
        github = "zhyiheihei";
        name = "zhyiheihei";
      }
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
