{
  lib,
  appimageTools,
  sources,
}:
let
  inherit (sources.nextai-translator) version src;
in
appimageTools.wrapType2 {
  pname = "nextai-translator";
  inherit version src;

  extraPkgs =
    pkgs: with pkgs; [
      webkitgtk_4_1
      libsoup_3
      libayatana-appindicator
      librsvg
      xdotool
    ];

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
