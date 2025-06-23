{
  sources,
  version,
  lib,
  buildLua,
  danmakufactory,
  opencc,
}:
buildLua (final: {
  inherit (sources) pname src;
  inherit version;

  scriptName = "uosc_danmaku";
  scriptPath = ".";
  passthru.scriptName = final.scriptName;

  fixupPhase = ''
    runHook preFixup

    rm -rf $out/share/mpv/scripts/${final.scriptName}/bin/DanmakuFactory/*
    ln -sf ${danmakufactory}/bin/DanmakuFactory $out/share/mpv/scripts/${final.scriptName}/bin/DanmakuFactory

    rm -rf $out/share/mpv/scripts/${final.scriptName}/bin/OpenCC_Windows
    rm -rf $out/share/mpv/scripts/${final.scriptName}/bin/OpenCC_Linux/*
    ln -sf ${opencc}/bin/opencc $out/share/mpv/scripts/${final.scriptName}/bin/OpenCC_Linux

    rm -rf $out/share/mpv/scripts/${final.scriptName}/bin/dandanplay/dandanplay.exe

    runHook postFixup
  '';

  meta = {
    changelog = "https://github.com/Tony15246/uosc_danmaku/releases/tag/${final.version}";
    description = "在MPV播放器中加载弹弹play弹幕";
    homepage = "https://github.com/Tony15246/uosc_danmaku";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      # `dandanplay` binary executable is licensed under the MIT license.
      # https://github.com/zhongfly/dandanplay/blob/main/LICENSE
      binaryNativeCode
    ];
  };
})
