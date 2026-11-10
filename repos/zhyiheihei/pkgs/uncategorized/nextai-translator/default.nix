{
  lib,
  appimageTools,
  sources,
}:
let
  pname = "nextai-translator";
  inherit (sources.nextai-translator) version src;
  contents = appimageTools.extract {
    inherit pname version src;
    postExtract = ''
      rm -f $out/usr/lib/gtk-3.0/3.0.0/immodules/im-wayland.so
      sed -i '/im-wayland\.so/d' $out/usr/lib/gtk-3.0/3.0.0/immodules.cache
      sed -i '/^"wayland"/d' $out/usr/lib/gtk-3.0/3.0.0/immodules.cache
    '';
  };
in
appimageTools.wrapAppImage {
  inherit pname version contents;

  extraPkgs =
    pkgs: with pkgs; [
      libgpg-error
      libayatana-appindicator
    ];

  extraInstallCommands = ''
    install -Dm644 "${contents}/usr/share/applications/NextAI Translator.desktop" \
      $out/share/applications/${pname}.desktop
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-fail "Exec=app" "Exec=${pname}" \
      --replace-fail "Icon=app" "Icon=${pname}"
    install -Dm444 "${contents}/usr/share/icons/hicolor/32x32/apps/app.png" \
      $out/share/icons/hicolor/32x32/apps/${pname}.png
    install -Dm444 "${contents}/usr/share/icons/hicolor/128x128/apps/app.png" \
      $out/share/icons/hicolor/128x128/apps/${pname}.png
    install -Dm444 "${contents}/usr/share/icons/hicolor/256x256@2/apps/app.png" \
      $out/share/icons/hicolor/512x512/apps/${pname}.png
  '';

  meta = {
    changelog = "https://github.com/nextai-translator/nextai-translator/releases/tag/v${version}";
    description = "Selection translation desktop app powered by ChatGPT API";
    homepage = "https://github.com/nextai-translator/nextai-translator";
    license = lib.licenses.agpl3Only;
    mainProgram = pname;
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
